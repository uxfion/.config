export PATH=~/.local/bin:$PATH
export PATH=~/.config/bin:$PATH

if [[ $SHELL == */bash ]]; then
    eval "$(fzf --bash)"
    eval "$(zoxide init bash)"
    eval "$(starship init bash)"
elif [[ $SHELL == */zsh ]]; then
    eval "$(fzf --zsh)"
    eval "$(zoxide init zsh)"
    eval "$(starship init zsh)"
fi

# alias cd='z'

alias dc='docker compose'
alias dr='dc down && dc pull && dc build && dc up -d'
alias dd='dc down'
alias dl='dc logs -f'
alias dp='docker ps -a'
alias dpp='docker system prune -a'
alias de='docker exec -it'
alias dt='docker run -it --rm'

alias r='ya'
function ya() {
    local tmp="$(mktemp -t "yazi-cwd.XXXXX")"
    yazi "$@" --cwd-file="$tmp"
    if cwd="$(cat -- "$tmp")" && [ -n "$cwd" ] && [ "$cwd" != "$PWD" ]; then
        cd -- "$cwd"
    fi
    rm -f -- "$tmp"
}

export EDITOR='nvim'
alias v='nvim'
alias vim='nvim'

alias t='tmux new -A -s'
alias tl='tmux ls'
alias tn='tmux new -A -s'
alias ta='tmux attach -t'

alias lzg='lazygit'

alias diff='kitten diff'
alias icat='kitten icat'
alias gdiff='git difftool --no-symlinks --dir-diff'
alias lsh='ls --hyperlink=auto'
# alias down='kitten transfer'
# alias up='kitten transfer --direction=upload'
down() {
    kitten transfer "$@" /Users/lecter/Downloads/
}
up() {
    kitten transfer --direction=upload "$@" ./
}

op() {
    local input="$1"
    IFS=',' read -ra tags <<< "$input"
    for tag in "${tags[@]}"; do
        echo -e "\033[1;4;36mollama pull $tag\033[0m"
        ollama pull "$tag"
    done
}

