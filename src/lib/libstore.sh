## Begin libstore.sh

include parse


store() {
    local scope="$1" store="$2" action="$3"
    shift 4
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
    varname="__cache_store_$key"
    ! [ -z ${!varname+x} ]
}

store:session:vars:get() {
    local key="$1" varname
    varname="__cache_store_$key"
    unquote-0 "${!varname}"
}

store:session:vars:set() {
    local key="$1"
    varname="__cache_store_$key"
    export __cache_store_$key="$(quote-0)"
}

store:session:vars:del() {
    local key="$1"
    varname="__cache_store_$key"
    unset "$varname"
}


##
## temporary state directory cmd store
##

store:cmd:statedir:has() {
    :statedir:
    [ -e "$STATEDIR/$1" ]
}

store:cmd:statedir:get() {
    :statedir:
    cat "$STATEDIR/$1" 2>/dev/null
}

store:cmd:statedir:set() {
    :statedir:
    local key="$1"
    cat - > "$STATEDIR/$1"
}

store:cmd:statedir:del() {
    :statedir:
    local key="$1"
    rm "$STATEDIR/$1"
}


##
## application cache directory command store
##

store:cmd:file:has() {
    :cache-dir:
    [ -e "$CACHEDIR/cache.$1" ]
}

store:cmd:file:get() {
    :cache-dir:
    cat "$CACHEDIR/cache.$1" 2>/dev/null
}

store:cmd:file:set() {
    :cache-dir:
    local key="$1"
    cat - > "$CACHEDIR/cache.$1"
}

store:cmd:file:del() {
    :cache-dir:
    local key="$1"
    rm "$CACHEDIR/cache.$1"
}


## End libstore.sh
