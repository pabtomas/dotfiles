redshift -x
redshift -O 5500k

function __cd__() {
    local LS=($(ls -a -1 --color))
    local LS=(${LS[@]:2})
    set -o noglob
    IFS=$'\n'
    local LINKS=($(ls -la --color))
    set +o noglob
    local LINKS=(${LINKS[@]:3})
    TREE=()
    for I in $(seq 0 $((${#LS[@]} - 1))); do
        local LINE="- "${LINKS[$I]/*${LS[$I]}/${LS[$I]}}
        TREE+=($LINE)
    done
}

function cd() {
    command cd "$@"
    if [ $? -eq 0 ]; then
        {
            __cd__ &
            __CD__PID=$!
            wait $__CD__PID
            fg
        } > /dev/null 2>&1
        __cd__
        if [ ${#TREE[@]} -gt 0 ]; then
            printf "%s\n" "${TREE[@]}" | less -r -F -X
            unset TREE
        fi
    fi
}
