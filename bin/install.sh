#!/bin/bash

tdir=''
cleanup() {
    [ -n "$tdir" ] && {
        command rm -rf "$tdir"
        tdir=''
    }
}

die() {
    cleanup
    printf "\033[31m%s\033[m\n\r" "$*" > /dev/stderr;
    exit 1;
}

log() {
    printf "\033[32m%s\033[m\n\r" "$*" > /dev/stderr;
}

detect_network_tool() {
    if command -v curl > /dev/null 2>&1; then
        fetch() {
            command curl -fL "$1"
        }
        fetch_quiet() {
            command curl -fsSL "$1"
        }
    elif command -v wget > /dev/null 2>&1; then
        fetch() {
            command wget -O- "$1"
        }
        fetch_quiet() {
            command wget --quiet -O- "$1"
        }
    else
        die "neither curl nor wget available, cannot download"
    fi
}

detect_os() {
    arch=""
    case "$(command uname)" in
        'Darwin') OS="macos";;
        'Linux')
            OS="linux"
            case "$(command uname -m)" in
                amd64|x86_64) arch="x86_64";;
                # arm64
                aarch64*) arch="aarch64";;
                armv8*) arch="aarch64";;
                i386) arch="i686";;
                i686) arch="i686";;
                *) die "unknown CPU architecture $(command uname -m)";;
            esac
            ;;
        *) die "binaries are not available for $(command uname)"
    esac
}

detect_brew() {
    if command -v brew > /dev/null 2>&1; then
        brew_installed=true
    else
        brew_installed=false
    fi
}

detect_apt() {
    if command -v apt > /dev/null 2>&1; then
        apt_installed=true
    else
        apt_installed=false
    fi
}

# -------------------------- yazi --------------------------
install_yazi_by_brew() {
    log "installing yazi and dependencies by brew"
    packages=(yazi ffmpegthumbnailer unar jq poppler fd ripgrep fzf zoxide)
    for package in "${packages[@]}"; do
        log "installing $package"
        for attempt in {1..2}; do
            if brew install "$package"; then
                break
            elif [ "$attempt" -eq 2 ]; then
                die "failed to install $package after 2 attempts"
            fi
            log "retrying to install $package"
        done
    done
    log "yazi and dependencies installed"
}

download_yazi_binary() {
    local _arch="$1"
    local _releases_url="https://api.github.com/repos/sxyazi/yazi/releases/latest"
    local _releases
    _releases=$(fetch_quiet "$_releases_url")
    _package_url="$(echo "${_releases}" | grep "browser_download_url" | cut -d '"' -f 4 | grep "${_arch}" | grep "linux-gnu.zip")"

    fetch "$_package_url" > "$tdir/yazi.zip" || die "failed to download: $_package_url"
    unzip -j -d "$tdir/yazi/" "$tdir/yazi.zip"
    cp "$tdir/yazi/yazi" ~/.local/bin/yazi
}

install_yazi_by_apt() {
    log "installing yazi and dependencies by apt"
    if [ "$arch" = "x86_64" ] || [ "$arch" = "aarch64" ]; then
        log "installing yazi $arch binary"
        download_yazi_binary "$arch"
        log "yazi installed to ~/.local/bin/yazi"
        log "installing yazi dependencies"
        sudo apt update
        sudo apt install -y file unar jq fd-find ripgrep fzf ffmpegthumbnailer poppler-utils || die "failed to install dependencies"
        log "installing zoxide"
        curl -sS https://raw.githubusercontent.com/ajeetdsouza/zoxide/main/install.sh | bash
        log "zoxide installed to ~/.local/bin/zoxide"
        log "yazi and dependencies installed"
    else
        die "unknown CPU architecture $arch"
    fi
}
# ----------------------------------------------------------

# -------------------------- nvim --------------------------
install_nvim_by_brew() {
    log "installing nvim by brew"
    brew install nvim rustup fd ripgrep || die "failed to install nvim and dependencies"
    brew install node@20 && brew link --overwrite node@20 || die "failed to install node@20"
    npm install -g neovim || die "failed to install npm neovim"
    pip install pynvim || die "failed to install pynvim"
    log "nvim and dependencies installed"
}

download_nvim_binary() {
    sudo apt install libfuse2 || die "failed to install libfuse2"
    fetch https://github.com/neovim/neovim/releases/download/stable/nvim.appimage > ~/.local/bin/nvim.appimage || die "failed to download nvim"
    chmod +x ~/.local/bin/nvim.appimage && ln -sf ~/.local/bin/nvim.appimage ~/.local/bin/nvim
}

install_nvim_by_apt() {
    log "installing nvim and dependencies by apt"
    if [ "$arch" = "x86_64" ]; then
        log "installing nvim $arch appimage"
        download_nvim_binary
        log "nvim installed to ~/.local/bin/nvim"
    elif [ "$arch" = "aarch64" ]; then
        # https://github.com/matsuu/neovim-aarch64-appimage
        log "installing nvim from source"
        read -t 10 -p "Do you want to install nvim from source? [y/N] " choice
        # 如果用户没有输入，read命令的返回状态会是大于128的。使用该特性来检测超时
        if [ $? -eq 142 ]; then
            log "timeout, nvim is not installed"
            choice="n"
        fi
        case "$choice" in
            y|Y)
                log "installing nvim from source"
                sudo apt update
                sudo apt install -y git build-essential ca-certificates curl gnupg python3-pip || die "failed to install dependencies"
                git clone -b stable https://github.com/neovim/neovim.git "$tdir/neovim" || die "failed to clone neovim"
                cd "$tdir/neovim"
                make CMAKE_BUILD_TYPE=Release || die "failed to build nvim"
                sudo make install || die "failed to install nvim"
                log "nvim installed to /usr/local/bin/nvim"
                ;;
            *)
                log "nvim is not installed"
                ;;
        esac
    else
        die "unknown CPU architecture $arch"
    fi
    log "installing nvim dependencies"
    sudo apt update
    sudo apt install -y fd-find ripgrep || die "failed to install dependencies"
    # node
    curl -fsSL https://deb.nodesource.com/setup_20.x | sudo -E bash - || die "failed to ssetup nodejs repository"
    sudo apt-get install -y nodejs || die "failed to install nodejs"
    npm install -g neovim || die "failed to install npm neovim"
    pip install pynvim || die "failed to install pynvim"
    log "nvim and dependencies installed"
}
# ----------------------------------------------------------

# -------------------------- lazygit --------------------------
install_lazygit_by_brew() {
    log "installing lazygit by brew"
    brew install lazygit || die "failed to install lazygit"
    log "lazygit installed"
}

install_lazygit_by_apt() {
    log "installing lazygit by binary"
    LAZYGIT_VERSION=$(curl -s "https://api.github.com/repos/jesseduffield/lazygit/releases/latest" | grep -Po '"tag_name": "v\K[^"]*')
    if [ "$arch" = "x86_64" ]; then
        curl -Lo "$tdir/lazygit.tar.gz" "https://github.com/jesseduffield/lazygit/releases/latest/download/lazygit_${LAZYGIT_VERSION}_Linux_x86_64.tar.gz" || die "failed to download lazygit"
        tar -xzf "$tdir/lazygit.tar.gz" -C "$tdir" lazygit
        sudo install "$tdir/lazygit" ~/.local/bin
    elif [ "$arch" = "aarch64" ]; then
        curl -Lo "$tdir/lazygit.tar.gz" "https://github.com/jesseduffield/lazygit/releases/latest/download/lazygit_${LAZYGIT_VERSION}_Linux_arm64.tar.gz" || die "failed to download lazygit"
        tar -xzf "$tdir/lazygit.tar.gz" -C "$tdir" lazygit
        sudo install "$tdir/lazygit" ~/.local/bin
    else
        die "unknown CPU architecture $arch"
    fi
    log "lazygit installed to ~/.local/bin/lazygit"
}
# ----------------------------------------------------------

# -------------------------- tmux --------------------------
install_tmux_by_brew() {
    log "installing tmux by brew"
    brew install tmux || die "failed to install tmux"
    log "tmux installed"
}

install_tmux_by_apt() {
    log "installing tmux by apt"
    sudo apt update
    sudo apt install -y tmux || die "failed to install tmux"
    log "tmux installed"
}
# ----------------------------------------------------------

config() {
    # 设置目标 git 仓库地址
    GIT_REPO="https://github.com/uxfion/.config.git"
    GIT_REPO_SSH="git@github.com:uxfion/.config.git"
    CONFIG_DIR="$HOME/.config"

    # 检查 ~/.config 目录是否存在
    if [ ! -d "$CONFIG_DIR" ]; then
        log "directory $CONFIG_DIR does not exist, creating"
        mkdir -p "$CONFIG_DIR"
    fi

    cd "$CONFIG_DIR"

    # 检查当前目录是否是一个 git 仓库
    if ! git rev-parse --is-inside-work-tree > /dev/null 2>&1; then
        log "init git repo in $CONFIG_DIR"
        git init && git branch -M main
        git remote add origin "$GIT_REPO"
        git branch -u origin/main main
        git pull
    else
        # 检查设置的远程仓库是否正确
        REMOTE_URL=$(git remote get-url origin)
        if [ "$REMOTE_URL" = "$GIT_REPO" ] || [ "$REMOTE_URL" = "$GIT_REPO_SSH" ]; then
                log "remote repo already set, pulling"
                git pull
        else
            die "remote repo does not match, exiting"
        fi
    fi
}

rc() {
    LINE_TO_ADD="if [ -f ~/.config/myrc.sh ]; then\n    source ~/.config/myrc.sh\nfi"

    if [ "$SHELL" = "/bin/zsh" ]; then
        CONFIG_FILE="$HOME/.zshrc"
    elif [ "$SHELL" = "/bin/bash" ]; then
        CONFIG_FILE="$HOME/.bashrc"
    else
        die "unsupported shell type: $SHELL"
    fi

    if grep -qF -- "source ~/.config/myrc.sh" "$CONFIG_FILE"; then
        log "myrc.sh exists in $CONFIG_FILE, no need to add."
    else
        echo -e "$LINE_TO_ADD" >> "$CONFIG_FILE"
        log "added myrc.sh to $CONFIG_FILE"
    fi

    source "$CONFIG_FILE"
    log "sourced $CONFIG_FILE"
}

main() {
    log "---------- info ----------"
    detect_os
    log "OS: $OS"
    log "arch: $arch"
    detect_network_tool
    detect_brew
    log "brew: $brew_installed"
    detect_apt
    log "apt: $apt_installed"
    tdir=$(command mktemp -d "/tmp/config-install-XXXXXXXXXXXX")
    log "temp dir: $tdir"
    log "bin dir: ~/.local/bin"
    # log "--------------------------"
    log "------- preparing -------"
    if [ "$OS" = "macos" ]; then
        if [ "$brew_installed" = true ]; then
            log "using brew to install"
            install_yazi_by_brew
            install_nvim_by_brew
            install_lazygit_by_brew
            install_tmux_by_brew
        else
            die "brew is not installed"
        fi
    elif [ "$OS" = "linux" ]; then
        if [ "$brew_installed" = true ]; then
            log "using brew to install"
            install_yazi_by_brew
            install_nvim_by_brew
            install_lazygit_by_brew
            install_tmux_by_brew
        elif [ "$apt_installed" = true ]; then
            log "using apt and binaries to install"
            install_yazi_by_apt
            install_nvim_by_apt
            install_lazygit_by_apt
            install_tmux_by_apt
        else
            die "brew and apt are not installed"
        fi
    fi
    log "------- configuring -------"
    config
    rc
    log "------- cleaning -------"
    cleanup
    log "done!"
}

main "$@"