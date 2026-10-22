#!/usr/bin/env bash
set -euo pipefail

REPO="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
PACKAGES=(zsh nvim tmux ghostty starship opencode zed gh)
BACKUP="$HOME/.dotfiles-backup/$(date +%Y%m%d-%H%M%S)"

usage() {
  cat <<'EOF'
Usage: ./install.sh [--help]

Installs Homebrew packages from Brewfile, then symlinks every package into $HOME
with GNU stow. Existing files are moved to ~/.dotfiles-backup/<timestamp>/ first.

Environment:
  SKIP_BREW=1   Skip "brew bundle" and only create the symlinks.
EOF
}

if [[ "${1:-}" == "--help" || "${1:-}" == "-h" ]]; then
  usage
  exit 0
fi

if ! command -v brew >/dev/null 2>&1; then
  echo "Homebrew is required: https://brew.sh" >&2
  exit 1
fi

if [[ "${SKIP_BREW:-0}" != "1" ]]; then
  echo "==> Installing packages from Brewfile"
  brew bundle --file="$REPO/Brewfile"
fi

if ! command -v stow >/dev/null 2>&1; then
  echo "GNU stow is required (brew install stow)" >&2
  exit 1
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
