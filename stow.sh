#!/bin/bash
find ./* -maxdepth 0  -type d | xargs -n1 basename | xargs stow "${@}"

# Create symlinks in ~/.claude/skills for each skill in claude/.agents/skills
SKILLS_SRC="$(realpath "$(dirname "$0")")/claude/.agents/skills"
SKILLS_DEST="$HOME/.claude/skills"
mkdir -p "$SKILLS_DEST"
for skill_dir in "$SKILLS_SRC"/*/; do
  skill_name=$(basename "$skill_dir")
  ln -sf "$skill_dir" "$SKILLS_DEST/$skill_name"
done
