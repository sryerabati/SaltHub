# SaltHub

SaltHub is a single-file Roblox Lua automation hub for **Defend ur base with anime**.

## Files

- `salthub.lua` - main Lua script.
- `scripts/serve-salthub.mjs` - local HTTP helper for loading the script during development.
- `tests/` - Node test coverage for script structure and feature contracts.

## Local Development

Run the tests:

```powershell
npm test
```

Serve the script locally:

```powershell
npm run serve
```

The local script URL is:

```text
http://127.0.0.1:16500/salthub.lua
```
