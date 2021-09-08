redshift -x
redshift -O 5500k

cd () {
    command cd "$@"
    TREE=$(ls -a -1 --color | sed "s/^/- /g")
    TREE_HEIGHT=$(echo -e "$TREE" | wc -l)
    TREE=$(echo -e "$TREE" | tail -n $(($TREE_HEIGHT - 2)))
    echo -e "$TREE" | less -r -F -X
}
