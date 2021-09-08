redshift -x
redshift -O 5500k

cd () {
    command cd "$@" && tree -a -L 1
}
