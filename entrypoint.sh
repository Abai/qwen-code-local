#!/bin/bash

set -e

cd $HOME

# Download or find existing model
python3 hf_download.py

# Launch llama-server in tmux
echo set-option -g default-shell /bin/bash >> .tmux.conf
tmux new -s llama-server -d
tmux rename-window -t llama-server $HF_MODEL
tmux send-keys -t llama-server 'cd /app; ./llama-server --prio 3 --temp $LLAMA_SAMPLING_TEMPERATURE --min-p $LLAMA_SAMPLING_MIN_P --top-p $LLAMA_SAMPLING_TOP_P --top-k $LLAMA_SAMPLING_TOP_K --repeat-penalty $LLAMA_SAMPLING_REPETITION_PENALTY --chat-template-file $HF_CHAT_TEMPLATE'  C-m  #--verbose --log-file $HOME/llama-server.log' C-m
echo 'Loading model ...'
sleep 3

# Lauch terminal to work in
/bin/bash

# Shutdown llama-server
tmux send-keys -t llama-server C-c
echo 'Shutting down llama-server ...'
sleep 2
tmux kill-session -t llama-server
