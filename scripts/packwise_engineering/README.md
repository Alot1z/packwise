# PackWise engineering toolkit

`packwise_tool.py` is a dependency-free, repository-confined helper for repeatable engineering work. It complements the agent's file tools; it does not replace code review or project-native validation.

## Safety model

- Repository root defaults to the current working directory and can be set with `--root`.
- Relative paths are required and path traversal is rejected.
- `write` refuses to overwrite an existing file unless `--replace` and an exact `--expect-sha256` are supplied.
- `replace` requires an exact expected SHA-256 for the current file and defaults to exactly one replacement.
- `remove` requires `--yes` and an exact expected SHA-256.
- Writes use a temporary file in the destination directory followed by an atomic replace.
- Inventory/search skip dependency and generated build directories by default.
- The validator never starts a dev server and never installs packages.

## Commands

```bash
python3 scripts/packwise_engineering/packwise_tool.py inventory [--json]
python3 scripts/packwise_engineering/packwise_tool.py search PATTERN [--glob '*.swift'] [--regex]
python3 scripts/packwise_engineering/packwise_tool.py read PATH [--max-bytes 200000]
python3 scripts/packwise_engineering/packwise_tool.py write PATH --input FILE [--replace --expect-sha256 HASH]
python3 scripts/packwise_engineering/packwise_tool.py replace PATH --old TEXT --new TEXT --expect-sha256 HASH [--count 1]
python3 scripts/packwise_engineering/packwise_tool.py remove PATH --expect-sha256 HASH --yes
python3 scripts/packwise_engineering/packwise_tool.py validate --all
```

`validate --all` runs available typecheck/build/script/config checks as separate steps and returns nonzero if a required check fails. Convex codegen is intentionally separate because it can contact an external deployment:

```bash
bun convex dev --once
```

The toolkit is intentionally standard-library-only so a fresh engineering session can use it before dependency installation.
