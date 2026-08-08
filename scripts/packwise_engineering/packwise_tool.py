#!/usr/bin/env python3
"""PackWise repository engineering helper.

This tool is deliberately dependency-free and conservative. It provides
repeatable read/search/validation operations plus guarded, hash-preconditioned
file authoring for deterministic changes. It never starts a development server
or installs dependencies.
"""
from __future__ import annotations

import argparse
import hashlib
import json
import os
import re
import subprocess
import sys
import tempfile
from dataclasses import asdict, dataclass
from pathlib import Path
from typing import Iterable, Sequence

SKIP_DIRS = {
    ".git", ".cache", ".vite", "node_modules", "dist", "build", "coverage",
    "DerivedData", "xcuserdata", ".DS_Store", "__pycache__",
}
TEXT_SUFFIXES = {
    ".c", ".cc", ".cpp", ".h", ".hh", ".hpp", ".js", ".jsx", ".json", ".md",
    ".m", ".mm", ".plist", ".py", ".sh", ".sql", ".swift", ".toml", ".ts",
    ".tsx", ".txt", ".webmanifest", ".xml", ".yaml", ".yml", ".css", ".html",
}


class ToolError(Exception):
    """An expected, user-actionable toolkit error."""


@dataclass(frozen=True)
class FileRecord:
    path: str
    size: int
    sha256: str
    suffix: str


def repository_root(raw: str | None) -> Path:
    root = Path(raw or os.getcwd()).expanduser().resolve()
    if not root.is_dir():
        raise ToolError(f"repository root is not a directory: {root}")
    return root


def safe_path(root: Path, raw: str, *, allow_missing: bool = False) -> Path:
    candidate = Path(raw)
    if candidate.is_absolute():
        raise ToolError("paths must be relative to the repository root")
    resolved = (root / candidate).resolve()
    try:
        resolved.relative_to(root)
    except ValueError as exc:
        raise ToolError(f"path escapes repository root: {raw}") from exc
    if not allow_missing and not resolved.exists():
        raise ToolError(f"path does not exist: {raw}")
    return resolved


def is_skipped(path: Path) -> bool:
    return any(part in SKIP_DIRS for part in path.parts)


def iter_files(root: Path) -> Iterable[Path]:
    for current, dirs, files in os.walk(root):
        dirs[:] = sorted(d for d in dirs if d not in SKIP_DIRS)
        for name in sorted(files):
            path = Path(current) / name
            if not is_skipped(path) and path.is_file():
                yield path


def digest(path: Path) -> str:
    hasher = hashlib.sha256()
    with path.open("rb") as stream:
        for block in iter(lambda: stream.read(1024 * 1024), b""):
            hasher.update(block)
    return hasher.hexdigest()


def rel(root: Path, path: Path) -> str:
    return path.relative_to(root).as_posix()


def cmd_inventory(args: argparse.Namespace) -> int:
    root = repository_root(args.root)
    records = []
    for path in iter_files(root):
        records.append(FileRecord(rel(root, path), path.stat().st_size, digest(path), path.suffix))
    if args.json:
        print(json.dumps([asdict(record) for record in records], indent=2))
    else:
        print("path\tsize\tsha256\tsuffix")
        for record in records:
            print(f"{record.path}\t{record.size}\t{record.sha256}\t{record.suffix}")
        print(f"\n{len(records)} files indexed (excluded: {', '.join(sorted(SKIP_DIRS))})", file=sys.stderr)
    return 0


def cmd_search(args: argparse.Namespace) -> int:
    root = repository_root(args.root)
    matcher = re.compile(args.pattern) if args.regex else None
    seen = 0
    for path in iter_files(root):
        if args.glob and not path.match(args.glob):
            continue
        if path.suffix not in TEXT_SUFFIXES:
            continue
        try:
            text = path.read_text(encoding="utf-8")
        except (UnicodeDecodeError, OSError):
            continue
        for line_number, line in enumerate(text.splitlines(), 1):
            matched = bool(matcher.search(line)) if matcher else args.pattern in line
            if matched:
                print(f"{rel(root, path)}:{line_number}:{line}")
                seen += 1
                if args.max_results and seen >= args.max_results:
                    return 0
    return 0


def cmd_read(args: argparse.Namespace) -> int:
    root = repository_root(args.root)
    path = safe_path(root, args.path)
    if path.is_dir():
        raise ToolError("read accepts files, not directories")
    data = path.read_bytes()
    if len(data) > args.max_bytes:
        raise ToolError(f"refusing to print {len(data)} bytes; max is {args.max_bytes}")
    try:
        sys.stdout.write(data.decode("utf-8"))
    except UnicodeDecodeError as exc:
        raise ToolError("refusing to print a binary file") from exc
    return 0


def expected_digest(path: Path, expected: str | None) -> None:
    if not expected:
        raise ToolError("an exact --expect-sha256 precondition is required for existing files")
    actual = digest(path)
    if actual != expected.lower():
        raise ToolError(f"sha256 precondition failed: expected {expected}, actual {actual}")


def atomic_write(path: Path, data: bytes) -> None:
    path.parent.mkdir(parents=True, exist_ok=True)
    fd, temp_name = tempfile.mkstemp(prefix=f".{path.name}.", dir=str(path.parent))
    try:
        with os.fdopen(fd, "wb") as stream:
            stream.write(data)
            stream.flush()
            os.fsync(stream.fileno())
        os.replace(temp_name, path)
    except Exception:
        try:
            os.unlink(temp_name)
        except FileNotFoundError:
            pass
        raise


def cmd_write(args: argparse.Namespace) -> int:
    root = repository_root(args.root)
    path = safe_path(root, args.path, allow_missing=True)
    if path.exists():
        if not args.replace:
            raise ToolError("refusing to overwrite an existing file; use --replace with --expect-sha256")
        expected_digest(path, args.expect_sha256)
    elif args.expect_sha256:
        raise ToolError("--expect-sha256 cannot be used for a new file")
    source = safe_path(root, args.input)
    data = source.read_bytes()
    atomic_write(path, data)
    print(f"wrote {rel(root, path)} ({len(data)} bytes, sha256 {digest(path)})")
    return 0


def cmd_replace(args: argparse.Namespace) -> int:
    root = repository_root(args.root)
    path = safe_path(root, args.path)
    if path.is_dir():
        raise ToolError("replace accepts files, not directories")
    expected_digest(path, args.expect_sha256)
    text = path.read_text(encoding="utf-8")
    occurrences = text.count(args.old)
    if occurrences != args.count:
        raise ToolError(f"expected {args.count} occurrences, found {occurrences}; file was not changed")
    updated = text.replace(args.old, args.new, args.count)
    atomic_write(path, updated.encode("utf-8"))
    print(f"replaced {args.count} occurrence(s) in {rel(root, path)} (sha256 {digest(path)})")
    return 0


def cmd_remove(args: argparse.Namespace) -> int:
    root = repository_root(args.root)
    path = safe_path(root, args.path)
    if not args.yes:
        raise ToolError("remove requires --yes")
    if path.is_dir():
        raise ToolError("remove only deletes files; remove directories through reviewed platform tooling")
    expected_digest(path, args.expect_sha256)
    path.unlink()
    print(f"removed {rel(root, path)}")
    return 0


def run_step(name: str, command: Sequence[str], root: Path, *, required: bool = True) -> dict[str, object]:
    print(f"== {name}: {' '.join(command)} ==")
    try:
        result = subprocess.run(command, cwd=root, text=True, capture_output=True, check=False)
    except FileNotFoundError:
        message = f"command unavailable: {command[0]}"
        print(message, file=sys.stderr)
        return {"name": name, "command": list(command), "status": "unavailable", "exit": None, "required": required}
    output = (result.stdout + result.stderr).strip()
    if output:
        print(output)
    status = "pass" if result.returncode == 0 else "fail"
    print(f"== {name}: {status} (exit {result.returncode}) ==")
    return {"name": name, "command": list(command), "status": status, "exit": result.returncode, "required": required}


def cmd_validate(args: argparse.Namespace) -> int:
    root = repository_root(args.root)
    results = []
    if args.all or args.typecheck:
        results.append(run_step("TypeScript", ["bun", "tsc", "-b", "--noEmit"], root))
    if args.all or args.build:
        results.append(run_step("Web build", ["bun", "run", "build"], root))
    if args.all or args.scripts:
        scripts = [root / "ios" / "build.sh"] + sorted((root / "scripts").glob("*.sh"))
        for path in scripts:
            if path.exists():
                results.append(run_step(f"Shell syntax {rel(root, path)}", ["bash", "-n", rel(root, path)], root))
    if args.all or args.config:
        for raw in ("package.json", "convex.json", "vercel.json"):
            path = root / raw
            if path.exists():
                try:
                    json.loads(path.read_text(encoding="utf-8"))
                    print(f"== JSON {raw}: pass ==")
                    results.append({"name": f"JSON {raw}", "status": "pass", "exit": 0, "required": True})
                except json.JSONDecodeError as exc:
                    print(f"== JSON {raw}: fail: {exc} ==")
                    results.append({"name": f"JSON {raw}", "status": "fail", "exit": 1, "required": True})
        yaml_files = [
            root / ".github" / "workflows" / "ios.yml",
            root / ".github" / "workflows" / "wiki.yml",
            root / "ios" / "project.yml",
        ]
        yaml_files = [path for path in yaml_files if path.exists()]
        if yaml_files:
            script = "import('js-yaml').then(async y=>{const fs=await import('node:fs');for(const f of process.argv.slice(1)){y.load(fs.readFileSync(f,'utf8'));console.log(f+': valid')}}).catch(e=>{console.error(e.message);process.exit(2)})"
            results.append(run_step("Workflow YAML", ["node", "--input-type=module", "-e", script, *[rel(root, p) for p in yaml_files]], root, required=False))
    if not results:
        raise ToolError("select at least one validation group: --all, --typecheck, --build, --scripts, or --config")
    failed = [r for r in results if r.get("required") and r.get("status") == "fail"]
    print(json.dumps({"results": results, "required_failures": len(failed)}, indent=2))
    return 1 if failed else 0


def parser() -> argparse.ArgumentParser:
    common = argparse.ArgumentParser(add_help=False)
    common.add_argument("--root", help="repository root (defaults to cwd)")
    root = argparse.ArgumentParser(prog="packwise_tool.py", description=__doc__)
    sub = root.add_subparsers(dest="command", required=True)
    inventory = sub.add_parser("inventory", parents=[common])
    inventory.add_argument("--json", action="store_true")
    inventory.set_defaults(func=cmd_inventory)
    search = sub.add_parser("search", parents=[common])
    search.add_argument("pattern")
    search.add_argument("--glob")
    search.add_argument("--regex", action="store_true")
    search.add_argument("--max-results", type=int, default=0)
    search.set_defaults(func=cmd_search)
    read = sub.add_parser("read", parents=[common])
    read.add_argument("path")
    read.add_argument("--max-bytes", type=int, default=200_000)
    read.set_defaults(func=cmd_read)
    write = sub.add_parser("write", parents=[common])
    write.add_argument("path")
    write.add_argument("--input", required=True)
    write.add_argument("--replace", action="store_true")
    write.add_argument("--expect-sha256")
    write.set_defaults(func=cmd_write)
    replace = sub.add_parser("replace", parents=[common])
    replace.add_argument("path")
    replace.add_argument("--old", required=True)
    replace.add_argument("--new", required=True)
    replace.add_argument("--expect-sha256", required=True)
    replace.add_argument("--count", type=int, default=1)
    replace.set_defaults(func=cmd_replace)
    remove = sub.add_parser("remove", parents=[common])
    remove.add_argument("path")
    remove.add_argument("--expect-sha256", required=True)
    remove.add_argument("--yes", action="store_true")
    remove.set_defaults(func=cmd_remove)
    validate = sub.add_parser("validate", parents=[common])
    validate.add_argument("--all", action="store_true")
    validate.add_argument("--typecheck", action="store_true")
    validate.add_argument("--build", action="store_true")
    validate.add_argument("--scripts", action="store_true")
    validate.add_argument("--config", action="store_true")
    validate.set_defaults(func=cmd_validate)
    return root


def main(argv: Sequence[str] | None = None) -> int:
    try:
        args = parser().parse_args(argv)
        return int(args.func(args))
    except ToolError as exc:
        print(f"packwise-tool: error: {exc}", file=sys.stderr)
        return 2
    except KeyboardInterrupt:
        print("packwise-tool: interrupted", file=sys.stderr)
        return 130


if __name__ == "__main__":
    raise SystemExit(main())
