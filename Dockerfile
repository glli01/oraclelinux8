FROM ghcr.io/oracle/oraclelinux8-nodejs:20-20231221
USER root
WORKDIR /root

RUN echo 'Setting up packages' \
&& dnf update \
&& dnf install -y \
gcc \
gettext \
gcc-c++ \
cmake \
valgrind \
gdb \ 
zsh 

SHELL ["/usr/bin/zsh", "-c"]
ENV SHELL=zsh

RUN echo 'Setting up rest of packages in zsh' \
&& dnf install -y \
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
docker \
oracle-instantclient-release-el8 \ 
fontconfig \
tmux

RUN echo 'Get Other things' \
&& /usr/bin/zsh -c "$(curl -fsSL https://raw.githubusercontent.com/ohmyzsh/ohmyzsh/master/tools/install.sh)"\
&& /bin/bash -c "$(curl -fsSL https://raw.githubusercontent.com/JetBrains/JetBrainsMono/master/install_manual.sh)"\
&& git clone https://github.com/zsh-users/zsh-autosuggestions ~/.oh-my-zsh/custom/plugins/zsh-autosuggestions\
&& git clone https://github.com/zsh-users/zsh-syntax-highlighting.git ${ZSH_CUSTOM:-~/.oh-my-zsh/custom}/plugins/zsh-syntax-highlighting\
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
&& sudo install lazygit /usr/local/bin \
&& rm -rf lazygit \
&& rm lazygit.tar.gz

# RUN echo 'Setup Neovim' \
# && git clone https://github.com/neovim/neovim \
# && cd neovim \
# && git checkout stable \
# && make CMAKE_BUILD_TYPE=RelWithDebInfo \
# && make install \
# && rm -rf neovim \

RUN echo 'Setup Neovim 0.95.0 from release build' \ 
&& mkdir ~/.neovim \
&& curl -Lo nvim-linux64.tar.gz "https://github.com/neovim/neovim/releases/download/v0.9.5/nvim-linux64.tar.gz" \
&& tar xzvf nvim-linux64.tar.gz \
&& cp -r nvim-linux64/* /usr/local \ 
&& rm -rf nvim-linux64 nvim-linux64.tar.gz

# RUN echo 'Setup Lunarvim' \
# && LV_BRANCH='release-1.3/neovim-0.9' /usr/bin/zsh -c "$(curl -s https://raw.githubusercontent.com/LunarVim/LunarVim/release-1.3/neovim-0.9/utils/installer/install.sh)"
RUN echo 'Setup Lazyvim' \
&& git clone https://github.com/LazyVim/starter ~/.config/nvim

RUN echo 'Add path from Lunarvim setup, vi aliases, and TERM colors'\
&& echo 'export PATH=/root/.local/bin:$PATH' >> ~/.zshenv \
&& echo 'export LANG=en_ES.UTF-8' >> ~/.zshrc  \
# This command makes it so lunarvim can use the correct colors on mac terminals - always opens in tmux.
&& echo '#!/bin/bash\nif [ ! "$TMUX" ]; then tmux attach -t lvim $1 || tmux new -s lvim lvim $1; else lvim $1; fi' >> /usr/local/bin/lunarvimtotmux \
&& chmod +x /usr/local/bin/lunarvimtotmux \
&& echo 'alias vi="lunarvimtotmux"'>> ~/.zshrc \
&& echo 'alias vim="lunarvimtotmux"' >> ~/.zshrc \
&& echo 'export TERM=xterm-256color' >> ~/.zshrc \
&& npm install -g neovim

RUN echo 'Set up tmux' \
&& git clone https://github.com/tmux-plugins/tpm ~/.tmux/plugins/tpm \
&& echo "# List of plugins\n\
set -sg escape-time 0\n\
set -g mouse on\n\
set -g @plugin 'tmux-plugins/tpm'\n\
set -g @plugin 'tmux-plugins/tmux-sensible'\n\
set -g @plugin 'christoomey/vim-tmux-navigator'\n\
set -g @plugin 'catppuccin/tmux'\n\
set -g @catppuccin_flavour 'macchiato'\n\
set -g @plugin 'tmux-plugins/tmux-yank'\n\
set -g base-index 1\n\
set -g pane-base-index 1\n\
set-window-option -g pane-base-index 1\n\
set-option -g renumber-windows on\n\
\n\
set-window-option -g mode-keys vi\n\
bind-key -T copy-mode-vi v send-keys -X begin-selection\n\
bind-key -T copy-mode-vi C-v send-keys -X rectangle-toggle\n\
bind-key -T copy-mode-vi y send-keys -X copy-selection-and-cancel\n\
\n\
run '~/.tmux/plugins/tpm/tpm'" >> ~/.tmux.conf

RUN echo 'Add Tmux plugin to lunar vim to allow shortcuts to persist' \
&& echo "\nlvim.plugins = {\n\
  {\n\
    "\""christoomey/vim-tmux-navigator"\"",\n\
    lazy = false\n\
  },\n\
}" >> ~/.config/lvim/config.lua

RUN echo 'Fixes for oh-my-zsh git and setup bashrc' \
&& echo 'exec /bin/zsh' >> ~/.bashrc

RUN echo 'INSTALL autojump - use with "j" in terminal'\
&& git clone https://github.com/wting/autojump.git \
&& cd autojump \
&& ./install.py \
&& rm -rf ~/autojump \
&& echo '[[ -s /root/.autojump/etc/profile.d/autojump.sh ]] && source /root/.autojump/etc/profile.d/autojump.sh\nautoload -U compinit && compinit -u' >> ~/.zshrc

RUN echo 'Setup oh-my-zsh plugins'

RUN source ~/.zshrc
