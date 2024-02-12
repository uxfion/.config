# My Config Files

## Modules

- [kitty](https://github.com/kovidgoyal/kitty): `0.32.1`
- [lazyvim](https://github.com/LazyVim/starter): `741ff3aa70336abb6c76ee4c49815ae589a1b852`
- [tmux](https://github.com/gpakosz/.tmux): `b892bc155b6df087b05868995fc6e2cd8b5bbb98`
- [yazi](https://github.com/sxyazi/yazi/tree/main/yazi-config/preset): `0.2.3`

## Installation

```bash
# clean
rm -rf ~/.config/coc ~/.config/ranger
rm -rf ~/.local/share/ranger
rm -rf ~/.config/kitty ~/.config/nvim ~/.config/tmux ~/.config/yazi
rm -rf ~/.local/share/nvim ~/.local/state/nvim ~/.cache/nvim
```

### Font: JetBrains Mono Nerd Font

<details>
<summary><b>Brew</b></summary>

```bash
brew tap homebrew/cask-fonts
brew install font-jetbrains-mono-nerd-font
```

</details>

<details>
<summary><b>Linux</b></summary>

```bash
sudo apt install xxx  # TODO
```

</details>

### Terminal Emulator: Kitty

<details>
<summary><b>Brew</b></summary>

```bash
brew install kitty
```

</details>

<details>
<summary><b>Linux</b></summary>

```bash
curl -L https://sw.kovidgoyal.net/kitty/installer.sh | sh /dev/stdin
```

</details>

### File Manager: Yazi

<details>
<summary><b>Brew</b></summary>

```bash
brew install yazi ffmpegthumbnailer unar jq poppler fd ripgrep fzf zoxide
```

</details>

<details>
<summary><b>Linux</b></summary>

```bash
cd ~/dl && wget https://github.com/sxyazi/yazi/releases/download/v0.2.3/yazi-x86_64-unknown-linux-gnu.zip
unzip yazi-x86_64-unknown-linux-gnu.zip
cp yazi-x86_64-unknown-linux-gnu/yazi /usr/local/bin/
# TODO: requirtments
```

</details>

### Text Editor: LazyVim

<details>
<summary><b>Brew</b></summary>

```bash
brew install nvim rustup fd ripgrep

# test
fd lua  # find file name
rg lua  # find file text

brew install node@20 && brew link --overwrite node@20

npm install -g neovim
pip install pynvim


```

</details>

<details>
<summary><b>Linux</b></summary>

```bash
# nvim
sudo apt install libfuse2
wget https://github.com/neovim/neovim/releases/download/stable/nvim.appimage -O /usr/local/bin/nvim.appimage
chmod +x /usr/local/bin/nvim.appimage && ln -sf /usr/local/bin/nvim.appimage /usr/local/bin/nvim
# TODO: aarch64

# requirements
sudo apt update && sudo apt install -y git build-essential ca-certificates curl gnupg python3-pip
sudo apt install fd-find ripgrep

# test
fd lua  # find file name
rg lua  # find file text

# node
sudo mkdir -p /etc/apt/keyrings
curl -fsSL https://deb.nodesource.com/gpgkey/nodesource-repo.gpg.key | sudo gpg --dearmor -o /etc/apt/keyrings/nodesource.gpg
NODE_MAJOR=20
echo "deb [signed-by=/etc/apt/keyrings/nodesource.gpg] https://deb.nodesource.com/node_$NODE_MAJOR.x nodistro main" | sudo tee /etc/apt/sources.list.d/nodesource.list
sudo apt-get update && sudo apt-get install nodejs -y

# # rust (no necessary)
# # curl --proto '=https' --tlsv1.2 -sSf https://sh.rustup.rs | sh
# # rust fd::fd-find, rg::ripgrep

npm install -g neovim
pip install pynvim
```

</details>

### Git GUI: Lazygit

<details>
<summary><b>Brew</b></summary>

```bash
brew install lazygit
```

</details>

<details>
<summary><b>Linux</b></summary>

```bash
LAZYGIT_VERSION=$(curl -s "https://api.github.com/repos/jesseduffield/lazygit/releases/latest" | grep -Po '"tag_name": "v\K[^"]*')
# amd64
curl -Lo lazygit.tar.gz "https://github.com/jesseduffield/lazygit/releases/latest/download/lazygit_${LAZYGIT_VERSION}_Linux_x86_64.tar.gz"
# arm64
curl -Lo lazygit.tar.gz "https://github.com/jesseduffield/lazygit/releases/latest/download/lazygit_${LAZYGIT_VERSION}_Linux_arm64.tar.gz"

tar xf lazygit.tar.gz lazygit
sudo install lazygit /usr/local/bin
```

</details>

### Tmux

<details>
<summary><b>Brew</b></summary>

```bash
brew install tmux
```

</details>

<details>
<summary><b>Linux</b></summary>

```bash
sudo apt install tmux
tmux -V

# wget https://github.com/nelsonenzo/tmux-appimage/releases/download/3.3a/tmux.appimage -O /usr/local/bin/tmux.appimage
# chmod +x /usr/local/bin/tmux.appimage && ln -sf /usr/local/bin/nvim.appimage /usr/local/bin/nvim
```

</details>

## Config

- First Time

```bash
cd ~/.config
git init && git branch -M main
git remote add origin https://github.com/uxfion/.config.git
git pull origin main
git branch --set-upstream-to=origin/main main
```

- Update

```bash
cd ~/.config && git pull
```
