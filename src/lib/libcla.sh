## Begin libcla.sh


cla.normalize() {
    local letters arg i
    while [ "$#" != 0 ]; do
        arg=$1
        case "$arg" in
            --*=*|-*=*)
                shift
                set -- "${arg%%=*}" "${arg#*=}" "$@"
                continue
                ;;
            --*)
                echo -n "$arg"
                echo -en '\0'
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
                    echo -n "$arg"
                    echo -en '\0'
                fi
                ;;
            *)
                echo -n "$arg"
                echo -en '\0'
                ;;
        esac
        shift
    done
}


## End libcla.sh