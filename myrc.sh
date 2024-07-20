export PATH=~/.local/bin:$PATH
export PATH=~/.config/bin:$PATH

if [[ $SHELL == */bash ]]; then
    eval "$(zoxide init bash)"
    eval "$(starship init bash)"
    eval "$(fzf --bash)"
elif [[ $SHELL == */zsh ]]; then
    eval "$(zoxide init zsh)"
    eval "$(starship init zsh)"
    source <(fzf --zsh)
fi

# alias dc='docker compose'
# 改为自动检测
if docker compose version &> /dev/null; then
    alias dc='docker compose'
else
    alias dc='docker-compose'
fi
alias dcc='docker context'
alias dr='dc down && dc pull && dc build && dc up -d'
alias dd='dc down'
alias dl='dc logs -f'
alias dp='docker ps -a'
alias dpp='docker system prune -a'
alias de='docker exec -it'
alias dt='docker run -it --rm'

alias r='yy'
function yy() {
	local tmp="$(mktemp -t "yazi-cwd.XXXXXX")"
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
        ido ollama pull "$tag"
    done
}

wez() {
    export TERM_PROGRAM=WezTerm
}

install_config() {
    bash <(curl https://raw.githubusercontent.com/uxfion/.config/main/bin/install.sh)
}

update_config() {
    cd ~/.config
    git reset --hard HEAD
    git pull
    cd -
}

show_env() {
    env | grep -i "$1"
}

show_path() {
    # echo -e ${PATH//:/'\n'}
    echo $PATH | tr ':' '\n'
}

if [ -d "$HOME/.local/share/kitty-ssh-kitten/kitty/bin" ] && [[ ":$PATH:" != *":$HOME/.local/share/kitty-ssh-kitten/kitty/bin:"* ]]; then
    export PATH="$PATH:$HOME/.local/share/kitty-ssh-kitten/kitty/bin"
fi