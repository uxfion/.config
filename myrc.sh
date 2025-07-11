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
# TODO: 有些场景好像有问题，待反馈
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

hf_download() {
    local input="$1"
    IFS=',' read -ra tags <<< "$input"
    for tag in "${tags[@]}"; do
        ido huggingface-cli download "$tag"
    done
}

hf_download_dataset() {
    local input="$1"
    IFS=',' read -ra tags <<< "$input"
    for tag in "${tags[@]}"; do
        ido huggingface-cli download --repo-type dataset "$tag"
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

show_size() {
    du -sh ./* ./.??* 2>/dev/null | sort -rh
}

show_color() {
    awk 'BEGIN{
        s="/\\/\\/\\/\\/\\"; s=s s s s s s s s;
        for (colnum = 0; colnum<77; colnum++) {
            r = 255-(colnum*255/76);
            g = (colnum*510/76);
            b = (colnum*255/76);
            if (g>255) g = 510-g;
            printf "\033[48;2;%d;%d;%dm", r,g,b;
            printf "\033[38;2;%d;%d;%dm", 255-r,255-g,255-b;
            printf "%s\033[0m", substr(s,colnum+1,1);
        }
        printf "\n";
    }'
}

if [ -d "$HOME/.local/share/kitty-ssh-kitten/kitty/bin" ] && [[ ":$PATH:" != *":$HOME/.local/share/kitty-ssh-kitten/kitty/bin:"* ]]; then
    export PATH="$PATH:$HOME/.local/share/kitty-ssh-kitten/kitty/bin"
fi

# bind -x '"\C-p": "~/.config/bin/process"'
# TODO: 无法交互

bind -f ~/.config/.inputrc


cs() {
    source <(/root/.config/bin/conda_selector.sh)
}
cdd() {
    conda deactivate
}
