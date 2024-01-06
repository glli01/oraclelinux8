FROM ghcr.io/oracle/oraclelinux8-nodejs:20-20231221
USER root
WORKDIR /root

RUN echo 'Setting up packages' \
&& yum update \
&& yum install -y \
zsh 

SHELL ["/usr/bin/zsh", "-c"]
ENV SHELL=zsh

RUN echo 'Setting up rest of packages in zsh' \
&& yum install -y \
git \
rsync \
jq \
make \
nano \
vim \
lsof \
unzip \
zip \
python3.11 \
cargo \
sudo \
fontconfig 

RUN echo 'Get Other things' \
&& /usr/bin/zsh -c "$(curl -fsSL https://raw.githubusercontent.com/ohmyzsh/ohmyzsh/master/tools/install.sh)"\
&& /bin/bash -c "$(curl -fsSL https://raw.githubusercontent.com/JetBrains/JetBrainsMono/master/install_manual.sh)"\
&& curl -fsSL https://get.pnpm.io/install.sh | zsh - \
&& source ~/.zshrc

RUN echo 'Setup dev tools' \
&& git clone https://github.com/spaceship-prompt/spaceship-prompt.git "$ZSH_CUSTOM/themes/spaceship-prompt" --depth=1 \
&& ln -s "$ZSH_CUSTOM/themes/spaceship-prompt/spaceship.zsh-theme" "$ZSH_CUSTOM/themes/spaceship.zsh-theme" \
&& git clone --depth 1 https://github.com/junegunn/fzf.git ~/.fzf \
&& ~/.fzf/install \
&& curl -o- https://raw.githubusercontent.com/nvm-sh/nvm/v0.39.7/install.sh | bash \ 
&& LAZYGIT_VERSION=$(curl -s "https://api.github.com/repos/jesseduffield/lazygit/releases/latest" | grep -Po '"tag_name": "v\K[^"]*')\
&& curl -Lo lazygit.tar.gz "https://github.com/jesseduffield/lazygit/releases/latest/download/lazygit_${LAZYGIT_VERSION}_Linux_x86_64.tar.gz" \
&& tar xf lazygit.tar.gz lazygit \
&& sudo install lazygit /usr/local/bin

RUN echo 'Setup Neovim' \
&& yum install -y \
gcc \
gettext \
cmake \
&& git clone https://github.com/neovim/neovim \
&& cd neovim \
&& git checkout stable \
&& make CMAKE_BUILD_TYPE=RelWithDebInfo \
&& make install \
&& rm -rf neovim \
&& LV_BRANCH='release-1.3/neovim-0.9' /usr/bin/zsh -c "$(curl -s https://raw.githubusercontent.com/LunarVim/LunarVim/release-1.3/neovim-0.9/utils/installer/install.sh)"; exit 0

RUN echo 'Add path from Lunarvim setup'\
&& echo 'export PATH=/root/.local/bin:$PATH' >> ~/.zshenv \
&& echo 'export LANG=en_ES.UTF-8' >> ~/.zshrc  \
&& npm install -g neovim

RUN echo 'Fixes for oh-my-zsh git and setup bashrc' \
&& echo 'exec /bin/zsh' >> ~/.bashrc \ 
&& echo 'cd /root/dev' >> ~/.bashrc \
&& echo 'cd /root/dev' >> ~/.zshrc

RUN echo 'INSTALL autojump - use with "j" in terminal'\
&& git clone https://github.com/wting/autojump.git \
&& cd autojump \
&& ./install.py \
&& rm -rf ~/autojump \
&& echo '[[ -s /root/.autojump/etc/profile.d/autojump.sh ]] && source /root/.autojump/etc/profile.d/autojump.sh\nautoload -U compinit && compinit -u' >> ~/.zshrc

RUN source ~/.zshrc