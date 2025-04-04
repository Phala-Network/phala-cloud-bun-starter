# Phala Cloud Bun + TypeScript Starter

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

We also need to download the DStack simulator:

```shell
# Mac
wget https://github.com/Leechael/tappd-simulator/releases/download/v0.1.4/tappd-simulator-0.1.4-aarch64-apple-darwin.tgz
tar -xvf tappd-simulator-0.1.4-aarch64-apple-darwin.tgz
cd tappd-simulator-0.1.4-aarch64-apple-darwin
./tappd-simulator -l unix:/tmp/tappd.sock

# Linux
wget https://github.com/Leechael/tappd-simulator/releases/download/v0.1.4/tappd-simulator-0.1.4-x86_64-linux-musl.tgz
tar -xvf tappd-simulator-0.1.4-x86_64-linux-musl.tgz
cd tappd-simulator-0.1.4-x86_64-linux-musl
./tappd-simulator -l unix:/tmp/tappd.sock
```

Once the simulator is running, you need to open another terminal to start your Bun development server:

```shell
bun run dev
```

By default, the Bun development server will listen on port 3000. Open http://127.0.0.1:3000/tdx_quote in your browser to get the quote with reportdata `test`.

This repo also includes code snippets for the following common use cases:

- `/tdx_quote`: The `reportdata` is `test` and generates the quote for attestation report via `tdxQuote` API.
- `/tdx_quote_raw`: The `reportdata` is `Hello DStack!` and generates the quote for attestation report. The difference from `/tdx_quote` is that you can see the raw text `Hello DStack!` in [Attestation Explorer](https://proof.t16z.com/).
- `/derive_key`: Basic example of the `deriveKey` API.
- `/ethereum`: Using the `deriveKey` API to generate a deterministic wallet for Ethereum, a.k.a. a wallet held by the TEE instance.
- `/solana`: Using the `deriveKey` API to generate a deterministic wallet for Solana, a.k.a. a wallet held by the TEE instance.
- `/info`: Returns the TCB Info of the hosted CVM.

## Build

You need to build the image and push it to DockerHub for deployment. The following instructions are for publishing to a public registry via DockerHub:

```shell
sudo docker build . -t leechael/phala-cloud-bun-starter
sudo docker push leechael/phala-cloud-bun-starter
```

## Deploy

You can copy and paste the `docker-compose.yml` file from this repo to deploy to Phala Cloud, follow the [tutorial](https://docs.phala.network/phala-cloud/create-cvm/create-with-docker-compose) in the Phala Docs.
