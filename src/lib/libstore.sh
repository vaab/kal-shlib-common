## Begin libstore.sh

include parse
include decorators

store() {
    local scope="$1" store="$2" action="$3"
    shift 3
    fn=store:$scope:$store:$action
    if fn.exists "$fn"; then
        "$fn" "$@"
    else
        die "Store function $fn is not found."
    fi
}


##
## Bash variables session store
##

store:session:vars:has() {
    local key="$1" varname 
    local varname="__cache_store_$key"
    ! [ -z ${!varname+x} ]
}

store:session:vars:get() {
    local key="$1" varname
    local varname="__cache_store_$key"
    unquote-0 "${!varname}"
}

store:session:vars:set() {
    local key="$1" val
    local varname="__cache_store_$key"
    val=$(quote-0 && echo x) || return 1
    export "__cache_store_$key"="${val:: -1}"
}

store:session:vars:del() {
    local key="$1"
    local varname="__cache_store_$key"
    unset "$varname"
}


##
## temporary state directory cmd store
##


:state-dir:() {
    if [ -z "$STATE_DIR" ]; then
        settmpdir "STATE_DIR"
        debug "Setting STATE_DIR to '$state_dir'."
    fi
}


store:session:file:has() {
    :state-dir:
    [ -e "$STATE_DIR/$1" ]
}

store:session:file:get() {
    :state-dir:
    cat "$STATE_DIR/$1" 2>/dev/null
}

store:session:file:set() {
    :state-dir:
    local key="$1"
    cat - > "$STATE_DIR/$1"
}

store:session:file:del() {
    :state-dir:
    local key="$1"
    rm "$STATE_DIR/$1"
}


##
## application cache directory command store
##

:cache-dir: () {
    [ -n "$exname" ] || {
        err "No \$exname set. This is required."
        return 1
    }

    if [ -z "$CACHE_DIR" ]; then
        if [ "$UID" == 0 ]; then
            export CACHE_DIR="/var/cache/$exname"
        else
            export CACHE_DIR="$HOME/.cache/$exname"
        fi
    fi
    mkdir -p "$CACHE_DIR"
}


store:cmd:file:has() {
    :cache-dir:
    [ -e "$CACHE_DIR/cache.$1" ]
}

store:cmd:file:get() {
    :cache-dir:
    cat "$CACHE_DIR/cache.$1" 2>/dev/null
}

store:cmd:file:set() {
    :cache-dir:
    local key="$1"
    cat - > "$CACHE_DIR/cache.$1"
}

store:cmd:file:del() {
    :cache-dir:
    local key="$1"
    rm "$CACHE_DIR/cache.$1"
}


## End libstore.sh
