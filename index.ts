import { serve } from "bun";
import { TappdClient } from "@phala/dstack-sdk";
import { toViemAccount } from '@phala/dstack-sdk/viem';
import { toKeypair } from '@phala/dstack-sdk/solana';

const port = process.env.PORT || 3000;
console.log(`Listening on port ${port}`);
serve({
  port,

  routes: {
    "/": new Response("Hello DStack!"),

    "/tdx_quote": async (req) => {
      const client = new TappdClient();
      const result = await client.tdxQuote('test');
      return new Response(JSON.stringify(result));
    },

    "/tdx_quote_raw": async (req) => {
      const client = new TappdClient();
      const result = await client.tdxQuote('Hello DStack!', 'raw');
      return new Response(JSON.stringify(result));
    },

    "/derive_key": async (req) => {
      const client = new TappdClient();
      const result = await client.deriveKey('test');
      return new Response(JSON.stringify(result));
    },

    "/ethereum": async (req) => {
      const client = new TappdClient();
      const result = await client.deriveKey('ethereum');
      const viemAccount = toViemAccount(result);
      return new Response(JSON.stringify({
        address: viemAccount.address,
      }));
    },

    "/solana": async (req) => {
      const client = new TappdClient();
      const result = await client.deriveKey('solana');
      const solanaAccount = toKeypair(result);
      return new Response(JSON.stringify({
        address: solanaAccount.publicKey.toBase58(),
      }));
    },

    "/info": async (req) => {
      const client = new TappdClient();
      const result = await client.info();
      result.tcb_info = JSON.parse(result.tcb_info);
      return new Response(JSON.stringify(result), {
        headers: {
          'Content-Type': 'application/json',
        },
      });
    },
  },
});