redshift -x
redshift -O 5500k

cd () {
    command cd "$@"
    if [ $? -eq 0 ]; then
        TREE=$(ls -a -1 --color | sed "s/^/- /g")
        TREE_HEIGHT=$(echo -e "$TREE" | wc -l)
        TREE=$(echo -e "$TREE" | tail -n $(($TREE_HEIGHT - 2)))
        if [ $(($TREE_HEIGHT - 2)) -gt 0 ]; then
            echo -e "$TREE" | less -r -F -X
        fi
    fi
}
