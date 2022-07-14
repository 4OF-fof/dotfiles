FROM gitpod/workspace-full

RUN sudo apt remove -y tmux \
    && brew install fish tmux fzf exa nvim