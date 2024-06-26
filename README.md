# 🛠️ My Config Files

<details>
<summary><h2>🔢 Config Version</h2></summary>

- [🐈 Kitty](https://github.com/kovidgoyal/kitty): `0.32.1`
- [🛌 LazyVim](https://github.com/LazyVim/starter): `741ff3aa70336abb6c76ee4c49815ae589a1b852`
- [🎛️ .tmux](https://github.com/gpakosz/.tmux): `b892bc155b6df087b05868995fc6e2cd8b5bbb98`
- [🦆 Yazi](https://github.com/sxyazi/yazi/tree/main/yazi-config/preset): `0.2.3`

</details>

<details>
<summary><h2>⚙️ Installation</h2></summary>

```bash
# clean
brew uninstall ranger joshuto
sudo apt remove ranger
rm -rf /usr/local/bin/joshuto /usr/local/bin/vim
rm -rf ~/.config/coc ~/.config/ranger ~/.config/joshuto ~/.config/lvim
rm -rf ~/.local/share/ranger ~/.local/share/lunarvim* ~/.local/share/lvim
rm -rf ~/.config/kitty ~/.config/nvim ~/.config/tmux ~/.config/yazi
rm -rf ~/.local/share/nvim ~/.local/state/nvim ~/.cache/nvim
bash ~/.local/share/lunarvim/lvim/utils/installer/uninstall.sh
```

### 1. 📝 Font: [🔤 JetBrains Mono Nerd Font](https://github.com/ryanoasis/nerd-fonts/releases/latest)

<details>
<summary><b>🍺 Brew</b></summary>

```bash
brew tap homebrew/cask-fonts
brew install font-jetbrains-mono-nerd-font
```

</details>

<details>
<summary><b>📟 Linux</b></summary>

```bash
sudo apt install xxx  # TODO
```

</details>

### 2. 📟 Terminal Emulator: [🐈 Kitty](https://sw.kovidgoyal.net/kitty/)

<details>
<summary><b>🍺 Brew</b></summary>

```bash
brew install kitty
```

</details>

<details>
<summary><b>📟 Linux</b></summary>

```bash
curl -L https://sw.kovidgoyal.net/kitty/installer.sh | sh /dev/stdin
```

</details>

### 3. 🗃️ File Manager: [🦆 Yazi](https://yazi-rs.github.io/docs/installation)

<details>
<summary><b>🍺 Brew</b></summary>

```bash
brew install yazi ffmpegthumbnailer unar jq poppler fd ripgrep fzf zoxide

```

</details>

<details>
<summary><b>📟 Linux</b></summary>

```bash
# yazi amd64
mkdir -p ~/dl
cd ~/dl && wget https://github.com/sxyazi/yazi/releases/download/v0.2.3/yazi-x86_64-unknown-linux-gnu.zip
unzip yazi-x86_64-unknown-linux-gnu.zip
cp yazi-x86_64-unknown-linux-gnu/yazi ~/.local/bin/

# yazi aarch64
# cargo install --locked yazi-fm
# # cd ~/dl && wget https://github.com/sxyazi/yazi/releases/download/v0.2.3/yazi-aarch64-unknown-linux-gnu.zip
# # unzip yazi-aarch64-unknown-linux-gnu.zip
# # cp yazi-aarch64-unknown-linux-gnu/yazi ~/.local/bin/
# # TODO: `yazi: /lib/aarch64-linux-gnu/libc.so.6: version `GLIBC_2.33' not found (required by yazi)`

# requirtments
sudo apt update && sudo apt install -y file unar jq fd-find ripgrep fzf

# sudo apt install -y zoxide, recommend using binary
curl -sS https://raw.githubusercontent.com/ajeetdsouza/zoxide/main/install.sh | bash

# no necessary
# sudo apt install -y ffmpegthumbnailer poppler-utils
```

</details>

### 4. ✏️ Text Editor: [🛌 LazyVim](https://www.lazyvim.org/)

<details>
<summary><b>🍺 Brew</b></summary>

```bash
brew install nvim rustup fd ripgrep

brew install node@20 && brew link --overwrite node@20

npm install -g neovim
pip install pynvim
```

</details>

<details>
<summary><b>📟 Linux</b></summary>

```bash
# nvim amd64
sudo apt install libfuse2
wget https://github.com/neovim/neovim/releases/download/stable/nvim.appimage -O ~/.local/bin/nvim.appimage
chmod +x ~/.local/bin/nvim.appimage && ln -sf ~/.local/bin/nvim.appimage ~/.local/bin/nvim

# nvim aarch64
# # git clone https://github.com/neovim/neovim.git
# cd ~/dl/neovim
# git tag -d stable && git pull
# git checkout stable
# rm -r build/
# make CMAKE_BUILD_TYPE=Release
# sudo make install

# requirements
sudo apt update && sudo apt install -y git build-essential ca-certificates curl gnupg python3-pip
sudo apt install fd-find ripgrep

# node
sudo mkdir -p /etc/apt/keyrings
curl -fsSL https://deb.nodesource.com/gpgkey/nodesource-repo.gpg.key | sudo gpg --dearmor -o /etc/apt/keyrings/nodesource.gpg
NODE_MAJOR=20
echo "deb [signed-by=/etc/apt/keyrings/nodesource.gpg] https://deb.nodesource.com/node_$NODE_MAJOR.x nodistro main" | sudo tee /etc/apt/sources.list.d/nodesource.list
sudo apt-get update && sudo apt-get install nodejs -y

# rust (no necessary)
# curl --proto '=https' --tlsv1.2 -sSf https://sh.rustup.rs | sh
# rust fd::fd-find, rg::ripgrep

npm install -g neovim
pip install pynvim
```

</details>

### 5. 🔢 Git GUI: [💤 Lazygit](https://github.com/jesseduffield/lazygit)

<details>
<summary><b>🍺 Brew</b></summary>

```bash
brew install lazygit
```

</details>

<details>
<summary><b>📟 Linux</b></summary>

```bash
LAZYGIT_VERSION=$(curl -s "https://api.github.com/repos/jesseduffield/lazygit/releases/latest" | grep -Po '"tag_name": "v\K[^"]*')
# amd64
curl -Lo lazygit.tar.gz "https://github.com/jesseduffield/lazygit/releases/latest/download/lazygit_${LAZYGIT_VERSION}_Linux_x86_64.tar.gz"
# arm64
# curl -Lo lazygit.tar.gz "https://github.com/jesseduffield/lazygit/releases/latest/download/lazygit_${LAZYGIT_VERSION}_Linux_arm64.tar.gz"

tar xf lazygit.tar.gz lazygit
sudo install lazygit ~/.local/bin
```

</details>

### 6. 📟 Multiplexer: [🎛️ Tmux](https://github.com/tmux/tmux/wiki)

<details>
<summary><b>🍺 Brew</b></summary>

```bash
brew install tmux
```

</details>

<details>
<summary><b>📟 Linux</b></summary>

```bash
sudo apt install tmux
tmux -V

# wget https://github.com/nelsonenzo/tmux-appimage/releases/download/3.3a/tmux.appimage -O /usr/local/bin/tmux.appimage
# chmod +x /usr/local/bin/tmux.appimage && ln -sf /usr/local/bin/nvim.appimage /usr/local/bin/nvim
# TODO: aarch64
```

</details>

</details>

## 🚀 Config

### 1️⃣ Download Config

```bash
mkdir -p ~/.config
cd ~/.config
git init && git branch -M main
git remote add origin https://github.com/uxfion/.config.git
git pull origin main
git branch --set-upstream-to=origin/main main
```

### 2️⃣ Support [🐈 kitty-diff](https://sw.kovidgoyal.net/kitty/kittens/diff/) with Git

`vim ~/.gitconfig`

```bash
[diff]
  tool = kitty
  guitool = kitty.gui
[difftool]
  prompt = false
  trustExitCode = true
[difftool "kitty"]
  cmd = kitten diff $LOCAL $REMOTE
[difftool "kitty.gui"]
  cmd = kitten diff $LOCAL $REMOTE
```

### 3️⃣ Config My Rc

`vim ~/.bashrc` or `vim ~/.zshrc`

```bash
if [ -f ~/.config/myrc.sh ]; then
    source ~/.config/myrc.sh
fi
```

then `source ~/.bashrc` or `source ~/.zshrc`

### 🎉 Update

```bash
cd ~/.config && git pull
```

then `source ~/.config/myrc.sh`


## 🌌 Ultimate

```
# for bash
bash <(curl https://raw.githubusercontent.com/uxfion/.config/main/bin/install.sh)
# curl -L https://github.com/uxfion/.config/raw/main/bin/install.sh | bash


# for zsh
zsh <(curl https://raw.githubusercontent.com/uxfion/.config/main/bin/install.sh)
# curl -L https://github.com/uxfion/.config/raw/main/bin/install.sh | zsh
```