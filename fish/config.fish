if status is-interactive
    # Commands to run in interactive sessions can go here
end

set -g fish_greeting

# bun
set --export BUN_INSTALL "$HOME/.bun"
set --export PATH $BUN_INSTALL/bin $PATH

# Go bin path
set --export PATH "$HOME/go/bin" $PATH

# Cargp bin path
set --export PATH "$HOME/.cargo/bin" $PATH

starship init fish | source
fnm env --use-on-cd | source
zoxide init fish | source

# nvim
alias nv="nvim"

# zoxide
# alias cd="z"

# zellij
alias ze="zellij"
alias zes="zellij -s"
alias zel="zellij ls"
alias zea="zellij a"
alias zek="zellij ka"

# exa
alias l="exa -1 --icons -a -s=type --colour=always -H -I '.git|node_modules'"
alias ll="exa -G --icons -a -s=type --colour=always -H -I '.git|node_modules'"
alias lt="l -T -L 1"
alias lt2="l -T -L 2"
alias lt3="l -T -L 3"
alias lt4="l -T -L 4"

# lazygit
alias g="lazygit"

# git
alias ga="git add"
alias gaa="git add ."
alias gs="git status"
alias gl="git log --oneline"
alias gc="git commit"
alias gcm="git commit -m"
alias gca="git commit --amend"
alias gcav="git commit --amend --no-verify"
alias gp="git push"
alias gpp="git pull"
alias gr="git rebase"
alias gri="git rebase -i"
alias gs="git switch"
alias gsc="git switch"

# Added by Windsurf
fish_add_path /Users/saidgeek/.codeium/windsurf/bin

set -gx CARGO_TARGET_DIR /Users/saidgeek/rust_target

set -U LIBRARY_PATH (brew --prefix)/lib
set -U fish_user_paths (brew --prefix)/bin $fish_user_paths
