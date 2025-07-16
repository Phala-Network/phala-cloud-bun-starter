import { TappdClient } from "@phala/dstack-sdk";
import { toKeypairSecure } from '@phala/dstack-sdk/solana';
import { toViemAccountSecure } from '@phala/dstack-sdk/viem';
import { serve } from "bun";

const port = process.env.PORT || 3000;
console.log(`Listening on port ${port}`);

// Route handlers
const routes = {
  "/": async () => {
    const client = new TappdClient();
    const result = await client.info();
    return new Response(JSON.stringify(result), {
      headers: { 'Content-Type': 'application/json' },
    });
  },
  "/info": async () => {
    const client = new TappdClient();
    const result = await client.info();
    return new Response(JSON.stringify(result), {
      headers: { 'Content-Type': 'application/json' },
    });
  },
  "/tdx_quote": async () => {
    const client = new TappdClient();
    const result = await client.tdxQuote('test');
    return new Response(JSON.stringify(result), {
      headers: { 'Content-Type': 'application/json' },
    });
  },
  "/tdx_quote_raw": async () => {
    const client = new TappdClient();
    const result = await client.tdxQuote('Hello DStack!', 'raw');
    return new Response(JSON.stringify(result), {
      headers: { 'Content-Type': 'application/json' },
    });
  },
  "/derive_key": async () => {
    const client = new TappdClient();
    const result = await client.deriveKey('test');
    return new Response(JSON.stringify(result), {
      headers: { 'Content-Type': 'application/json' },
    });
  },
  "/ethereum": async () => {
    const client = new TappdClient();
    const result = await client.deriveKey('ethereum');
    const viemAccount = toViemAccountSecure(result);
    return new Response(JSON.stringify({
      address: viemAccount.address,
    }), {
      headers: { 'Content-Type': 'application/json' },
    });
  },
  "/solana": async () => {
    const client = new TappdClient();
    const result = await client.deriveKey('solana');
    const solanaAccount = toKeypairSecure(result);
    return new Response(JSON.stringify({
      address: solanaAccount.publicKey.toBase58(),
    }), {
      headers: { 'Content-Type': 'application/json' },
    });
  },
} as const;

serve({
  port,
  routes: {
    "/": async () => {
      const client = new TappdClient();
      const result = await client.info();
      return new Response(JSON.stringify(result), {
        headers: { 'Content-Type': 'application/json' },
      });
    },
    "/info": async () => {
      const client = new TappdClient();
      const result = await client.info();
      return new Response(JSON.stringify(result), {
        headers: { 'Content-Type': 'application/json' },
      });
    },
    "/tdx_quote": async () => {
      const client = new TappdClient();
      const result = await client.tdxQuote('test');
      return new Response(JSON.stringify(result), {
        headers: { 'Content-Type': 'application/json' },
      });
    },
    "/tdx_quote_raw": async () => {
      const client = new TappdClient();
      const result = await client.tdxQuote('Hello DStack!', 'raw');
      return new Response(JSON.stringify(result), {
        headers: { 'Content-Type': 'application/json' },
      });
    },
    "/derive_key": async () => {
      const client = new TappdClient();
      const result = await client.deriveKey('test');
      return new Response(JSON.stringify(result), {
        headers: { 'Content-Type': 'application/json' },
      });
    },
    "/ethereum": async () => {
      const client = new TappdClient();
      const result = await client.deriveKey('ethereum');
      const viemAccount = toViemAccountSecure(result);
      return new Response(JSON.stringify({
        address: viemAccount.address,
      }), {
        headers: { 'Content-Type': 'application/json' },
      });
    },
    "/solana": async () => {
      const client = new TappdClient();
      const result = await client.deriveKey('solana');
      const solanaAccount = toKeypairSecure(result);
      return new Response(JSON.stringify({
        address: solanaAccount.publicKey.toBase58(),
      }), {
        headers: { 'Content-Type': 'application/json' },
      });
    },
  },
});
