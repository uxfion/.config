#!/bin/bash

source <(curl -s https://raw.githubusercontent.com/uxfion/.config/main/bin/print)
source <(curl -s https://raw.githubusercontent.com/uxfion/.config/main/bin/ido)
source <(curl -s https://raw.githubusercontent.com/uxfion/.config/main/download_github_release.sh)


tdir=''
cleanup() {
    [ -n "$tdir" ] && {
        command rm -rf "$tdir"
        tdir=''
    }
}

die() {
    cleanup
    printf "\033[1;31;4m%s\033[0m\n\r" "$*" > /dev/stderr;
    exit 1;
}

log() {
    printf "\033[1;34;4m%s\033[0m\n\r" "$*" > /dev/stderr;
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
    print -c blue "installing yazi and dependencies by brew"
    packages=(yazi ffmpegthumbnailer unar jq poppler fd ripgrep fzf zoxide bat)
    for package in "${packages[@]}"; do
        for attempt in {1..2}; do
            if ido brew install "$package"; then
                break
            elif [ "$attempt" -eq 2 ]; then
                die "failed to install $package after 2 attempts"
            fi
            print -c purple "retrying to install $package"
        done
    done
    print -c blue "yazi and dependencies installed"
}

download_yazi_binary() {
    glibc_version=$(ldd --version | head -n1 | grep -oP '(\d+\.\d+)' | head -1)
    if [[ $(echo "$glibc_version < 2.32" | bc) -eq 1 ]]; then
        # glibc版本小于2.32
        print -c purple "glibc version is less than 2.32, using musl version of yazi for compatibility"
        ido download_github_release sxyazi/yazi $tdir linux $arch musl
    else
        # glibc版本等于或高于2.32
        ido download_github_release sxyazi/yazi $tdir linux $arch gnu -e snap
    fi

    ido unzip -j "$tdir/yazi*.zip" -d "$tdir/yazi/"
    ido cp "$tdir/yazi/yazi" ~/.local/bin/yazi
    ido cp "$tdir/yazi/ya" ~/.local/bin/ya
}

install_yazi_by_binary() {
    print -c blue "installing yazi and dependencies by binary"
    if [ "$arch" = "x86_64" ] || [ "$arch" = "aarch64" ]; then
        print -c blue "installing yazi $arch binary"
        download_yazi_binary
        print -c blue "yazi installed to ~/.local/bin/yazi"
        print -c blue "installing yazi dependencies"
        ido sudo apt update
        ido sudo apt install -y file ffmpegthumbnailer unar jq poppler-utils fd-find ripgrep fzf bat
        print -c blue "installing zoxide"
        ido "curl -sSfL https://raw.githubusercontent.com/ajeetdsouza/zoxide/main/install.sh | sh"
        print -c blue "zoxide installed to ~/.local/bin/zoxide"
        print -c blue "yazi and dependencies installed"
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

download_nvim_x64_binary() {
    sudo apt install libfuse2 || die "failed to install libfuse2"
    fetch https://github.com/neovim/neovim/releases/download/stable/nvim.appimage > ~/.local/bin/nvim.appimage || die "failed to download nvim"
    chmod +x ~/.local/bin/nvim.appimage && ln -sf ~/.local/bin/nvim.appimage ~/.local/bin/nvim
}

download_nvim_aarch64_binary() {
    sudo apt install libfuse2 || die "failed to install libfuse2"
    local _releases_url="https://api.github.com/repos/matsuu/neovim-aarch64-appimage/releases/latest"
    local _releases=$(fetch_quiet "$_releases_url")
    local _package_url="$(echo "${_releases}" | grep "browser_download_url" | cut -d '"' -f 4 | grep "aarch64.appimage")"
    fetch $_package_url > ~/.local/bin/nvim.appimage || die "failed to download nvim"
    chmod +x ~/.local/bin/nvim.appimage && ln -sf ~/.local/bin/nvim.appimage ~/.local/bin/nvim
}

install_nvim_by_binary() {
    log "installing nvim and dependencies by binary"
    log "installing nvim $arch appimage"
    if [ "$arch" = "x86_64" ]; then
        download_nvim_x64_binary
    elif [ "$arch" = "aarch64" ]; then
        download_nvim_aarch64_binary
    else
        die "unknown CPU architecture $arch"
    fi
    log "nvim installed to ~/.local/bin/nvim"
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

install_lazygit_by_binary() {
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


# -------------------------- tmux --------------------------
install_starship_by_brew() {
    log "installing starship by brew"
    brew install starship || die "failed to install starship"
    log "starship installed"
}
install_starship_by_binary() {
    log "installing starship by binary"
    curl -fsSL https://starship.rs/install.sh | sh -s -- -b ~/.local/bin -y || die "failed to install starship"
    log "starship installed"
}
# ----------------------------------------------------------

apt_prepare() {
    log "requirements before installation"
    ido sudo apt update
    ido sudo apt install -y git build-essential curl jq python3-pip unzip bc || die "failed to install dependencies"
}

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
        git init
        git remote add origin "$GIT_REPO"
        git fetch origin main:main
        git branch -u origin/main main
        git switch main
        git pull
    else
        # 检查设置的远程仓库是否正确
        REMOTE_URL=$(git remote get-url origin)
        if [ "$REMOTE_URL" = "$GIT_REPO" ] || [ "$REMOTE_URL" = "$GIT_REPO_SSH" ]; then
                log "remote repo already set, pulling"
                log "nuke working tree"
                git reset --hard HEAD
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
            install_starship_by_brew
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
            install_starship_by_brew
        elif [ "$apt_installed" = true ]; then
            log "using apt and binaries to install"
            apt_prepare
            install_yazi_by_binary
            install_nvim_by_binary
            install_lazygit_by_binary
            install_tmux_by_apt
            install_starship_by_binary
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
    log "please run the following command to apply the changes:"
    log "source $CONFIG_FILE"
}

main "$@"
