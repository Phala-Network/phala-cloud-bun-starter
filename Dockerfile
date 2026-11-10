FROM oven/bun:1.4.4
WORKDIR /usr/src/app

COPY . .
RUN bun install --frozen-lockfile --production

EXPOSE 3000/tcp
ENTRYPOINT [ "bun", "run", "index.ts" ]
