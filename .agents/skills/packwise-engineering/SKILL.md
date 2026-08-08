# packwise-engineering

## Purpose

This is the project-local engineering procedure for PackWise. It is an implementation skill, not an audit-only or report-only procedure. It owns the repository state that can be changed or validated from the current environment and stops only at a genuine external boundary.

## Authority and boundaries

- The repository is the source of truth; historical reports are context only.
- Inspect current files, configuration, callers, tests, and scripts before editing.
- Use Ix when its CLI and graph backend are actually available. Ix improves architecture and impact analysis; it is never a prerequisite for editing, testing, or building PackWise.
- Use the guarded toolkit in `scripts/packwise_engineering/packwise_tool.py` for repeatable inventory, search, reads, writes, replacements, removals, and validation.
- Do not invent FreeBuff registries, MCP configuration, Ix commands, CI results, IPA artifacts, or production state.
- Do not edit `.env` files or generated Convex files by hand.
- Do not start or stop managed development servers from the agent. Do not install packages or mutate source through ad-hoc shell redirection.
- Do not suppress diagnostics, weaken tests, disable build steps, or use `continue-on-error` to hide compiler/build failures.

## State machine

```text
DISCOVER → INVENTORY → UNDERSTAND → CLASSIFY GAPS → PLAN
→ IMPLEMENT → VALIDATE → REPAIR → REVALIDATE
→ RELEASE/DEPLOY PREP → EXTERNAL HANDOFF → EVIDENCE
```

Never use `DISCOVER → REPORT → WAIT` while useful local work remains.

## Required execution procedure

### 1. Fresh environment and repository probe

Verify, rather than assume:

- OS, architecture, Node, Bun, npm, Python, Git, ripgrep, shell, writable paths;
- Xcode/macOS availability;
- Docker, Compose, socket, alternate runtimes, and Ix CLI/backend;
- project root, package manifests, Vite, Convex, iOS project/build/release files;
- skill, tool, MCP, and session configuration surfaces.

Record external blockers once with the exact missing capability. Do not loop on unchanged blockers.

### 2. Inventory and architecture

Run a complete repository inventory. Exclude dependency/build output from source analysis, but inspect deployment artifacts and tracked generated files deliberately. Cover:

- iOS app, models, services, views, tests, project generation, scripts, release/IPA gates;
- web entrypoint, routes, components, hooks, Convex clients, error handling, assets, Vite, deployment;
- Convex schema/functions/auth and generated-code boundaries;
- workflows, Gitea mirrors, package/lock/config files, docs, tooling, and stale copies.

Search for TODO/FIXME/stub/placeholder/unsafe suppression/old API/old hash/debug output, then classify each match as intentional, harmless documentation, or a defect.

### 3. Ix integration (conditional)

Verify the installed CLI with its current `--version`, `--help`, `status`, and `doctor` commands. If the documented backend is healthy, register/map PackWise and use only commands exposed by that installed version (`map`, `overview`, `search`, `locate`, `read`, `explain`, `trace`, `impact`, `smells`, `inventory`, `subsystems`, `rank`, `history`, `diff`). Cross-check graph findings against source. If Docker/Compose or a remote Ix backend is unavailable, mark graph analysis unavailable and continue with filesystem/search/compiler evidence.

### 4. Impact-first implementation

For every real defect:

1. identify the source of truth and affected callers;
2. preserve public contracts unless the requirement changes them;
3. make the smallest coherent multi-file change;
4. update tests/docs/configuration that are genuinely affected;
5. run focused validation immediately;
6. repair failures and re-run the failed gate.

Do not make cosmetic refactors or speculative product changes. Do not create isolated dead files.

### 5. PackWise invariants

- iOS deployment target remains 17.0 unless explicitly changed by a separate requirement.
- iOS 18-only `.searchActions` stays exclusively inside an appropriate `@available(iOS 18.0, *)` implementation; callers use the PackWise `searchClearAction` abstraction.
- Web `Landing` import/chunk behavior must match current source. Fresh `dist/` must reference files that exist and contain no obsolete `CIOKFVVM` artifact unless current build evidence proves it valid.
- Convex functions use source files plus generated types; never hand-edit `src/convex/_generated/*`.
- IPA claims require an actual artifact plus `scripts/verify-ipa.sh` output.
- Deployment claims require live HTTP evidence; a local build is not production verification.

### 6. Validation matrix

Use the project's native commands where available:

```text
python3 scripts/packwise_engineering/packwise_tool.py validate --all
bun tsc -b --noEmit
bun run build
bash -n ios/build.sh scripts/*.sh
bun convex dev --once                 # only when Convex sources changed
```

Also perform:

- index.html → asset existence checks;
- stale-hash and stale-copy sweeps;
- Swift availability/deployment-target/caller sweeps;
- workflow/config parsing where parsers are available;
- iOS source/static validation on Linux, never a fabricated Xcode result.

### 7. External boundaries and evidence

Separate these states:

- implemented vs locally validated;
- CI-ready vs CI-passed;
- IPA build prepared vs IPA generated vs IPA verified;
- deployment-ready vs deployed vs production verified;
- Ix CLI installed vs backend operational vs graph mapped vs session-integrated.

For every claim record `CLAIM → FILE/COMMAND → OBSERVATION → RESULT`. A final classification may be `IMPLEMENTATION COMPLETE / CI PENDING`, `IMPLEMENTATION COMPLETE / IPA PENDING`, `DEPLOYMENT READY`, `COMPLETE WITH EXTERNAL PENDING`, or `COMPLETE` only when the evidence supports it.

## Guarded toolkit quick reference

All commands operate from the repository root unless `--root` is supplied. Paths are confined to the repository. Writes/replacements/removals require explicit preconditions.

```bash
python3 scripts/packwise_engineering/packwise_tool.py inventory
python3 scripts/packwise_engineering/packwise_tool.py search 'CIOKFVVM' --glob '*.js'
python3 scripts/packwise_engineering/packwise_tool.py read src/main.tsx
python3 scripts/packwise_engineering/packwise_tool.py write path/to/new-file --input file.txt
python3 scripts/packwise_engineering/packwise_tool.py replace path/to/file --old 'old text' --new 'new text' --expect-sha256 HASH
python3 scripts/packwise_engineering/packwise_tool.py remove path/to/file --expect-sha256 HASH --yes
python3 scripts/packwise_engineering/packwise_tool.py validate --all
```

The toolkit refuses ambiguous writes, refuses path traversal, writes atomically, and reports command exit status. Prefer the platform file-editing tools for complex edits; use the toolkit for deterministic, reviewable operations.

## Final report contract

Report only work actually performed:

1. fresh environment and Ix state;
2. files created/modified/removed;
3. defects found, evidence, fix, and validation;
4. validation command/exit/result ledger;
5. CI/iOS/IPA/deployment/sync boundaries;
6. exact next external action, if any.
