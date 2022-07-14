FROM gitpod/workspace-full
RUN sudo apt remove tmux
RUN brew install fish tmux fzf exa nvim