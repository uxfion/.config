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
    printf "\033[34m%s\033[m\n\r" "$*" > /dev/stderr;
}

detect_network_tool() {
    if command -v curl 2> /dev/null > /dev/null; then
        fetch() {
            command curl -fL "$1"
        }
        fetch_quiet() {
            command curl -fsSL "$1"
        }
    elif command -v wget 2> /dev/null > /dev/null; then
        fetch() {
            command wget -O- "$1"
        }
        fetch_quiet() {
            command wget --quiet -O- "$1"
        }
    else
        die "Neither curl nor wget available, cannot download"
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
                aarch64*) arch="aarch64";;
                armv8*) arch="arm64";;
                i386) arch="i686";;
                i686) arch="i686";;
                *) die "Unknown CPU architecture $(command uname -m)";;
            esac
            ;;
        *) die "binaries are not available for $(command uname)"
    esac
}

detect_brew() {
    if command -v brew 2> /dev/null > /dev/null; then
        brew_installed=true
    else
        brew_installed=false
    fi
}

detect_apt() {
    if command -v apt 2> /dev/null > /dev/null; then
        apt_installed=true
    else
        apt_installed=false
    fi
}

install_yazi_by_brew() {
    log "installing yazi and dependencies by brew"
    packages=(yazi ffmpegthumbnailer unar jq poppler fd ripgrep fzf zoxide)
    for package in "${packages[@]}"; do
        log "installing $package"
        for attempt in {1..2}; do
            if brew install "$package" 2> /dev/null > /dev/null; then
                break
            elif [ "$attempt" -eq 2 ]; then
                die "failed to install $package after 2 attempts"
            fi
            log "retrying to install $package"
        done
    done
}

download_yazi_binary() {
    local _arch="$1"
    local _releases_url="https://api.github.com/repos/sxyazi/yazi/releases/latest"
    local _releases
    _releases=$(fetch_quiet "$_releases_url")
    _package_url="$(echo "${_releases}" | grep "browser_download_url" | cut -d '"' -f 4 | grep "${_arch}" | grep "linux-gnu.zip")"

    fetch "$_package_url" > "$tdir/yazi.zip" || die "failed to download: $_package_url"
    unzip -j -d "$tdir/yazi/" "$tdir/yazi.zip" > /dev/null 2>&1
    cp "$tdir/yazi/yazi" ~/.local/bin/yazi
}

install_yazi_by_apt() {
    log "installing yazi and dependencies by apt"
    if [ "$arch" = "x86_64" ] || [ "$arch" = "aarch64" ]; then
        log "installing yazi $arch binary"
        download_yazi_binary "$arch"
        log "yazi installed to ~/.local/bin/yazi"
        log "installing yazi dependencies"
        sudo apt update > /dev/null 2>&1 && sudo apt install -y file unar jq fd-find ripgrep fzf ffmpegthumbnailer poppler-utils > /dev/null 2>&1 || die "failed to install dependencies"
        log "yazi and dependencies installed"
        log "installing zoxide"
        curl -sS https://raw.githubusercontent.com/ajeetdsouza/zoxide/main/install.sh | bash
        log "zoxide installed to ~/.local/bin/zoxide"
        log "yazi and dependencies installed"
    else
        die "unknown CPU architecture $arch"
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
    log "------- processing -------"
    if [ "$OS" = "macos" ]; then
        if [ "$brew_installed" = true ]; then
            log "using brew to install"
            install_yazi_by_brew
        else
            die "brew is not installed"
        fi
    elif [ "$OS" = "linux" ]; then
        if [ "$brew_installed" = true ]; then
            log "using brew to install"
            install_yazi_by_brew
        elif [ "$apt_installed" = true ]; then
            log "using apt and binaries to install"
            install_yazi_by_apt
        else
            die "brew and apt are not installed"
        fi
    fi
    cleanup
}

main "$@"