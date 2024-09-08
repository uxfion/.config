#!/bin/bash

source <(curl -s https://raw.githubusercontent.com/uxfion/.config/main/bin/print)
source <(curl -s https://raw.githubusercontent.com/uxfion/.config/main/bin/ido)
source <(curl -s https://raw.githubusercontent.com/uxfion/.config/main/bin/download_github_release.sh)


tdir=''
cleanup() {
    [ -n "$tdir" ] && {
        command rm -rf "$tdir"
        print -c purple "cleaned up temp dir $tdir"
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
                # i386) arch="i686";;
                # i686) arch="i686";;
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
    print -c blue "==== installing yazi by brew......"
    # ffmpegthumbnailer unar
    ido brew install yazi ffmpeg sevenzip jq poppler fd ripgrep fzf zoxide imagemagick bat || die "failed to install yazi and dependencies"
    print -c blue "==== yazi installed."
}

download_yazi_binary() {
    # # 为了兼容性所有都用static文件，就不用gnu了，因为gnu通常为dynamic
    # glibc_version=$(ldd --version | head -n1 | grep -oP '(\d+\.\d+)' | head -1)
    # if [[ $(echo "$glibc_version < 2.32" | bc) -eq 1 ]]; then
    #     # glibc版本小于2.32
    #     print -c purple "glibc version is less than 2.32, using musl version of yazi for compatibility."
    #     ido download_github_release sxyazi/yazi $tdir linux $arch musl
    # else
    #     # glibc版本等于或高于2.32
    #     ido download_github_release sxyazi/yazi $tdir linux $arch gnu -e snap
    # fi

    if [ "$arch" = "x86_64" ]; then
        ido download_github_release sxyazi/yazi $tdir linux x86 musl
    elif [ "$arch" = "aarch64" ]; then
        ido download_github_release sxyazi/yazi $tdir linux aarch64 musl
    fi
    mkdir -p $tdir/yazi
    ido unzip $tdir/yazi-*.zip -d $tdir
    ido cp $tdir/yazi-*/yazi ~/.local/bin/yazi
    ido cp $tdir/yazi-*/ya ~/.local/bin/ya
    ido chmod +x ~/.local/bin/yazi
    ido chmod +x ~/.local/bin/ya
}

download_ffmpeg_binary() {
    if [ "$arch" = "x86_64" ]; then
        ido download_github_release eugeneware/ffmpeg-static $tdir ffmpeg linux x64 -e gz  # static
        ido download_github_release eugeneware/ffmpeg-static $tdir ffprobe linux x64 -e gz
    elif [ "$arch" = "aarch64" ]; then
        ido download_github_release eugeneware/ffmpeg-static $tdir ffmpeg linux arm64 -e gz
        ido download_github_release eugeneware/ffmpeg-static $tdir ffprobe linux arm64 -e gz
    fi
    ido cp $tdir/ffmpeg* ~/.local/bin/ffmpeg
    ido cp $tdir/ffprobe* ~/.local/bin/ffprobe
    ido chmod +x ~/.local/bin/ffmpeg
    ido chmod +x ~/.local/bin/ffprobe
}

download_7zip_binary() {
    if [ "$arch" = "x86_64" ]; then
        ido download_github_release ip7z/7zip $tdir linux x64  # static
    elif [ "$arch" = "aarch64" ]; then
        ido download_github_release ip7z/7zip $tdir linux arm64
    fi
    mkdir -p $tdir/7zip
    ido tar -xJf 7z*.tar.xz -C $tdir/7zip
    ido cp $tdir/7zip/7zzs ~/.local/bin/7zz
    ido chmod +x ~/.local/bin/7zz
}

download_jq_binary() {
    if [ "$arch" = "x86_64" ]; then
        ido download_github_release jqlang/jq $tdir linux amd64  # static
    elif [ "$arch" = "aarch64" ]; then
        ido download_github_release jqlang/jq $tdir linux arm64
    fi
    ido cp $tdir/jq* ~/.local/bin/jq
    ido chmod +x ~/.local/bin/jq
}

# TODO: poppler

download_fd_binary() {
    if [ "$arch" = "x86_64" ]; then
        ido download_github_release sharkdp/fd $tdir linux x86 musl  # static
    elif [ "$arch" = "aarch64" ]; then
        ido download_github_release sharkdp/fd $tdir linux aarch64 musl
    fi
    ido tar -xzf fd-*.tar.gz -C $tdir
    ido cp $tdir/fd-*/fd ~/.local/bin/fd
    ido chmod +x ~/.local/bin/fd
}

download_ripgrep_binary() {
    if [ "$arch" = "x86_64" ]; then
        ido download_github_release BurntSushi/ripgrep $tdir linux x86 musl -e sha256  # static
    elif [ "$arch" = "aarch64" ]; then
        ido download_github_release BurntSushi/ripgrep $tdir linux aarch64 gnu -e sha256  # arm64只有gnu的，没有musl
    fi
    ido tar -xzf fd-*.tar.gz -C $tdir
    ido cp $tdir/fd-*/fd ~/.local/bin/fd
    ido chmod +x ~/.local/bin/fd
}

download_fzf_binary() {
    if [ "$arch" = "x86_64" ]; then
        ido download_github_release junegunn/fzf $tdir linux amd64  # static
    elif [ "$arch" = "aarch64" ]; then
        ido download_github_release junegunn/fzf $tdir linux arm64
    fi
    ido tar -xzf $tdir/fzf-*.tar.gz -C $tdir
    ido cp $tdir/fzf ~/.local/bin/fzf
    ido chmod +x ~/.local/bin/fzf
}

# # /tmp/.mount_ImageMK3jJh0/usr/bin/magick: error while loading shared libraries: libharfbuzz.so.0: cannot open shared object file: No such file or directory
# download_imagemagic_binary() {
#     if [ "$arch" = "x86_64" ]; then
#         ido download_github_release ImageMagick/ImageMagick $tdir gcc x86
#     elif [ "$arch" = "aarch64" ]; then
#         # ido download_github_release ImageMagick/ImageMagick $tdir linux arm64
#         print -c purple "no arm64 binary provided, skipping..."
#     fi
#     ido cp ImageMagick-*.AppImage ~/.local/bin/imagemagick.appimage
#     ido "chmod +x ~/.local/bin/imagemagick.appimage && ln -sf ~/.local/bin/imagemagick.appimage ~/.local/bin/magick"
# }


download_bat_binary() {
    if [ "$arch" = "x86_64" ]; then
        ido download_github_release sharkdp/bat $tdir linux x86 musl  # static
    elif [ "$arch" = "aarch64" ]; then
        ido download_github_release sharkdp/bat $tdir linux aarch64 musl
    fi
    ido tar -xzf $tdir/bat-*.tar.gz -C $tdir
    ido cp $tdir/bat-*/bat ~/.local/bin/bat
    ido chmod +x ~/.local/bin/bat
}


install_yazi_by_binary() {
    print -c blue "==== installing yazi by binary......"

    ido sudo apt-get update
    # apt要卸载： apt autoremove ffmpeg ffmpegthumbnailer unar fd-find ripgrep fzf bat
    # binary要安装： ffmpeg 7zip jq fd ripgrep fzf
    # 必须： file jq git
    ido sudo apt-get install -y file jq git poppler-utils || die "failed to install dependencies"

    download_yazi_binary || die "failed to download yazi binary"
    print -c blue "yazi installed to ~/.local/bin/yazi"

    download_ffmpeg_binary || die "failed to download ffmpeg binary"
    print -c blue "ffmpeg and ffprobe installed to ~/.local/bin/ffmpeg ffprobe"

    download_7zip_binary || die "failed to download 7-zip binary"
    print -c blue "7-zip installed to ~/.local/bin/7zz"

    download_jq_binary || die "failed to download jq binary"
    print -c blue "jq installed to ~/.local/bin/jq"

    # TODO: poppler

    download_fd_binary || die "failed to download fd binary"
    print -c blue "fd installed to ~/.local/bin/fd"

    download_ripgrep_binary || die "failed to download ripgrep binary"
    print -c blue "ripgrep installed to ~/.local/bin/rg"

    download_fzf_binary || die "failed to download fzf binary"
    print -c blue "fzf installed to ~/.local/bin/fzf"

    # TODO: imagemagick

    download_bat_binary || die "failed to download bat binary"
    print -c blue "bat installed to ~/.local/bin/bat"
    
    print -c blue "installing zoxide..."
    ido "curl -sSfL https://raw.githubusercontent.com/ajeetdsouza/zoxide/main/install.sh | sh" || die "failed to install zoxide"
    print -c blue "zoxide installed to ~/.local/bin/zoxide"

    print -c blue "==== yazi installed."
}
# ----------------------------------------------------------

# -------------------------- nvim --------------------------
install_nvim_by_brew() {
    print -c blue "==== installing nvim by brew......"
    ido brew install nvim rustup fd ripgrep || die "failed to install nvim and dependencies"
    ido "brew install node@20 && brew link --overwrite node@20"
    ido npm install -g neovim
    ido pip install pynvim
    print -c blue "==== nvim installed."
}

download_nvim_binary() {
    ido sudo apt install libfuse2
    if [ "$arch" = "x86_64" ]; then
        ido download_github_release neovim/neovim ~/.local/bin appimage -e sha256 -e zsync
    elif [ "$arch" = "aarch64" ]; then
        ido download_github_release matsuu/neovim-aarch64-appimage ~/.local/bin
        ido cp ~/.local/bin/nvim-*-aarch64.appimage ~/.local/bin/nvim.appimage
    fi
    ido "chmod +x ~/.local/bin/nvim.appimage && ln -sf ~/.local/bin/nvim.appimage ~/.local/bin/nvim"
}

install_nvim_by_binary() {
    print -c blue "==== installing nvim by binary......"
    download_nvim_binary || die "failed to download nvim binary"
    print -c blue "nvim installed to ~/.local/bin/nvim"
    ido sudo apt-get update
    ido sudo apt-get install -y fd-find ripgrep || die "failed to install nvim dependencies"
    ido "curl -fsSL https://deb.nodesource.com/setup_20.x | sudo -E bash -" || die "failed to setup nodejs repository"
    ido sudo apt-get install -y nodejs || die "failed to install nodejs"
    ido npm install -g neovim
    ido pip install pynvim
    print -c blue "==== nvim installed"
}
# ----------------------------------------------------------

# -------------------------- lazygit --------------------------
install_lazygit_by_brew() {
    print -c blue "==== installing lazygit by brew......"
    ido brew install lazygit
    print -c blue "==== lazygit installed."
}

install_lazygit_by_binary() {
    print -c blue "==== installing lazygit by binary......"
    if [ "$arch" = "x86_64" ]; then
        ido download_github_release jesseduffield/lazygit $tdir linux x86_64
    elif [ "$arch" = "aarch64" ]; then
        ido download_github_release jesseduffield/lazygit $tdir linux arm64
    fi
    ido tar -xzf $tdir/lazygit_*.tar.gz -C $tdir lazygit
    ido sudo install $tdir/lazygit ~/.local/bin
    print -c blue "lazygit installed to ~/.local/bin/lazygit"
    print -c blue "==== lazygit installed."
}
# ----------------------------------------------------------

# -------------------------- tmux --------------------------
install_tmux_by_brew() {
    print -c blue "==== installing tmux by brew......"
    ido brew install tmux
    print -c blue "==== tmux installed."
}

install_tmux_by_apt() {
    print -c blue "==== installing tmux by apt......"
    ido sudo apt-get update
    ido sudo apt-get install -y tmux
    print -c blue "==== tmux installed."
}
# ----------------------------------------------------------


# -------------------------- starship --------------------------
install_starship_by_brew() {
    print -c blue "==== installing starship by brew......"
    brew install starship
    print -c blue "==== starship installed."
}
install_starship_by_binary() {
    print -c blue "==== installing starship by binary......"
    ido "curl -sS https://starship.rs/install.sh | sh -s -- -b ~/.local/bin -y" || die "failed to install starship"
    print -c blue "==== starship installed."
}
# ----------------------------------------------------------

# -------------------------- btop --------------------------
install_btop_by_brew() {
    print -c blue "==== installing btop by brew......"
    brew install btop
    print -c blue "==== btop installed."
}
install_btop_by_binary() {
    print -c blue "==== installing btop by binary......"
    ido download_github_release aristocratos/btop $tdir linux $arch
    ido tar -xjf $tdir/btop-*.tbz -C $tdir
    ido cp $tdir/btop/bin/btop ~/.local/bin/btop
    ido mkdir -p ~/.config/btop
    ido cp -r $tdir/btop/themes ~/.config/btop
    print -c blue "btop installed to ~/.local/bin/btop"
    print -c blue "==== btop installed."
}

apt_prepare() {
    print -c blue "requirements before installation"
    ido sudo apt-get update
    ido sudo apt-get install -y git build-essential curl jq python3-pip unzip bc || die "failed to install dependencies"
}

config() {
    # 设置目标 git 仓库地址
    GIT_REPO="https://github.com/uxfion/.config.git"
    GIT_REPO_SSH="git@github.com:uxfion/.config.git"
    CONFIG_DIR="$HOME/.config"

    # 检查 ~/.config 目录是否存在
    if [ ! -d "$CONFIG_DIR" ]; then
        print -c purple "directory $CONFIG_DIR does not exist, creating"
        ido mkdir -p $CONFIG_DIR
    fi

    # cd不能使用id，否则无法改变目录
    cd $CONFIG_DIR

    # 检查当前目录是否是一个 git 仓库
    if ! git rev-parse --is-inside-work-tree > /dev/null 2>&1; then
        print -c blue "init git repo in $CONFIG_DIR"
        ido git init
        ido git remote add origin "$GIT_REPO"
        ido git fetch origin main:main
        ido git branch -u origin/main main
        ido git switch main
        ido git pull
    else
        # 检查设置的远程仓库是否正确
        REMOTE_URL=$(git remote get-url origin)
        if [ "$REMOTE_URL" = "$GIT_REPO" ] || [ "$REMOTE_URL" = "$GIT_REPO_SSH" ]; then
            print -c blue "remote repo already set, pulling"
            print -c purple "nuke working tree"
            ido git reset --hard HEAD
            ido git pull
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
        print -c blue "myrc.sh exists in $CONFIG_FILE, no need to add."
    else
        ido "echo -e "$LINE_TO_ADD" >> $CONFIG_FILE"
        print -c blue "added myrc.sh to $CONFIG_FILE"
    fi
}

main() {
    print -c blue "---------- info ----------"
    detect_os
    print -c blue "OS: $OS"
    print -c blue "arch: $arch"
    detect_network_tool
    detect_brew
    print -c blue "brew: $brew_installed"
    detect_apt
    print -c blue "apt: $apt_installed"
    tdir=$(command mktemp -d "/tmp/config-install-XXXXXXXXXXXX")
    print -c blue "temp dir: $tdir"
    print -c blue "bin dir: ~/.local/bin"
    print -c blue "------- preparing -------"
    if [ "$OS" = "macos" ]; then
        if [ "$brew_installed" = true ]; then
            print -c purple "using brew to install"
            install_yazi_by_brew
            install_nvim_by_brew
            install_lazygit_by_brew
            install_tmux_by_brew
            install_starship_by_brew
            install_btop_by_brew
        else
            die "brew is not installed"
        fi
    elif [ "$OS" = "linux" ]; then
        if [ "$brew_installed" = true ]; then
            print -c purple "using brew to install"
            install_yazi_by_brew
            install_nvim_by_brew
            install_lazygit_by_brew
            install_tmux_by_brew
            install_starship_by_brew
            install_btop_by_brew
        elif [ "$apt_installed" = true ]; then
            print -c purple "using apt and binaries to install"
            apt_prepare
            install_yazi_by_binary
            install_nvim_by_binary
            install_lazygit_by_binary
            install_tmux_by_apt
            install_starship_by_binary
            install_btop_by_binary
        else
            die "brew and apt are not installed"
        fi
    fi
    ido kitten update-self
    print -c blue "------- configuring -------"
    config
    rc
    print -c blue "------- cleaning -------"
    cleanup
    print -c blue "done!"
    print -c blue "please run the following command to apply the changes:"
    print -c purple "source $CONFIG_FILE"
}

main "$@"
# TODO: -m --mirror
