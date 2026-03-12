#!/usr/bin/env bash
set -euo pipefail

SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"

# Parse --root flag, default to $HOME.
ROOT="$HOME"
while [[ $# -gt 0 ]]; do
    case "$1" in
        --root)
            ROOT="$2"
            shift 2
            ;;
        *)
            echo "Usage: $0 [--root <path>]" >&2
            exit 1
            ;;
    esac
done

# Resolve ROOT to absolute path.
mkdir -p "$ROOT"
ROOT="$(cd "$ROOT" && pwd)"

# When root is HOME, use tilde form for config dir substitution.
# Otherwise use absolute path.
tilde_or_abs() {
    local config_rel="$1"
    if [[ "$ROOT" == "$HOME" ]]; then
        echo "~/$config_rel"
    else
        echo "$ROOT/$config_rel"
    fi
}

# Tool definitions: name, relative config path, skill format (subdir or flat).
#   subdir: skills/<name>/SKILL.md
#   flat:   commands/<name>.md
TOOLS=(
    "claude-code|.claude|subdir"
    "codex|.codex|subdir"
    "opencode|.config/opencode|flat"
    "ai-legacy|.ai|flat"
)

installed=()

for tool_entry in "${TOOLS[@]}"; do
    IFS='|' read -r tool_name config_rel skill_format <<< "$tool_entry"

    config_path="$ROOT/$config_rel"
    config_display="$(tilde_or_abs "$config_rel")"

    # Install skills.
    for skill_dir in "$SCRIPT_DIR"/skills/*/; do
        skill_name="$(basename "$skill_dir")"
        src="$skill_dir/SKILL.md"

        if [[ ! -f "$src" ]]; then
            continue
        fi

        if [[ "$skill_format" == "subdir" ]]; then
            dest_dir="$config_path/skills/$skill_name"
            dest="$dest_dir/SKILL.md"
        else
            dest_dir="$config_path/commands"
            dest="$dest_dir/$skill_name.md"
        fi

        mkdir -p "$dest_dir"
        sed "s|{{CONFIG_DIR}}|$config_display|g" "$src" > "$dest"
    done

    # Install rules.
    rules_dest="$config_path/rules"
    mkdir -p "$rules_dest"
    for rule_file in "$SCRIPT_DIR"/rules/*.md; do
        cp "$rule_file" "$rules_dest/"
    done

    installed+=("$tool_name ($config_display)")
done

echo "Installed skills and rules to:"
for entry in "${installed[@]}"; do
    echo "  - $entry"
done
