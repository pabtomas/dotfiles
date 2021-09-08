redshift -x
redshift -O 5500k

cd () {
    command cd "$@"
    TREE=$(ls -a -1 --color | sed "s/^/- /g")
    TREE_HEIGHT=$(echo -e "$TREE" | wc -l)
    TREE=$(echo -e "$TREE" | tail -n $(($TREE_HEIGHT - 2)))
    ((TREE_HEIGHT-2))
    TERM_HEIGHT=$LINES
    [ $TMUX ] && ((TERM_HEIGHT-=2))
    if [ $TREE_HEIGHT -lt $TERM_HEIGHT ]; then
        echo -e "$TREE"
    else
        echo -e "$TREE" | less -r -X
    fi
}
