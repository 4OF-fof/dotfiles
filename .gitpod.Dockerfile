FROM gitpod/workspace-base

RUN sudo apt remove -y tmux
RUN brew install fish tmux fzf exa nvim