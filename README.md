# Step
## A. Install zsh
1. Follow instruction [here link](https://ohmyz.sh/#install)
2. Copy .zshrc if needed
## B. Set Bash script
1. Copy all the bash file that i use to search for folder project and open new tmux session to folder local/scripts
2. in my .zshrc i map it to 'tns', example: tns parameter {m_d => max-depth, s_n => session name, path => path to search}
## B. Tmux
1. Install tmux on local machine
2. Copy tmux.conf to folder .config/tmux
3. Clone TPM (package manager for tmux) git clone https://github.com/tmux-plugins/tpm ~/.tmux/plugins/tpm
4. Run tmux open tmux.conf prefix + I ( prefix = ctrl + b in my tmux.conf)
5. Tmux is set
## C.1. Neovim with packer
1. Install neovim
2. Copy nvim folder content to .config/nvim
3. Comment all content of lua/aptha/lazy.lua
4. Uncomment content of lua/aptha/packer.lua
5. install packer (git clone --depth 1 https://github.com/wbthomason/packer.nvim\
 ~/.local/share/nvim/site/pack/packer/start/packer.nvim)
6. Open nvim folder with nvim
7. go to packer.lua
8. source file (:so)
9. install plugin (:PackerSync)
## C.2. Neovim with lazy
1. Install neovim
2. Copy nvim folder content to .config/nvim
4. Open vim and its done
