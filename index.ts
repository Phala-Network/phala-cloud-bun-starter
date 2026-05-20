import { serve } from "bun";
import { DstackClient } from "@phala/dstack-sdk";
import { toViemAccountSecure } from '@phala/dstack-sdk/viem';
import { toKeypairSecure } from '@phala/dstack-sdk/solana';
import { getComposeHash, type AppCompose } from '@phala/dstack-sdk/get-compose-hash';

const port = process.env.PORT || 3000;
const defaultHeaders = {
  'Content-Type': 'application/json',
};
const failureThreshold = Number(process.env.FAILURE_THRESHOLD || 10);
let consecutiveFailures = 0;

function jsonResponse(body: unknown, init?: ResponseInit) {
  return new Response(JSON.stringify(body), {
    ...init,
    headers: {
      ...defaultHeaders,
      ...(init?.headers || {}),
    },
  });
}

function errorResponse(error: unknown, status = 502) {
  const message = error instanceof Error ? error.message : String(error);
  return jsonResponse({ error: message }, { status });
}

function recordSuccess() {
  consecutiveFailures = 0;
}

function recordFailure(context: string, error: unknown) {
  consecutiveFailures += 1;
  console.error(`${context} failed (${consecutiveFailures}/${failureThreshold})`, error);
  if (consecutiveFailures >= failureThreshold) {
    console.error("failure threshold reached, exiting to trigger restart");
    setTimeout(() => process.exit(1), 50);
  }
}

console.log(`Listening on port ${port}`);
serve({
  port,
  idleTimeout: 30,

  routes: {
    "/": async () => {
      try {
        const client = new DstackClient();
        const result = await client.info();
        recordSuccess();
        return jsonResponse(result);
      } catch (error) {
        recordFailure("info", error);
        return errorResponse(error, 503);
      }
    },

    "/get_quote": async (req: Request) => {
      try {
        const url = new URL(req.url);
        const text = url.searchParams.get('text') || 'hello dstack';
        const client = new DstackClient();
        const result = await client.getQuote(text);
        recordSuccess();
        return jsonResponse(result);
      } catch (error) {
        recordFailure("get_quote", error);
        return errorResponse(error, 503);
      }
    },

    "/tdx_quote": async (req: Request) => {
      try {
        const url = new URL(req.url);
        const text = url.searchParams.get('text') || 'hello dstack';
        const client = new DstackClient();
        const result = await client.getQuote(text);
        recordSuccess();
        return jsonResponse(result);
      } catch (error) {
        recordFailure("tdx_quote", error);
        return errorResponse(error, 503);
      }
    },

    "/get_key": async (req: Request) => {
      try {
        const url = new URL(req.url);
        const path = url.searchParams.get('path') ?? url.searchParams.get('key') ?? undefined;
        const purpose = url.searchParams.get('purpose') ?? '';
        const algorithm = url.searchParams.get('algorithm') ?? 'secp256k1';
        const client = new DstackClient();
        const result = await client.getKey(path ?? '', purpose, algorithm);
        recordSuccess();
        return jsonResponse({
          key: Buffer.from(result.key).toString('hex'),
          signature_chain: result.signature_chain.map((s) => Buffer.from(s).toString('hex')),
        });
      } catch (error) {
        recordFailure("get_key", error);
        return errorResponse(error, 503);
      }
    },

    "/tls_key": async (req: Request) => {
      try {
        const url = new URL(req.url);
        const subject = url.searchParams.get('subject') ?? '';
        const altNamesParam = url.searchParams.get('alt_names');
        const altNames = altNamesParam ? altNamesParam.split(',').filter(Boolean) : [];
        const usageRaTls = url.searchParams.get('usage_ra_tls') === 'true';
        const usageServerAuth = url.searchParams.get('usage_server_auth') !== 'false';
        const usageClientAuth = url.searchParams.get('usage_client_auth') === 'true';
        const notBefore = url.searchParams.get('not_before');
        const notAfter = url.searchParams.get('not_after');
        const withAppInfo = url.searchParams.get('with_app_info') === 'true';
        const client = new DstackClient();
        const result = await client.getTlsKey({
          subject,
          altNames,
          usageRaTls,
          usageServerAuth,
          usageClientAuth,
          ...(notBefore != null ? { notBefore: Number(notBefore) } : {}),
          ...(notAfter != null ? { notAfter: Number(notAfter) } : {}),
          ...(withAppInfo ? { withAppInfo: true } : {}),
        });
        recordSuccess();
        return jsonResponse(result);
      } catch (error) {
        recordFailure("tls_key", error);
        return errorResponse(error, 503);
      }
    },

    "/attest": async (req: Request) => {
      try {
        const url = new URL(req.url);
        const text = url.searchParams.get('text') || 'hello dstack';
        const client = new DstackClient();
        const result = await client.attest(text);
        recordSuccess();
        return jsonResponse(result);
      } catch (error) {
        recordFailure("attest", error);
        return errorResponse(error, 503);
      }
    },

    "/version": async () => {
      try {
        const client = new DstackClient();
        const result = await client.version();
        recordSuccess();
        return jsonResponse(result);
      } catch (error) {
        recordFailure("version", error);
        return errorResponse(error, 503);
      }
    },

    "/reachable": async () => {
      try {
        const client = new DstackClient();
        const ok = await client.isReachable();
        return jsonResponse({ reachable: ok });
      } catch (error) {
        return errorResponse(error, 503);
      }
    },

    "/emit_event": async (req: Request) => {
      try {
        const url = new URL(req.url);
        const event = url.searchParams.get('event');
        const payload = url.searchParams.get('payload') ?? '';
        if (!event) {
          return jsonResponse({ error: "missing required 'event' query param" }, { status: 400 });
        }
        const client = new DstackClient();
        await client.emitEvent(event, payload);
        recordSuccess();
        return jsonResponse({ ok: true });
      } catch (error) {
        recordFailure("emit_event", error);
        return errorResponse(error, 503);
      }
    },

    "/compose_hash": async (req: Request) => {
      try {
        let compose: AppCompose;
        if (req.method === 'POST') {
          compose = await req.json() as AppCompose;
        } else {
          compose = {
            manifest_version: 2,
            name: 'example',
            runner: 'docker-compose',
            docker_compose_file: 'services:\n  app:\n    image: nginx:latest\n',
          };
        }
        const hash = getComposeHash(compose);
        return jsonResponse({ compose_hash: hash });
      } catch (error) {
        return errorResponse(error, 400);
      }
    },

    "/ethereum": async (req: Request) => {
      try {
        const url = new URL(req.url);
        const key = url.searchParams.get('key') || 'dstack';
        const client = new DstackClient();
        const result = await client.getKey(key);
        const viemAccount = toViemAccountSecure(result);
        recordSuccess();
        return jsonResponse({
          address: viemAccount.address,
        });
      } catch (error) {
        recordFailure("ethereum", error);
        return errorResponse(error, 503);
      }
    },

    "/solana": async (req) => {
      try {
        const url = new URL(req.url);
        const key = url.searchParams.get('key') || 'dstack';
        const client = new DstackClient();
        const result = await client.getKey(key);
        const solanaAccount = toKeypairSecure(result);
        recordSuccess();
        return jsonResponse({
          address: solanaAccount.publicKey.toBase58(),
        });
      } catch (error) {
        recordFailure("solana", error);
        return errorResponse(error, 503);
      }
    },

    "/env": async () => {
      return jsonResponse(process.env);
    },

    "/healthz": async () => {
      try {
        const client = new DstackClient();
        await client.info();
        recordSuccess();
        return jsonResponse({ ok: true });
      } catch (error) {
        recordFailure("healthz", error);
        return errorResponse(error, 503);
      }
    },
  },
});
