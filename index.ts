import { serve } from "bun";
import { DstackClient } from "@phala/dstack-sdk";
import { toViemAccountSecure } from '@phala/dstack-sdk/viem';
import { toKeypairSecure } from '@phala/dstack-sdk/solana';

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
        const key = url.searchParams.get('key') || 'dstack';
        const client = new DstackClient();
        const result = await client.getKey(key);
        recordSuccess();
        return jsonResponse(result);
      } catch (error) {
        recordFailure("get_key", error);
        return errorResponse(error, 503);
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
