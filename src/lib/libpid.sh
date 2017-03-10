## Begin libpid.sh


pid.get_pgid() {
    local pid="$1"
    ps -o pgid= "$pid" 2>/dev/null | egrep -o "[0-9]+"
}

pid.get_ppid() {
    local pid="$1"
    ps -o ppid= "$pid" 2>/dev/null | egrep -o "[0-9]+"
}

pid.get_child_pids() {
    local pid="$1"
    ps -ax -o ppid,pid --no-headers | sed -r 's/^ +//g;s/ +/ /g' |
        grep "^$pid " | cut -f 2 -d " "
}

pid.get_group_pids() {
    local pid="$1"
    ps -ax -o pgid,pid --no-headers | sed -r 's/^ +//g;s/ +/ /g' |
        grep "^$pid " | cut -f 2 -d " "
}

pid.get_rec_group_pids() {
    local pids=("$@") pid pids_done sub_pids
    declare -A pids_done=()
    while (("${#pids[@]}")); do
        pid="${pids[0]}"
        pids=("${pids[@]:1}")
        [ "${pids_done[$pid]}" ] && continue
        echo "$pid"
        sub_pids=$(pid.get_group_pids "$pid")
        pids+=($sub_pids)
        pids_done[$pid]=1
    done
}

pid.get_rec_child_pids() {
    local pids=("$@") pid pids_done sub_pids
    declare -A pids_done=()
    while (("${#pids[@]}")); do
        pid="${pids[0]}"
        pids=("${pids[@]:1}")
        [ "${pids_done[$pid]}" ] && continue
        echo "$pid"
        sub_pids=$(pid.get_child_pids "$pid")
        pids+=($sub_pids)
        pids_done[$pid]=1
    done
}

pid.show() {
    local pids=("$@") pid
    ps ax -o pgid,ppid,pid,command -q "$(echo ${pids[*]})" --no-headers
}

## End libcla.sh