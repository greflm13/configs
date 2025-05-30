#!/bin/bash

bashrc="$(curl -Ssl 'https://raw.githubusercontent.com/greflm13/configs/refs/heads/main/.bashrc.server')"
vimrc="$(curl -Ssl 'https://raw.githubusercontent.com/greflm13/configs/refs/heads/main/.vimrc')"

echo "$bashrc" | ssh $1 -T 'cat > ${HOME}/.bashrc'
echo "$vimrc" | ssh $1 -T 'cat > ${HOME}/.vimrc'
