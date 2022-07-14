FROM gitpod/workspace-base

RUN sudo apt remove -y tmux \
    && brew install fish tmux fzf exa nvim