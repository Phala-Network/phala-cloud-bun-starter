import { serve } from "bun";
import { DstackClient } from "@phala/dstack-sdk";
import { toViemAccount } from '@phala/dstack-sdk/viem';
import { toKeypair } from '@phala/dstack-sdk/solana';

const port = process.env.PORT || 3000;
console.log(`Listening on port ${port}`);
serve({
  port,

  routes: {
    "/": async (req) => {
      const client = new DstackClient();
      const result = await client.info();
      return new Response(JSON.stringify(result), {
        headers: {
          'Content-Type': 'application/json',
        },
      });
    },

    "/get_quote": async (req) => {
      const client = new DstackClient();
      const result = await client.getQuote('test');
      return new Response(JSON.stringify(result));
    },

    "/get_key": async (req) => {
      const client = new DstackClient();
      const result = await client.getKey('test');
      return new Response(JSON.stringify(result));
    },

    "/ethereum": async (req) => {
      const client = new DstackClient();
      const result = await client.getKey('ethereum');
      const viemAccount = toViemAccount(result);
      return new Response(JSON.stringify({
        address: viemAccount.address,
      }));
    },

    "/solana": async (req) => {
      const client = new DstackClient();
      const result = await client.getKey('solana');
      const solanaAccount = toKeypair(result);
      return new Response(JSON.stringify({
        address: solanaAccount.publicKey.toBase58(),
      }));
    },
  },
});