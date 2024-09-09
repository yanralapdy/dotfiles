# Step
## A. Install zsh
## B. Set Bash script
1. Copy bash to folder local/scripts
2. tns parameter {m_d => max-depth, s_n => session name, path => path to search}
## B. Tmux
1. Install tmux on local machine
2. Copy tmux.conf to folder .config/tmux
3. Clone TPM git clone https://github.com/tmux-plugins/tpm ~/.tmux/plugins/tpm
4. Run tmux open tmux.conf prefix + I
5. Tmux is set
## C. Neovim
1. Install neovim
2. Copy nvim folder content to .config/nvim
3. install packer (git clone --depth 1 https://github.com/wbthomason/packer.nvim\
 ~/.local/share/nvim/site/pack/packer/start/packer.nvim)
4. Open nvim folder with nvim
5. go to packer.lua
6. source file (:so)
7. install plugin (:PackerSync)
