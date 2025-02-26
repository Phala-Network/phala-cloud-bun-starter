FROM oven/bun:latest
WORKDIR /usr/src/app

COPY . .
RUN which bun
RUN bun install --frozen-lockfile --production

EXPOSE 3000/tcp
ENTRYPOINT [ "bun", "run", "index.ts" ]