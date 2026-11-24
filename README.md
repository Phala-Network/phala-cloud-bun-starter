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

This starter uses the frozen v0 guest API (`DstackClientV0` from `@phala/dstack-sdk` 0.6.0). There is no published `simulator-v*` GitHub release; build the simulator from source at tag `js-sdk-v0.6.0` of [dstack](https://github.com/Dstack-TEE/dstack). Its `dstack.sock` serves both v0 routes (`/GetKey`, `/Info`, …) and `/v1/…`.

Prerequisites: Rust 1.92 and Cargo ([rustup](https://rustup.rs/)).

```shell
git clone --depth 1 --branch js-sdk-v0.6.0 https://github.com/Dstack-TEE/dstack.git
cd dstack/sdk/simulator
./build.sh
./dstack-simulator
```

The process creates `dstack.sock` in that directory. In another terminal, set the absolute path in `.env` (see `env.example`) or export it:

```shell
export DSTACK_SIMULATOR_ENDPOINT=/absolute/path/to/dstack/sdk/simulator/dstack.sock
```

Then start the Bun development server:

```shell
bun run dev
```

By default, the Bun development server will listen on port 3000. Open http://127.0.0.1:3000/tdx_quote in your browser to get a quote.

`/get_quote` and `/tdx_quote` never put caller input into TDX `report_data` raw.
They hash it as `sha512("app-data:" || utf8(text))` (the dstack `AppData` tag),
so the quote cannot be reused as an RA-TLS client certificate. The JSON response
includes `user_input`, `report_data_hex`, and `report_data_derivation` so a
verifier can recompute the digest. Pass `?text=` to choose the input; default is
`hello dstack`.

This repo also includes code snippets for the following common use cases:

- `/get_quote` and `/tdx_quote`: `getQuote` on `DstackClientV0`.
- `/get_key`: `getKey` on `DstackClientV0`.
- `/ethereum` and `/solana`: deterministic wallets from `getKey` plus `toViemAccountSecure` / `toKeypairSecure`.
- `/`: `info()` on `DstackClientV0`.

## Build

You need to build the image and push it to DockerHub for deployment. The following instructions are for publishing to a public registry via DockerHub:

```shell
sudo docker build . -t leechael/phala-cloud-bun-starter
sudo docker push leechael/phala-cloud-bun-starter
```

## Deploy

You can copy and paste the `docker-compose.yml` file from this repo to deploy to Phala Cloud, follow the [tutorial](https://docs.phala.network/phala-cloud/create-cvm/create-with-docker-compose) in the Phala Docs.
