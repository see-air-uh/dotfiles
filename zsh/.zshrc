
alias ll='ls -l'

alias melonds="$HOME/dev/pokemon/melonDS.app/Contents/MacOS/melonDS"

alias sync-fork-pret='git checkout main && git fetch pret && git merge pret/main && git push origin main'

  [[ -r "/opt/homebrew/etc/profile.d/bash_completion.sh" ]] && . "/opt/homebrew/etc/profile.d/bash_completion.sh"

# >>> grok installer >>>
export PATH="$HOME/.grok/bin:$PATH"
fpath=(~/.grok/completions/zsh $fpath)
autoload -Uz compinit && compinit -C
# <<< grok installer <<<

# >>> ytdl >>>
export PATH="$HOME/.local/bin:$PATH"
# <<< ytdl <<<

alias n='nvim .'
alias nsettings='nvim ~/.config/nvim/'

eval "$(fzf --zsh)"
eval "$(zoxide init zsh)"
eval "$(starship init zsh)"

export PATH=/opt/homebrew/opt/unzip/bin:$PATH
