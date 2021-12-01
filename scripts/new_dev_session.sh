#!/bin/bash

ID=$(echo $(( $(echo -e "\
  $(vim --serverlist | tr -d "^VIM-")\n0" | sort -n -r | head -n 1) + 1)))
tmux new-session -d -s "DEV-"${1} -c "#{pane_current_path}"
tmux switch-client -t "DEV-"${1}
tmux send-keys "/opt/scripts/explorer_vim_server.sh ${ID}" ENTER
tmux split-window -h -b -l 15% -c "#{pane_current_path}"
tmux send-keys "/opt/scripts/explorer_vim_remote.sh ${ID}" ENTER
tmux select-pane -t 2
tmux split-window -v -l 20% -c "#{pane_current_path}"
tmux send-keys 'tig' ENTER
