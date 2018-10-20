## Begin libcla.sh


cla.normalize() {
    local letters arg i
    while [ "$#" != 0 ]; do
        arg=$1
        case "$arg" in
            --)
                for elt in "$@"; do
                    printf "%s\0" "$elt"
                done
                return 0
                ;;
            --*=*|-*=*)
                shift
                set -- "${arg%%=*}" "${arg#*=}" "$@"
                continue
                ;;
            --*)
                printf "%s\0" "$arg"
                ;;
            -*)
                if [[ "${#arg}" > 2 ]]; then
                    letters=${arg:1}
                    shift
                    i=${#letters}
                    while ((i--)); do
                        set -- -${letters:$i:1} "$@"
                    done
                    continue
                else
                    printf "%s\0" "$arg"
                fi
                ;;
            *)
                printf "%s\0" "$arg"
                ;;
        esac
        shift
    done
}


## End libcla.sh