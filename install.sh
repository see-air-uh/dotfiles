#!/usr/bin/env bash
set -euo pipefail

REPO="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
ALL_PACKAGES=(zsh nvim tmux ghostty starship opencode zed gh)
BACKUP="$HOME/.dotfiles-backup/$(date +%Y%m%d-%H%M%S)"
CONFIG="${INSTALL_CONFIG:-$REPO/install.config}"

usage() {
  cat <<'EOF'
Usage: ./install.sh [--help]

Installs Homebrew packages from Brewfile, then symlinks every package into $HOME
with GNU stow. Existing files are moved to ~/.dotfiles-backup/<timestamp>/ first.

Environment:
  SKIP_BREW=1         Skip "brew bundle" and only create the symlinks.
  INSTALL_CONFIG=...  Use a different config file than ./install.config.

Configuration:
  Copy install.config.example to install.config (untracked) and edit the
  checkboxes. Checked boxes are skipped; everything else is installed. Without
  install.config, everything is installed. stow is always installed.
EOF
}

# Map a Brewfile formula/cask name to the checkbox id used in install.config.
brew_id() {
  case "$1" in
    neovim) echo nvim ;;
    opencode-v2) echo opencode ;;
    *) echo "$1" ;;
  esac
}

SKIPPED=" "

load_config() {
  [[ -f "$CONFIG" ]] || return 0
  local line id mark
  local re='^[[:space:]]*\[([ xX])\][[:space:]]+([^[:space:]#]+)'
  while IFS= read -r line || [[ -n "$line" ]]; do
    [[ "$line" =~ $re ]] || continue
    mark="${BASH_REMATCH[1]}"
    id="${BASH_REMATCH[2]}"
    [[ "$mark" == "x" || "$mark" == "X" ]] || continue
    [[ "$id" == "stow" ]] && continue
    SKIPPED+="$id "
  done < "$CONFIG"
}

is_selected() {
  [[ "$SKIPPED" != *" $1 "* ]]
}

if [[ "${1:-}" == "--help" || "${1:-}" == "-h" ]]; then
  usage
  exit 0
fi

load_config
if [[ -f "$CONFIG" ]]; then
  echo "==> Using $CONFIG (skipping:${SKIPPED% })"
fi

PACKAGES=()
for pkg in "${ALL_PACKAGES[@]}"; do
  if is_selected "$pkg"; then
    PACKAGES+=("$pkg")
  fi
done

if ! command -v brew >/dev/null 2>&1; then
  echo "Homebrew is required: https://brew.sh" >&2
  exit 1
fi

if [[ "${SKIP_BREW:-0}" != "1" ]]; then
  echo "==> Installing packages from Brewfile"
  if [[ "$SKIPPED" == " " ]]; then
    brew bundle --file="$REPO/Brewfile"
  else
    FILTERED_BREWFILE="$(mktemp)"
    trap 'rm -f "$FILTERED_BREWFILE"' EXIT
    brew_re='^(brew|cask)[[:space:]]+"([^"]+)"'
    while IFS= read -r line || [[ -n "$line" ]]; do
      if [[ "$line" =~ $brew_re ]] && is_selected "$(brew_id "${BASH_REMATCH[2]}")"; then
        echo "$line" >> "$FILTERED_BREWFILE"
      fi
    done < "$REPO/Brewfile"
    brew bundle --file="$FILTERED_BREWFILE"
  fi
fi

if ! command -v stow >/dev/null 2>&1; then
  echo "GNU stow is required (brew install stow)" >&2
  exit 1
fi

if [[ "${#PACKAGES[@]}" -eq 0 ]]; then
  echo "==> No config packages selected; nothing to link."
  exit 0
fi

echo "==> Backing up conflicting files to $BACKUP"
for pkg in "${PACKAGES[@]}"; do
  while IFS= read -r -d '' rel; do
    rel="${rel#./}"
    target="$HOME/$rel"

    # Never touch a path that is already inside a stowed (symlinked) tree.
    skip=0
    current="$HOME"
    IFS='/' read -r -a parts <<< "$rel"
    for part in "${parts[@]}"; do
      current="$current/$part"
      if [[ -L "$current" ]]; then
        skip=1
        break
      fi
    done
    [[ "$skip" -eq 1 ]] && continue

    if [[ -e "$target" ]]; then
      mkdir -p "$BACKUP/$(dirname "$rel")"
      mv "$target" "$BACKUP/$rel"
      echo "    $target"
    fi
  done < <(cd "$REPO/$pkg" && find . \( -type f -o -type l \) -print0)
done

echo "==> Linking packages"
stow --dir="$REPO" --target="$HOME" --restow "${PACKAGES[@]}"

echo "==> Done. Open a new shell to pick up the zsh, starship, fzf, and zoxide config."
