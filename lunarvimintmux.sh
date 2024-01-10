#!/bin/bash
if [ ! "$TMUX" ]; then tmux attach -t lvim $1 || tmux new -s lvim lvim $1; else lvim $1; fi
