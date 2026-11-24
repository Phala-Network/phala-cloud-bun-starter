# Phala Cloud Bun + TypeScript Starter

[![](https://cloud.phala.network/deploy-button.svg)](https://cloud.phala.network/templates/bun-starter)

This is a template for developing a [Bun](https://bun.sh/)-based app with boilerplate code targeting deployment on [Phala Cloud](https://cloud.phala.network/) and [DStack](https://github.com/dstack-TEE/dstack/). It includes the SDK by default to make integration with TEE features easier. This repo also includes a default Dockerfile and docker-compose.yml for deployment.

## Development

First, you need to clone this repo:

```shell
git clone --depth 1 https://github.com/Phala-Network/phala-cloud-bun-starter.git
```

Next, let's initialize the development environment:

```shell
bun i
cp env.example .env
```

This starter demonstrates the dstack guest API v1 (`DstackClient` from `@phala/dstack-sdk` 0.6.0). v1 needs dstack OS >= 0.6.0 (guest agent >= 0.6.0). The legacy v0 API (`DstackClientV0`) is kept for apps that must keep their existing keys. Local development needs a running dstack guest-agent simulator (Linux). See [sdk/simulator](https://github.com/Dstack-TEE/dstack/tree/next/sdk/simulator).

Point the SDK at it with `DSTACK_SIMULATOR_ENDPOINT` — a unix socket path, or an `http://` / `https://` URL (both clients accept either). Set it in `.env` (see `env.example`) or export it:

```shell
export DSTACK_SIMULATOR_ENDPOINT=/path/to/dstack.sock
# or: export DSTACK_SIMULATOR_ENDPOINT=http://127.0.0.1:8090
```

Then start the Bun development server:

```shell
bun run dev
```

By default, the Bun development server will listen on port 3000. Open http://127.0.0.1:3000/v1/attest in your browser to get an attestation.

`/v1/attest` never puts caller input into TDX `report_data` raw.
It hashes it as `sha512("app-data:" || utf8(text))` (the dstack `AppData` tag),
so the attestation cannot be reused as an RA-TLS client certificate. The JSON
response includes `user_input`, `report_data_hex`, and `report_data_derivation`
so a verifier can recompute the digest. Pass `?text=` to choose the input;
default is `hello dstack`. v1 `attest` takes 1 to 64 bytes, never a string.

This repo also includes code snippets for the following common use cases (v1):

- `/v1/info` and `/v1/version`: `info()` and `version()` on `DstackClient`.
- `/v1/key?domain=&algorithm=`: `getKey` on `DstackClient`. `algorithm` is required (`secp256k1` or `ed25519`).
- `/v1/attest`: `attest` on `DstackClient`.
- `/v1/tls_key`: `issueCert` on `DstackClient`.
- `/v1/ethereum`: secp256k1 `getKey` bytes into viem `privateKeyToAccount`.
- `/v1/solana`: ed25519 `getKey` bytes (32-byte seed) into `Keypair.fromSeed`.

Do not hold assets in a wallet derived from `getKey`: the key is a function of the KMS root, so these wallets suit demos and low-value or rotatable signing only. See the [dstack SDK warning](https://github.com/Dstack-TEE/dstack/blob/next/sdk/js/README.md#blockchain-helpers).

`/` lists all routes.

## Legacy v0 routes

The routes without a `/v1/` prefix use the deprecated v0 API (`DstackClientV0`) and work on every dstack OS version, including GPU images that are still on dstack 0.5.15.

> **v0 and v1 derive different keys.** The same key name yields different key material on the two APIs, and there is no migration path. If your app already published v0-derived keys or addresses, keep using v0.

- `/info`, `/version`, `/get_quote`, `/tdx_quote`, `/attest`, `/tls_key`, `/emit_event`
- `/get_key`: `getKey` with `path`, `purpose`, `algorithm`.
- `/ethereum` and `/solana`: wallets from `getKey` plus `toViemAccountSecure` / `toKeypairSecure`.

## Build

You need to build the image and push it to DockerHub for deployment. The following instructions are for publishing to a public registry via DockerHub:

```shell
sudo docker build . -t leechael/phala-cloud-bun-starter
sudo docker push leechael/phala-cloud-bun-starter
```

## Deploy

You can copy and paste the `docker-compose.yml` file from this repo to deploy to Phala Cloud, follow the [tutorial](https://docs.phala.network/phala-cloud/create-cvm/create-with-docker-compose) in the Phala Docs.
