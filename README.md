# Terminal Setup

My macOS terminal development environment, managed as GNU Stow packages. Everything uses the
[Catppuccin Frappe](https://github.com/catppuccin/catppuccin) palette: Ghostty, tmux, Neovim,
Starship, and the shells running inside them.

## Tools

### Core terminal

| Tool | Install | What it does |
| --- | --- | --- |
| [Ghostty](https://ghostty.org) | `cask "ghostty"` | Terminal. Frappe theme, JetBrainsMono Nerd Font (Bold), size 26, 0.99 opacity. |
| [tmux](https://github.com/tmux/tmux) | `brew "tmux"` | Multiplexer. Prefix is `Ctrl-a`, status bar on top. |
| [tpm](https://github.com/tmux-plugins/tpm) | `brew "tpm"` | tmux plugin manager. |
| [zsh](https://www.zsh.org) | system | Shell, with `fzf`, `zoxide`, and `starship` initialized in `.zshrc`. |
| [Starship](https://starship.rs) | `brew "starship"` | Prompt. Minimal left side (`directory` + `character`), everything else on the right. |
| [Stow](https://www.gnu.org/software/stow/) | `brew "stow"` | Symlinks the packages in this repo into `$HOME`. |

### Shell productivity

| Tool | Install | What it does |
| --- | --- | --- |
| [zoxide](https://github.com/ajeetdsouza/zoxide) | `brew "zoxide"` | Smarter `cd`; `z <dir>` jumps to frecent directories. |
| [fzf](https://github.com/junegunn/fzf) | `brew "fzf"` | Fuzzy finder with `Ctrl-r` / `Ctrl-t` / `Alt-c` shell bindings. |
| [eza](https://github.com/eza-community/eza) | `brew "eza"` | Modern `ls` replacement (installed; no alias is defined). |
| [fd](https://github.com/sharkdp/fd) | `brew "fd"` | Fast, user-friendly `find`. |
| [ripgrep](https://github.com/BurntSushi/ripgrep) | `brew "ripgrep"` | Fast recursive search; also powers Neovim pickers. |
| [sesh](https://github.com/joshmedeski/sesh) | `brew "sesh"` | tmux session manager. |
| [jq](https://jqlang.github.io/jq/) | `brew "jq"` | JSON processing. |
| [tree](https://oldmanprogrammer.net/source.php?dir=projects/tree) | `brew "tree"` | Directory tree viewer. |

### Editors and TUIs

| Tool | Install | What it does |
| --- | --- | --- |
| [Neovim](https://neovim.io) | `brew "neovim"` | Main editor, built on [LazyVim](https://www.lazyvim.org). |
| [Zed](https://zed.dev) | `cask "zed"` | GUI editor with Vim mode and telemetry disabled. |
| [lazygit](https://github.com/jesseduffield/lazygit) | `brew "lazygit"` | Git TUI. |
| [lazydocker](https://github.com/jesseduffield/lazydocker) | `brew "lazydocker"` | Docker TUI. |
| [GitHub CLI](https://cli.github.com) | `brew "gh"` | `gh` for repos, PRs, auth, and git credentials. |
| [opencode](https://opencode.ai) | `brew "opencode-v2"` | Terminal AI coding agent. |

### Runtimes and language tooling

| Tool | Install | What it does |
| --- | --- | --- |
| Node.js | `brew "node"` | JavaScript/TypeScript runtime. |
| Deno | `brew "deno"` | JS/TS runtime. |
| Go | `brew "go"` | Go toolchain. |
| Python | `brew "python@3.14"` | Python runtime. |
| TypeScript | `brew "typescript"` | `tsc`. |
| typescript-language-server | `brew "typescript-language-server"` | TypeScript LSP. |
| tree-sitter | `brew "tree-sitter"` | Parser generator / CLI. |
| clang-format | `brew "clang-format"` | C/C++ formatting. |
| LLVM | `brew "llvm"` | Compiler toolchain. |
| PostgreSQL | `brew "postgresql@18"` | Database server and client. |
| Temurin | `cask "temurin"` | JDK. |

### Media and network

| Tool | Install | What it does |
| --- | --- | --- |
| ffmpeg | `brew "ffmpeg"` | Audio/video conversion. |
| ImageMagick | `brew "imagemagick"` | Image conversion and manipulation. |
| yt-dlp | `brew "yt-dlp"` | Media downloader. |
| wget / curl | `brew "wget"`, `brew "curl"` | HTTP clients. |
| git / git-lfs | `brew "git"`, `brew "git-lfs"` | Git and large-file support. |

Optional extras for the keyboard firmware workflow (`qmk`, `arm-none-eabi-gcc`, `avr-gcc@8`,
`mdloader`) are commented out in the `Brewfile`; they are not needed for the terminal setup.

## Layout

Each top-level directory is a Stow package whose contents are relative to `$HOME`:

```
zsh/.zshrc, .zprofile, .zshenv      -> ~/
nvim/.config/nvim/                  -> ~/.config/nvim/
tmux/.config/tmux/                  -> ~/.config/tmux/
ghostty/.config/ghostty/            -> ~/.config/ghostty/
starship/.config/starship.toml      -> ~/.config/starship.toml
opencode/.config/opencode/          -> ~/.config/opencode/
zed/.config/zed/                    -> ~/.config/zed/
gh/.config/gh/config.yml            -> ~/.config/gh/
```

## Install

```sh
git clone https://github.com/see-air-uh/dotfiles.git ~/dev/dotfiles
cd ~/dev/dotfiles
./install.sh              # brew bundle + stow
SKIP_BREW=1 ./install.sh  # only create symlinks
```

`install.sh` moves any conflicting files to `~/.dotfiles-backup/<timestamp>/` before linking.

## After installing

```sh
gh auth login             # also wires git credential helper
opencode auth login       # if you use the AI agent
tmux                      # then press Ctrl-a + I to install plugins
nvim                      # lazy.nvim bootstraps itself; run :Lazy sync
```

## Configuration notes

### Neovim

- LazyVim 16 with extras for git, Go, JSON, Markdown, PHP, Python, Rust, SQL, Svelte, TOML,
  TypeScript (Biome), YAML, Zig, plus `mini-surround`.
- Catppuccin Frappe is loaded eagerly and registered as `catppuccin-frappe`. Neovim 0.12 ships a
  built-in `catppuccin` colorscheme (Mocha), and lazy.nvim skips loading a plugin when the requested
  colorscheme name already exists, so the plugin must use the flavoured name to win.
- `termguicolors` and `scrolloff=10` set in `lua/config/options.lua`.
- Snacks explorer opens on the right; `blink.cmp` is disabled in Markdown; `render-markdown.nvim`
  is disabled; `scrollEOF.nvim` keeps context at the end of files.

### tmux

- Prefix `Ctrl-a`, windows numbered from 1, status bar on top, true color enabled.
- Catppuccin Frappe status bar with session on the left and `directory` on the right.
- A one-cell lavender pane border (`#babbf1`) separates the status bar from pane content.
- `tmux-floax` popup on `Ctrl-a p`; `tmux-sessionx` on `Ctrl-a o`.
- `tmux-resurrect` + `tmux-continuum` restore sessions automatically.
- Plugins are managed by tpm and are not committed (`~/.config/tmux/plugins` is ignored).

### Ghostty / Starship / Zed

- Ghostty reads `~/.config/ghostty/config.ghostty` in current builds; the filename is kept as-is.
- Custom macOS app icons live in `ghostty/icons/` and are applied with `macos-icon = custom`.
  Three variants are included: the Catppuccin Frappe ghost, plain Catppuccin Frappe, and Ghostty
  original; point `macos-custom-icon` at the one you want.
- Starship defines the full `catppuccin_frappe` palette (`overLaye` is a harmless typo for
  `overlay0`; it is not referenced by the prompt format).
- Zed is set to system theme mode with **Catppuccin Macchiato** for dark mode. Switch it to
  `Catppuccin Frappe` if you want the GUI editor to match the terminal.

## Security

Deliberately not committed:

- `~/.config/gh/hosts.yml` (account-specific; the auth token lives in the macOS keychain)
- `~/.gitconfig` (personal identity and credential helper)
- `~/.ssh`, API keys, tokens, and any environment files
- `~/.config/tmux/plugins`, `~/.config/opencode/node_modules` (installed/vendored state)

The committed configs were scanned for tokens, passwords, private keys, and OAuth secrets before
the initial commit. If you fork this, run your own scan before pushing.

## Credits

Built on [LazyVim](https://github.com/LazyVim/LazyVim), [Catppuccin](https://catppuccin.com),
[tmux](https://github.com/tmux/tmux), and the tmux plugin ecosystem. The tmux configuration started
from [omerxx/dotfiles](https://github.com/omerxx/dotfiles) and has been trimmed and localized.
