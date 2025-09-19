import { serve } from "bun";
import { DstackClient } from "@phala/dstack-sdk";
import { toViemAccountSecure } from '@phala/dstack-sdk/viem';
import { toKeypairSecure } from '@phala/dstack-sdk/solana';

const port = process.env.PORT || 3000;
console.log(`Listening on port ${port}`);
serve({
  port,

  routes: {
    "/": async () => {
      const client = new DstackClient();
      const result = await client.info();
      return new Response(JSON.stringify(result), {
        headers: {
          'Content-Type': 'application/json',
        },
      });
    },

    "/get_quote": async (req: Request) => {
      const url = new URL(req.url);
      const text = url.searchParams.get('text') || 'hello dstack';
      const client = new DstackClient();
      const result = await client.getQuote(text);
      return new Response(JSON.stringify(result));
    },

    "/get_key": async (req: Request) => {
      const url = new URL(req.url);
      const key = url.searchParams.get('key') || 'dstack';
      const client = new DstackClient();
      const result = await client.getKey(key);
      return new Response(JSON.stringify(result));
    },

    "/ethereum": async (req: Request) => {
      const url = new URL(req.url);
      const key = url.searchParams.get('key') || 'dstack';
      const client = new DstackClient();
      const result = await client.getKey(key);
      const viemAccount = toViemAccountSecure(result);
      return new Response(JSON.stringify({
        address: viemAccount.address,
      }));
    },

    "/solana": async (req) => {
      const url = new URL(req.url);
      const key = url.searchParams.get('key') || 'dstack';
      const client = new DstackClient();
      const result = await client.getKey(key);
      const solanaAccount = toKeypairSecure(result);
      return new Response(JSON.stringify({
        address: solanaAccount.publicKey.toBase58(),
      }));
    },

    "/env": async () => {
      return new Response(JSON.stringify(process.env), {
        headers: {
          'Content-Type': 'application/json',
        },
      });
    },
  },
});