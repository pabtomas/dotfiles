redshift -x
redshift -O 5500k

cd () {
    command cd "$@"
    if [ $(tree -a -L 1 | wc -l) -lt $(echo $(($LINES - 2))) ]; then
        tree -a -L 1
    else
        tree -a -L 1 | less
    fi
}
