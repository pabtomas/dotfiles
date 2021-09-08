redshift -x
redshift -O 5500k

cd () {
    command cd "$@" && ls -la
}
