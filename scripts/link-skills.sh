#!/usr/bin/env bash
set -euo pipefail

# Dev-only helper for maintainers of this repo. Not a supported installer —
# end users install via the Claude Code plugin or by copying a skill folder.
#
# Symlinks every skill in skills/ into each harness's skill directory, so one
# `git pull` updates all of them. Re-run after adding, renaming or removing a
# skill. See .agents/harnesses.md for where these paths come from.

REPO="$(cd "$(dirname "$0")/.." && pwd)"

DESTS=(
  "$HOME/.claude/skills"        # Claude Code
  "$HOME/.agents/skills"        # Codex, and other Agent Skills harnesses
  "$HOME/.gemini/config/skills" # Antigravity, Gemini CLI
  "$REPO/.agents/skills"        # this repo, for agents working inside it
)

# Collect the repo's skills once, then link them into every destination.
names=()
srcs=()
while IFS= read -r -d '' skill_md; do
  src="$(dirname "$skill_md")"
  names+=("$(basename "$src")")
  srcs+=("$src")
done < <(find "$REPO/skills" -name SKILL.md -print0)

if [ ${#names[@]} -eq 0 ]; then
  echo "no skills found under $REPO/skills — nothing to link" >&2
  exit 0
fi

for DEST in "${DESTS[@]}"; do
  # A destination that is itself a symlink into this repo would make us write the
  # per-skill symlinks back into the working copy. Bail rather than pollute it.
  if [ -L "$DEST" ]; then
    resolved="$(cd "$DEST" 2>/dev/null && pwd -P)" || resolved=""
    case "$resolved" in
      "$REPO" | "$REPO"/*)
        echo "error: $DEST is a symlink into this repo ($resolved)." >&2
        echo "Remove it (rm \"$DEST\") and re-run; it will be recreated as a real dir." >&2
        exit 1
        ;;
    esac
  fi

  mkdir -p "$DEST"

  for i in "${!names[@]}"; do
    target="$DEST/${names[$i]}"

    # Replace a real directory left by a manual copy; leave nothing else behind.
    if [ -e "$target" ] && [ ! -L "$target" ]; then
      rm -rf "$target"
    fi

    ln -sfn "${srcs[$i]}" "$target"
    echo "linked ${names[$i]} -> $DEST"
  done
done
