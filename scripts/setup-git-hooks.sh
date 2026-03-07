#!/usr/bin/env bash
set -euo pipefail

SCRIPT_DIR="$(cd "$(dirname "$0")" && pwd)"
REPO_ROOT="$(cd "$SCRIPT_DIR/.." && pwd)"

chmod +x "$REPO_ROOT/hooks/git/pre-push"
git -C "$REPO_ROOT" config core.hooksPath hooks/git

echo "Configured git hooks path: hooks/git"
echo "Pre-push checks enabled."
