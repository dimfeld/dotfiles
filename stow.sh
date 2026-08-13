#!/bin/bash
find ./* -maxdepth 0  -type d | xargs -n1 basename | xargs stow -v "${@}"

# Create symlinks in ~/.claude/skills for each skill in claude/.agents/skills
SKILLS_SRC="$(realpath "$(dirname "$0")")/claude/.agents/skills"
SKILLS_DEST="$HOME/.claude/skills"
mkdir -p "$SKILLS_DEST"
for skill_dir in "$SKILLS_SRC"/*/; do
  ln -sf "$skill_dir" "$SKILLS_DEST"
done
