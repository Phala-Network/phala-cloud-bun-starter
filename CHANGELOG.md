## v1.3.0 (2026-11-24)

- Merge pull request #12 from Phala-Network/feat/dstack-v1-examples (bf3f5b8)
- docs: warn against holding assets in getKey-derived wallets (0a82834)
- feat: add dstack guest API v1 examples and mark v0 as legacy (0a7c69d)
- Merge pull request #11 from Phala-Network/chore/dstack-sdk-0.6 (4ee0054)
- docs: describe the simulator without build steps (0396098)
- chore: drop the stale tappd-simulator gitignore entry (6addf2a)
- docs: switch to the dstack simulator and dstack sdk 0.6 (0217de3)
- fix(compose): mount dstack.sock instead of tappd.sock (0d4a220)
- chore(deps): bump dstack sdk to 0.6 and pin the v0 client (87cef48)
- Merge pull request #10 from Phala-Network/chore/gha-node24-ubuntu2404 (03af59a)
- ci: bump GitHub Actions to Node 24 runtimes (fd6116f)
- chore(release): update docker-compose.yml and CHANGELOG.md for v1.2.0 (77c34bd)

## Unreleased

- feat: add dstack guest API v1 routes under `/v1/` (info, version, key, attest, tls_key, ethereum, solana); needs dstack OS >= 0.6.0
- feat: `/` now lists v1 routes first and marks the v0 routes as legacy
- refactor: move the v0 info route from `/` to `/info`; all other v0 routes are unchanged

## v1.2.0 (2026-11-10)

- Merge pull request #9 from Phala-Network/fix/hash-quote-report-data (a2cc45e)
- fix: hash quote report_data under the app-data tag (d2bc46f)
- Merge pull request #8 from Phala-Network/chore/update-bun-and-deps (e20f581)
- chore(deps): bump packages and pin bun 1.4.4 (811ed4e)
- chore(release): update docker-compose.yml and CHANGELOG.md for v1.1.4 (e18421e)

## v1.1.4 (2026-06-02)

- chore(release): update docker-compose.yml and CHANGELOG.md for v1.1.3 (f5edb82)

# Changelog

## v1.1.3 (2026-06-02)

- chore(deps): update @phala/dstack-sdk to 0.5.8 (1d6cdb4)
- ci: align release and ghcr workflows with phala-cloud-nextjs-starter (63d762a)
- feat: expose new 0.5.8 SDK APIs (0364cf1)
- chore(deps): bump @phala/dstack-sdk to 0.5.8-beta.2 (ecb8c0f)
