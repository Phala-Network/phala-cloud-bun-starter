import { TappdClient } from "@phala/dstack-sdk";
import { toKeypairSecure } from '@phala/dstack-sdk/solana';
import { toViemAccountSecure } from '@phala/dstack-sdk/viem';
import { serve } from "bun";

const port = process.env.PORT || 3000;
console.log(`Listening on port ${port}`);

serve({
  port,
  fetch: async (req) => {
    const url = new URL(req.url);
    
    switch (url.pathname) {
      case "/":
      case "/info":
        const client = new TappdClient();
        const result = await client.info();
        return new Response(JSON.stringify(result), {
          headers: {
            'Content-Type': 'application/json',
          },
        });

      case "/tdx_quote":
        const client1 = new TappdClient();
        const result1 = await client1.tdxQuote('test');
        return new Response(JSON.stringify(result1), {
          headers: {
            'Content-Type': 'application/json',
          },
        });

      case "/tdx_quote_raw":
        const client2 = new TappdClient();
        const result2 = await client2.tdxQuote('Hello DStack!', 'raw');
        return new Response(JSON.stringify(result2), {
          headers: {
            'Content-Type': 'application/json',
          },
        });

      case "/derive_key":
        const client3 = new TappdClient();
        const result3 = await client3.deriveKey('test');
        return new Response(JSON.stringify(result3), {
          headers: {
            'Content-Type': 'application/json',
          },
        });

      case "/ethereum":
        const client4 = new TappdClient();
        const result4 = await client4.deriveKey('ethereum');
        const viemAccount = toViemAccountSecure(result4);
        return new Response(JSON.stringify({
          address: viemAccount.address,
        }), {
          headers: {
            'Content-Type': 'application/json',
          },
        });

      case "/solana":
        const client5 = new TappdClient();
        const result5 = await client5.deriveKey('solana');
        const solanaAccount = toKeypairSecure(result5);
        return new Response(JSON.stringify({
          address: solanaAccount.publicKey.toBase58(),
        }), {
          headers: {
            'Content-Type': 'application/json',
          },
        });

      default:
        return new Response("Not Found", { status: 404 });
    }
  },
});
