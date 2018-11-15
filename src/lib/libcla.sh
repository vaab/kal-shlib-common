## Begin libcla.sh


cla.normalize() {
    local letters arg i
    while [ "$#" != 0 ]; do
        arg=$1
        case "$arg" in
            --)
                printf "%s\0" "$@"
                return 0
                ;;
            --*=*|-*=*)
                shift
                set -- "${arg%%=*}" "${arg#*=}" "$@"
                continue
                ;;
            --*|-?) :;;
            -*)
                letters=${arg:1}
                shift
                i=${#letters}
                while ((i--)); do
                    set -- -${letters:$i:1} "$@"
                done
                continue
                ;;
        esac
        printf "%s\0" "$arg"
        shift
    done
}


## End libcla.sh