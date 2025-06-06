#!/bin/bash

source <(curl -s https://raw.githubusercontent.com/uxfion/.config/main/bin/print)
source <(curl -s https://raw.githubusercontent.com/uxfion/.config/main/bin/ido)
source <(curl -s https://raw.githubusercontent.com/uxfion/.config/main/bin/download_github_release)

# Add usage function
usage() {
    cat << EOF
Usage: $0 [-m|--min] [-h|--help]

Options:
    -m, --min     Minimal installation (only binary downloads, no package manager operations)
    -h, --help    Show this help message
EOF
    exit 1
}

# Parse command line arguments
MINIMAL_INSTALL=false

while [[ $# -gt 0 ]]; do
    case $1 in
        -m|--min)
            MINIMAL_INSTALL=true
            shift
            ;;
        -h|--help)
            usage
            ;;
        *)
            echo "Unknown option: $1"
            usage
            ;;
    esac
done

tdir=''
cleanup() {
    [ -n "$tdir" ] && {
        command rm -rf "$tdir"
        print -c green "cleaned up temp dir $tdir"
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

detect_arch_os() {
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

detect_package_manager() {
    # 需要0.3-0.4G空间。最小安装模式下不需要包管理器。
    # require file git jq unzip tar bash curl wget xz-utils(xz) bzip2
    if [ "$MINIMAL_INSTALL" = true ]; then
        PACKAGE_MANAGER="none"
        return 0
    fi

    if command -v brew > /dev/null 2>&1; then
        PACKAGE_MANAGER="brew"
    elif command -v apt > /dev/null 2>&1; then
        PACKAGE_MANAGER="apt"
    elif command -v apk > /dev/null 2>&1; then
        PACKAGE_MANAGER="apk"
    else
        die "No supported package manager found. Use -m or --min for minimal installation mode."
    fi
    # print -c green "Package Manager: $PACKAGE_MANAGER"
}

# -------------------------- yazi --------------------------
download_yazi_binary() {
    if [ "$arch" = "x86_64" ]; then
        ido download_github_release sxyazi/yazi $tdir linux x86_64 musl
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

# download_ffmpeg_binary_github() {
#     if [ "$arch" = "x86_64" ]; then
#         ido download_github_release eugeneware/ffmpeg-static $tdir ffmpeg linux x64 -e gz  # static
#         ido download_github_release eugeneware/ffmpeg-static $tdir ffprobe linux x64 -e gz
#     elif [ "$arch" = "aarch64" ]; then
#         ido download_github_release eugeneware/ffmpeg-static $tdir ffmpeg linux arm64 -e gz
#         ido download_github_release eugeneware/ffmpeg-static $tdir ffprobe linux arm64 -e gz
#     fi
#     ido cp $tdir/ffmpeg* ~/.local/bin/ffmpeg
#     ido cp $tdir/ffprobe* ~/.local/bin/ffprobe
#     ido chmod +x ~/.local/bin/ffmpeg
#     ido chmod +x ~/.local/bin/ffprobe
# }

download_ffmpeg_binary() {
    if [ "$arch" = "x86_64" ]; then
        ido wget https://johnvansickle.com/ffmpeg/releases/ffmpeg-release-amd64-static.tar.xz -P $tdir
    elif [ "$arch" = "aarch64" ]; then
        ido wget https://johnvansickle.com/ffmpeg/releases/ffmpeg-release-arm64-static.tar.xz -P $tdir
    fi
    ido tar -xJf $tdir/ffmpeg*.tar.xz -C $tdir
    ido cp $tdir/ffmpeg*/ffmpeg ~/.local/bin/ffmpeg
    ido cp $tdir/ffmpeg*/ffprobe ~/.local/bin/ffprobe
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
    ido tar -xJf $tdir/7z*.tar.xz -C $tdir/7zip
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

download_fd_binary() {
    if [ "$arch" = "x86_64" ]; then
        ido download_github_release sharkdp/fd $tdir linux x86_64 musl  # static
    elif [ "$arch" = "aarch64" ]; then
        ido download_github_release sharkdp/fd $tdir linux aarch64 musl
    fi
    ido tar -xzf $tdir/fd-*.tar.gz -C $tdir
    ido cp $tdir/fd-*/fd ~/.local/bin/fd
    ido chmod +x ~/.local/bin/fd
}

download_ripgrep_binary() {
    if [ "$arch" = "x86_64" ]; then
        ido download_github_release BurntSushi/ripgrep $tdir linux x86_64 musl -e sha256  # static
    elif [ "$arch" = "aarch64" ]; then
        ido download_github_release BurntSushi/ripgrep $tdir linux aarch64 gnu -e sha256  # arm64只有gnu的，没有musl
    fi
    ido tar -xzf $tdir/ripgrep-*.tar.gz -C $tdir
    ido cp $tdir/ripgrep-*/rg ~/.local/bin/rg
    ido chmod +x ~/.local/bin/rg
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
#     ido cp $tdir/ImageMagick-*.AppImage ~/.local/bin/imagemagick.appimage
#     ido "chmod +x ~/.local/bin/imagemagick.appimage && ln -sf ~/.local/bin/imagemagick.appimage ~/.local/bin/magick"
# }

download_bat_binary() {
    if [ "$arch" = "x86_64" ]; then
        ido download_github_release sharkdp/bat $tdir linux x86_64 musl
    elif [ "$arch" = "aarch64" ]; then
        ido download_github_release sharkdp/bat $tdir linux aarch64 musl
    fi
    ido tar -xzf $tdir/bat-*.tar.gz -C $tdir
    ido cp $tdir/bat-*/bat ~/.local/bin/bat
    ido chmod +x ~/.local/bin/bat
}

download_lazygit_binary() {
    if [ "$arch" = "x86_64" ]; then
        ido download_github_release jesseduffield/lazygit $tdir linux x86_64  # static
    elif [ "$arch" = "aarch64" ]; then
        ido download_github_release jesseduffield/lazygit $tdir linux arm64
    fi
    ido tar -xzf $tdir/lazygit_*.tar.gz -C $tdir lazygit
    ido cp $tdir/lazygit ~/.local/bin/lazygit
    ido chmod +x ~/.local/bin/lazygit
}

download_zoxide_script() {
    print -c green "installing zoxide by script..."
    ido "curl -sSfL https://raw.githubusercontent.com/ajeetdsouza/zoxide/main/install.sh | sh" || die "failed to install zoxide"
    find /tmp -type d -name 'tmp.*' -prune -exec sh -c '[ -f "$1/zoxide" ] || [ -z "$(ls -A "$1")" ] && rm -rf "$1" && echo "Deleted: $1"' _ {} \;  # 删除包含 zoxide 文件的目录，以及那些空的 tmp.XXX 开头的目录
    print -c green "cleaned up zoxide tmp dirs"
}

install_yazi() {
    print -c green "==== installing yazi..."
    if [ "$MINIMAL_INSTALL" = false ]; then
        case "$PACKAGE_MANAGER" in
            brew)
                # ffmpegthumbnailer unar
                ido brew update
                ido brew install yazi ffmpeg sevenzip jq poppler fd ripgrep fzf zoxide imagemagick bat clipboard lazygit || die "failed to install yazi and deps"
                print -c green "==== yazi installed!"
                return 0
                ;;
            apt)
                ido sudo apt-get update
                ido sudo apt-get install -y file || die "failed to install file"
                ;;
            apk)
                ido apk update
                ido apk add file || die "failed to install file"
                ;;
            *)
                die "Unsupported package manager: $PACKAGE_MANAGER"
                ;;
        esac
    fi

    # apt要卸载： apt autoremove ffmpeg ffmpegthumbnailer unar fd-find ripgrep fzf bat
    # binary要安装： ffmpeg 7zip jq fd ripgrep fzf

    download_yazi_binary || die "failed to download yazi binary"
    print -c green "yazi installed to ~/.local/bin/yazi"

    download_ffmpeg_binary || die "failed to download ffmpeg binary"
    print -c green "ffmpeg and ffprobe installed to ~/.local/bin/ffmpeg ffprobe"

    download_7zip_binary || die "failed to download 7-zip binary"
    print -c green "7-zip installed to ~/.local/bin/7zz"

    download_jq_binary || die "failed to download jq binary"
    print -c green "jq installed to ~/.local/bin/jq"

    # TODO: poppler

    download_fd_binary || die "failed to download fd binary"
    print -c green "fd installed to ~/.local/bin/fd"

    download_ripgrep_binary || die "failed to download ripgrep binary"
    print -c green "ripgrep installed to ~/.local/bin/rg"

    download_fzf_binary || die "failed to download fzf binary"
    print -c green "fzf installed to ~/.local/bin/fzf"

    download_zoxide_script || die "failed to install zoxide"
    print -c green "zoxide installed to ~/.local/bin/zoxide"

    # TODO: imagemagick

    download_bat_binary || die "failed to download bat binary"
    print -c green "bat installed to ~/.local/bin/bat"

    # clipboard在vps上没必要，只需要在pc上安装即可，brew或者scoop
    
    download_lazygit_binary || die "failed to download lazygit binary"
    print -c green "lazygit installed to ~/.local/bin/lazygit"

    print -c green "==== yazi installed!"
}
# ----------------------------------------------------------

# -------------------------- lazyvim --------------------------
download_nvim_appimage() {
    if [ "$arch" = "x86_64" ]; then
        ido download_github_release neovim/neovim $tdir linux x86_64 appimage -e sha256 -e zsync
        ido cp $tdir/nvim-*.appimage ~/.local/bin/nvim.appimage
    elif [ "$arch" = "aarch64" ]; then
        ido download_github_release matsuu/neovim-aarch64-appimage $tdir
        ido cp $tdir/nvim-*aarch64.appimage ~/.local/bin/nvim.appimage
        # TODO: GLIBC_2.38 not found
        # ido download_github_release neovim/neovim $tdir linux arm64 appimage -e sha256 -e zsync
    fi
    
    ido "chmod +x ~/.local/bin/nvim.appimage && ln -sf ~/.local/bin/nvim.appimage ~/.local/bin/nvim"
}

install_lazyvim() {
    if [ "$MINIMAL_INSTALL" = true ]; then
        print -c green "==== installing neovim (minimal)..."
        # 纯二进制安装，不依赖包管理器，只需要 appimage
        download_nvim_appimage || die "failed to download nvim appimage"
        print -c green "==== neovim installed!"
        return 0
    fi

    print -c green "==== installing lazyvim..."
    case "$PACKAGE_MANAGER" in
        brew)
            # 已在yazi中安装了 lazygit fd ripgrep
            ido brew update
            ido brew install nvim node@20 || die "failed to install lazyvim and deps"
            ido brew link --overwrite node@20
            # 不确定需不需要
            # ido npm install -g neovim
            # ido pip install pynvim
            ;;
        apt)
            ido sudo apt-get update
            ido sudo apt-get install -y libfuse2 || die "failed to install libfuse2"
            # TODO: 高于ubuntu24需要libfuse2t64，https://github.com/AppImage/AppImageKit/wiki/FUSE#type-2-appimage
            download_nvim_appimage || die "failed to download nvim appimage"
            print -c green "nvim installed to ~/.local/bin/nvim"
            ido "curl -fsSL https://deb.nodesource.com/setup_20.x | sudo -E bash -" || die "failed to setup nodejs repository"
            ido sudo apt-get install -y nodejs || die "failed to install nodejs"
            # ido npm install -g neovim
            # ido pip install pynvim
            ;;
        apk)
            ido apk update
            ido apk add neovim nodejs npm || die "failed to install lazyvim and deps"
            # ido npm install -g neovim
            # ido pip install pynvim
            ;;
        *)
            die "Unsupported package manager: $PACKAGE_MANAGER"
            ;;
    esac
    print -c green "==== lazyvim installed!"
}
# ----------------------------------------------------------



# -------------------------- tools --------------------------
download_tmux_binary() {
    if [ "$arch" = "x86_64" ]; then
        ido download_github_release pythops/tmux-linux-binary $tdir x86_64
    elif [ "$arch" = "aarch64" ]; then
        ido download_github_release pythops/tmux-linux-binary $tdir arm64
    fi
    ido cp $tdir/tmux-linux-* ~/.local/bin/tmux
    ido chmod +x ~/.local/bin/tmux
}

download_btop_binary() {
    if [ "$arch" = "x86_64" ]; then
        ido download_github_release aristocratos/btop $tdir linux x86_64  # static
    elif [ "$arch" = "aarch64" ]; then
        ido download_github_release aristocratos/btop $tdir linux aarch64  # static
    fi
    ido tar -xjf $tdir/btop-*.tbz -C $tdir
    ido cp $tdir/btop/bin/btop ~/.local/bin/btop
    ido chmod +x ~/.local/bin/btop
    # ido mkdir -p ~/.config/btop
    # ido cp -r $tdir/btop/themes ~/.config/btop
}

download_xh_binary() {
    if [ "$arch" = "x86_64" ]; then
        ido download_github_release ducaale/xh $tdir linux x86_64  # static
    elif [ "$arch" = "aarch64" ]; then
        ido download_github_release ducaale/xh $tdir linux aarch64  # static
    fi
    ido tar -xzf $tdir/xh-*.tar.gz -C $tdir
    ido cp $tdir/xh-*/xh ~/.local/bin/xh
    ido chmod +x ~/.local/bin/xh
}

download_lazydocker_binary() {
    if [ "$arch" = "x86_64" ]; then
        ido download_github_release jesseduffield/lazydocker $tdir linux x86_64
    elif [ "$arch" = "aarch64" ]; then
        ido download_github_release jesseduffield/lazydocker $tdir linux arm64
    fi
    ido tar -xzf $tdir/lazydocker_*.tar.gz -C $tdir lazydocker  # 提取出来没有文件夹，所以只提取bin
    ido cp $tdir/lazydocker ~/.local/bin/lazydocker
    ido chmod +x ~/.local/bin/lazydocker
}

install_tools() {
    print -c green "==== installing tools..."
    if [ "$MINIMAL_INSTALL" = false ]; then
        case "$PACKAGE_MANAGER" in
            brew)
                ido brew update
                # brew don't have reptyr
                ido brew install tmux starship btop xh || die "failed to install tools"
                ido brew install lazydocker || die "failed to install lazydocker"
                ido kitten update-self
                print -c green "==== tools installed!"
                return 0
                # brew到这里结束，不走下去
                ;;
            apt)
                ido sudo apt-get update
                # TODO: arm64 ubuntu没有reptyr
                # ido sudo apt-get install -y reptyr || die "failed to install reptyr"
                ;;
            apk)
                ido apk update
                ido apk add tmux reptyr || die "failed to install tmux and reptyr"
                ;;
            *)
                die "Unsupported package manager: $PACKAGE_MANAGER"
                ;;
        esac
    fi

    ido "curl -sS https://starship.rs/install.sh | sh -s -- -b ~/.local/bin -y" || print -c red "failed to install starship"  # static

    download_tmux_binary || die "failed to download tmux binary"
    print -c green "tmux installed to ~/.local/bin/tmux"

    download_btop_binary || die "failed to download btop binary"
    print -c green "btop installed to ~/.local/bin/btop"

    download_xh_binary || die "failed to download xh binary"
    print -c green "xh installed to ~/.local/bin/xh"

    download_lazydocker_binary || die "failed to download lazydocker binary"
    print -c green "lazydocker installed to ~/.local/bin/lazydocker"

    # TODO: neofetch(?), iftop(?)

    ido kitten update-self
    print -c green "==== tools installed!"
}
# ----------------------------------------------------------

prepare() {
    print -c green "prepare requirements before installation..."
    if [ "$MINIMAL_INSTALL" = false ]; then
        case "$PACKAGE_MANAGER" in
            brew)
                ido brew install curl wget git jq unzip || die "failed to install prepare deps"
                ;;
            apt)
                ido sudo apt-get update
                ido sudo apt-get install -y curl wget git jq unzip tar build-essential python3 python3-pip || die "failed to install prepare deps"
                ;;
            apk)
                ido apk update
                ido apk add bash curl wget git jq unzip tar xz || die "failed to install prepare deps"
                ;;
            *)
                die "Unsupported package manager: $PACKAGE_MANAGER"
                ;;
        esac
    fi
    ido mkdir -p ~/.local/bin
    ido mkdir -p ~/.config
    print -c green "prepare requirements installed!"
}

config() {
    # 设置目标 git 仓库地址
    GIT_REPO="https://github.com/uxfion/.config.git"
    GIT_REPO_SSH="git@github.com:uxfion/.config.git"
    CONFIG_DIR="$HOME/.config"

    # 检查 ~/.config 目录是否存在
    if [ ! -d "$CONFIG_DIR" ]; then
        print -c green "directory $CONFIG_DIR does not exist, creating"
        ido mkdir -p $CONFIG_DIR
    fi

    # cd不能使用ido，否则无法改变目录
    cd $CONFIG_DIR

    # 检查当前目录是否是一个 git 仓库
    if ! git rev-parse --is-inside-work-tree > /dev/null 2>&1; then
        print -c green "init git repo in $CONFIG_DIR"
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
            print -c green "remote repo already set, pulling"
            print -c purple "nuke working tree"
            ido git reset --hard HEAD
            ido git pull
        else
            die "remote repo does not match, exiting"
        fi
    fi
    
    if [ "$MINIMAL_INSTALL" = true ]; then
        print -c purple "minimal install, remove lazyvim config"
        ido rm -rf $CONFIG_DIR/nvim.bak
        ido mv $CONFIG_DIR/nvim $CONFIG_DIR/nvim.bak
    fi
}

rc() {
    LINE_TO_ADD='if [ -f ~/.config/myrc.sh ]; then
    source ~/.config/myrc.sh
fi'

    case "$SHELL" in
        *zsh)
            RC_FILE="$HOME/.zshrc"
            ;;
        *bash)
            RC_FILE="$HOME/.bashrc"
            ;;
        *)
            print -c purple "Unsupported shell type: \$SHELL -> $SHELL \$0 -> $0"
            print -c purple "please add the following line to your shell rc file manually, and source it:"
            print -c cyan "\n
cat << EOF >> ~/.bashrc
$LINE_TO_ADD
EOF

source ~/.bashrc
\n"
            return 1
            ;;
    esac

    if [ ! -f "$RC_FILE" ]; then
        print -c green "$RC_FILE does not exist. Creating it."
        ido touch $RC_FILE
    fi

    if grep -qF -- "source ~/.config/myrc.sh" "$RC_FILE"; then
        print -c green "myrc.sh exists in $RC_FILE, no need to add."
    else
        ido "cat << EOF >> $RC_FILE
$LINE_TO_ADD
EOF"
        print -c green "added myrc.sh to $RC_FILE"
    fi
    print -c green "please run the following command to apply the changes:"
    print -c purple "source $RC_FILE"
}

main() {
    print -c green "---------- info ----------"
    detect_arch_os
    print -c green "OS: $OS"
    print -c green "arch: $arch"
    detect_network_tool
    detect_package_manager
    print -c green "package manager: $PACKAGE_MANAGER"
    print -c purple "minimal install: $MINIMAL_INSTALL"

    tdir=$(command mktemp -d "/tmp/config-install-XXXXXXXXXXXX")
    print -c green "temp dir: $tdir"
    print -c green "bin dir: $HOME/.local/bin"

    print -c green "------- preparing -------"
    prepare

    print -c green "------- installing -------"
    install_yazi
    install_lazyvim
    install_tools
    
    print -c green "------- configuring -------"
    config
    rc

    print -c green "------- cleaning -------"
    cleanup

    print -c green "------- done! -------"
}

main "$@"
# TODO: -m --mirror
