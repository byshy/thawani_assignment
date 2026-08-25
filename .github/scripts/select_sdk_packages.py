#!/usr/bin/env python3
"""Select SDK packages whose files changed for the current GitHub event."""

from __future__ import annotations

import json
import os
import subprocess
from pathlib import Path


def git(*args: str) -> str:
    return subprocess.check_output(["git", *args], text=True)


def is_absent_sha(sha: str) -> bool:
    return not sha or set(sha) <= {"0"}


def discover_sdk_packages() -> list[str]:
    packages = sorted(p.parent.name for p in Path("sdk").glob("*/pubspec.yaml"))
    if not packages:
        raise SystemExit("No SDK packages found under sdk/*/pubspec.yaml")
    return packages


def changed_files(base: str, head: str) -> list[str]:
    def diff() -> list[str]:
        return [
            path
            for path in git("diff", "--name-only", "-z", base, head).split("\0")
            if path
        ]

    try:
        return diff()
    except subprocess.CalledProcessError:
        git("fetch", "--no-tags", "origin", base)
        return diff()


def select_packages(
    packages: list[str],
    *,
    event: str,
    head: str,
    before: str,
    pr_base: str,
) -> list[str]:
    run_all = event == "workflow_dispatch" or (
        event == "push" and is_absent_sha(before)
    )
    changed: list[str] = []

    if not run_all:
        base = pr_base if event == "pull_request" else before
        if is_absent_sha(base):
            run_all = True
        else:
            changed = changed_files(base, head)
            if any(path.startswith(".github/") for path in changed):
                run_all = True

    if run_all:
        return packages

    return [
        name
        for name in packages
        if any(path.startswith(f"sdk/{name}/") for path in changed)
    ]


def write_outputs(selected: list[str]) -> None:
    output_path = os.environ.get("GITHUB_OUTPUT")
    if output_path:
        with open(output_path, "a", encoding="utf-8") as fh:
            fh.write(f"packages={json.dumps(selected)}\n")
            fh.write(f"any={'true' if selected else 'false'}\n")

    summary = os.environ.get("GITHUB_STEP_SUMMARY")
    if summary:
        with open(summary, "a", encoding="utf-8") as fh:
            fh.write("## SDK packages selected\n\n")
            if selected:
                fh.writelines(f"- `{name}`\n" for name in selected)
            else:
                fh.write("None — no SDK or workflow files changed.\n")

    print("Selected SDK packages:", ", ".join(selected) if selected else "(none)")


def main() -> None:
    selected = select_packages(
        discover_sdk_packages(),
        event=os.environ.get("EVENT_NAME", ""),
        head=os.environ.get("HEAD_SHA") or "HEAD",
        before=os.environ.get("EVENT_BEFORE") or "",
        pr_base=os.environ.get("PR_BASE_SHA") or "",
    )
    write_outputs(selected)


if __name__ == "__main__":
    main()
