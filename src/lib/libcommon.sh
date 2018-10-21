## Begin libcommon.sh

include color

warn() { echo -en "${YELLOW}Warning:$NORMAL" "$*\n" >&2 ; }
info() { echo -en "${BLUE}II$NORMAL" "$*\n" >&2 ; }
verb() { [ -z "$VERBOSE" ] || echo -en "$*\n" >&2; }
debug() { [ -z "$DEBUG" ] || echo -en "$*\n" >&2; }
err() { echo -en "${RED}Error:$NORMAL" "$*\n" >&2 ; }
die() { err "$@" ; exit 1; }


gnu_options() {
    local i

    for i in "$@" ;do
        if [ "$i" == '--help' ]; then
            print_help
            exit 0
        fi
        if [ "$i" == '--version' ]; then
            print_version
            exit 0
        fi
    done
}


print_version() {
    echo "$exname version $version";
}


print_help() {
    print_version
    echo "$help"
}


print_exit() {
    echo $@
    exit 1
}


print_syntax_error() {
    [ "$*" ] || print_syntax_error "$FUNCNAME: no arguments"
    print_exit "${ERROR}script error:${NORMAL} $@" >&2
}


print_syntax_warning() {
    [ "$*" ] || print_syntax_error "$FUNCNAME: no arguments."
    [ "$exname" ] || print_syntax_error "$FUNCNAME: 'exname' var is null or not defined."
    echo "$exname: ${WARNING}script warning:${NORMAL} $@" >&2
}


print_error() {
    [ "$*" ] || print_syntax_warning "$FUNCNAME: no arguments."
    [ "$exname" ] || print_exit "$FUNCNAME: 'exname' var is null or not defined." >&2
    print_exit "$exname: ${ERROR}error:${NORMAL} $@" >&2
}


print_warning() {
    [ "$*" ] || print_syntax_warning "$FUNCNAME: no arguments."
    [ "$exname" ] || print_syntax_error "$FUNCNAME: 'exname' var is null or not defined."
    echo "$exname: ${WARNING}warning:${NORMAL} $@" >&2
}


print_usage() {
    [ "$usage" ] || print_error "$FUNCNAME: 'usage' variable is not set or empty."
    echo "usage: $usage"
}


invert_list() {
    local newlist

    newlist=" "
    for i in "$@" ; do
        newlist=" $i${newlist}"
    done
    echo $newlist
}


get_path() { (
    IFS=:
    for d in $PATH; do
        filename="$d/$1"
        [ -f "$filename" -a -x "$filename" ] && {
            echo "$d/$1"
            return 0
        }
    done
    return 1
) }


depends() {
    ## Avoid colliding with variables that are created with depends.
    local __i __tr __path __new_name
    __tr=$(get_path "tr")
    test "$__tr" ||
        die "dependency check: couldn't find 'tr' command."

    for __i in "$@"; do
        if ! __path=$(get_path "$__i"); then
            __new_name=$(echo "$__i" | "$__tr" '_' '-')
            if [ "$__new_name" != "$__i" ]; then
                depends "$__new_name"
            else

                print_error "dependency check: couldn't find '$__i' required command."
            fi
        else
            if ! test -z "$__path" ; then
                export "$(echo $__i | "$__tr" -- '- ' '__')"="$__path"
            fi
        fi
    done
}



require() {
    local i path
    for i in "$@"; do
        if ! path=$(get_path "$i"); then
            return 1;
        else
            if ! test -z "$path"; then
                export $i=$path
            fi
        fi
    done
}


check() {
    for i in "$@"; do
        [ "$(type -t "check_$i")" == "function" ] &&
            "check_$i" && continue

        print_error "dependency check: couldn't find 'check_$i' function."
    done
}


check_ls_timestyle() {

    depends ls

    ##  Checking a special option of "ls"
    ##     -ls does accept the --time-style ?

    if ! "$ls" --time-style=+date:%Y%m%d%H%M.%S / >/dev/null 2>&1; then
        print_error "'$ls' doesn't support the --time-style argument, please upgrade your coreutils tools."
    fi
}


print_bytes () {
    local bytes="$1" float unit_level unit _print_bytes_units
    _print_bytes_units=(byte bytes {K,M,G,T,P,E,Z,Y}iB)

    read float unit_level < <(_get_bytes "$bytes")
    read float unit < <(printf "%.2f %s" "$float" "${_print_bytes_units[$unit_level]}")
    if ((unit_level < 2)) && [ "${float:(-3)}" == ".00" ]; then
        float="${float::-3}"
    fi
    echo -n "$float $unit"
}

print_bytes_aligned () {
    local bytes="$1" float unit_level unit _print_bytes_units
    _print_bytes_units=(byte bytes {K,M,G,T,P,E,Z,Y}iB)
    read float unit_level < <(_get_bytes "$bytes")
    IFS=$'\t' read float unit < <(printf "%7.2f\t%s" "$float" "${_print_bytes_units[$unit_level]}")
    if ((unit_level < 2)) && [ "${float:(-3)}" == ".00" ]; then
        float="${float::-3}   "
    fi
    echo -n "$float $unit"
}

## Will round to floor (truncate).
_get_bytes () {
    local bytes="$1" _p _d precision _max_born _unit

    [ "$*" ] || print_syntax_error "$FUNCNAME: no arguments.";
    [ "$2" ] && print_syntax_error "$FUNCNAME: too much arguments.";

    precision=3  ## nb of decimals

    ##singular
    _unit=0
    [ "$bytes" == 0 -o "$bytes" == 1 ] && { echo "$bytes $_unit"; return 0; }
    ((_unit++))
    [ "$bytes" -lt 1024 ] && { echo "$bytes $_unit"; return 0; }
    ((_unit++))

    _max_born=$((2**10 * 10**precision))
    while true; do
        ## multiply by 10^prec and divide by 1024
        _d=10
        _p="$precision"
        while ((_d)); do
            ((bytes % 2 == 1 && _p && (_p--, bytes *= 10)))
            ((bytes /= 2, _d--))
        done
        while ((_p)); do ((_p--, bytes *= 10)); done
        [ "$bytes" -lt $_max_born ] && {
            echo -n "${bytes::(-$precision)}.${bytes:(-$precision)}" "$_unit"
            return 0
        }
        bytes="${bytes::(-$precision)}"
        ((_unit++))
    done
}


## compatibility:
print_octets () {
    print_bytes "$@"
}


is_set() {
    local i val

    for i in "$@"; do
        val=$(eval echo -n \$$i)
        if test -z "$val"; then
            print_error "Variable \$$i is not set."
        fi
    done
    return 0
}


checkfile () {

    [ "$*" ] || print_syntax_error "$FUNCNAME: no arguments."
    [ "$3" ] && print_syntax_error "$FUNCNAME: too much arguments."

    separate=$(echo "$1" | sed_compat 's/(.)/ \1/g')

    for i in $separate; do
        case "$i" in
            "")
                :
                ;;
            "e")
                if ! [ -e "$2" ]; then
                    echo "'$2' is not found."
                    return 1
                fi;;
            "f")
                if ! [ -f "$2" ]; then
                    echo "'$2' is not a regular file."
                    return 1
                fi;;
            "d")
                if ! [ -d "$2" ]; then
                    echo "'$2' is not a directory."
                    return 1
                fi;;
            "r")
                if ! [ -r "$2" ]; then
                    echo "'$2' is not readable."
                    return 1
                fi;;
            "w")
                if ! [ -w "$2" ]; then
                    echo "'$2' is not writable."
                    return 1
                fi;;
            "x")
                if ! [ -x "$2" ]; then
                    echo "'$2' is not executable/openable."
                    return 1
                fi;;
            "l")
                if ! [ -L "$2" ]; then
                    echo "'$2' is not a symbolic link."
                    return 1
                fi;;
        esac
    done

    return 0
}


matches() {
    [ "$*" ] || print_syntax_error "$FUNCNAME: no arguments."
    [ "$3" ] && print_syntax_error "$FUNCNAME: too much arguments."

    echo "$1" | "$grep" "^$2\$" >/dev/null 2>&1
}


find_conf_file() {

    [ "$*" ] || print_syntax_error "$FUNCNAME: no arguments."
    [ "$2" ] && print_syntax_error "$FUNCNAME: too much arguments."

    poss="~/.$1 "

    [ -d "$KAL_CONF_DIR" ] && poss="$KAL_CONF_DIR/$1 $poss"
    [ -d "$KAL_PREFIX" ] && poss="$KAL_PREFIX/etc/$1 $poss"

    poss="/etc/$1 /usr/etc/$1 /usr/local/etc/$1 "

    for i in $poss ; do
        n=$(eval echo "$i")
        if [ -f "$n" -a -r "$n" ]; then
            echo "$n"
            return 0
        fi
    done

    ## return first choice
    for i in $poss ;do
        n=$(eval echo "$i")
        echo "$n"
        return 1
    done
}


str_is_uint() {
    matches "$1" "[0-9]\+"
}


str_is_sint() {
    matches "$1" '\(-\|+\)\?[0-9]\+'
}


str_is_sreal() {
    matches "$1" '\(-\|+\)\?[0-9]\+\(\.[0-9]\+\)\?'
}


str_is_ipv4() {
    ## XXXvlab: not perfect as it will match 929.267829872.2.129782
    matches "$1" '[0-9]\+\.[0-9]\+\.[0-9]\+\.[0-9]\+'
}


_sed_compat_load() {
    if get_path sed >/dev/null; then
        if sed --version >/dev/null 2>&1; then  ## GNU
            sed_compat() { sed -r "$@"; }
            sed_compat_i() { sed -r -i "$@"; }
        else                                    ## BSD
            sed_compat() { sed -E "$@"; }
            sed_compat_i() { sed -E -i "" "$@"; }
        fi
    else
        ## Look for ``gsed``
        if (get_path gsed && gsed --version) >/dev/null 2>&1; then
            sed_compat() { gsed -r "$@"; }
            sed_compat_i() { gsed -r -i "$@"; }
        else
            die "$exname: required GNU or BSD sed not found"
        fi
    fi
}

## BSD / GNU sed compatibility layer
sed_compat() { _sed_compat_load; sed_compat "$@"; }
sed_compat_i() { _sed_compat_load; sed_compat_i "$@"; }


compat_date() {
    if get_path date >/dev/null; then
        if date --version >/dev/null 2>&1 ; then  ## GNU
            compat_date() { date -d "@$1" "$2"; }
        else                                      ## BSD
            compat_date() { date -j -f %s "$1" "$2"; }
        fi
    else
        if (get_path gdate && gdate --version) >/dev/null 2>&1; then
            compat_date() { gdate -d "@$1" "$2"; }
        else
            die "$exname: required GNU or BSD date not found"
        fi
    fi
    compat_date "$1" "$2"
}


md5_compat() {
    if get_path md5sum >/dev/null; then
        md5_compat() { md5sum | cut -c -32; }
    elif get_path md5 >/dev/null; then
        md5_compat() { md5; }
    else
        die "$exname: required GNU or BSD date not found"
    fi
    md5_compat
}


get_perm() {
    depends stat
    if "$stat" --version >/dev/null; then
        get_perm() { "$stat" "$1" -c %a; }
    else
        get_perm() { "$stat" -f %OLp "$1"; }
    fi
}


check_perm() {
    [ "$(get_perm "$1")" == "$2" ]
}


same_contents() {
    "$diff" "$1" "$2" >/dev/null 2>&1
}


is_set() {
    depends printenv
    "$printenv" "$1" >/dev/null 2>&1
}


pause() {
    read -sn1 key
}

uses() {
    for var_decl in "$@"; do
        if ! is_set "$var_decl"; then
            print_error "${FUNCNAME[1]}: required variable '\$$var_decl' is not set."
        fi
    done
}




## appends a command to the signal handler functions
#
# example: trap_add EXIT,INT close_ssh "$ip"
trap_add() {
    local sigs="$1" sig cmd prev_cmd new_cmd
    shift || {
        echo "${FUNCNAME} usage error" >&2
        return 1
    }
    cmd="$@"
    while IFS="," read -d "," sig; do
        [ "$sig" ] || continue
        prev_cmd="$(trap -p "$sig")"
        if [ "$prev_cmd" ]; then
            prev_cmd=$(eval "set -- $prev_cmd"; echo "$3" )
            new_cmd="$cmd"$'\n'"${prev_cmd}"
        else
            new_cmd="$cmd"
        fi
        trap -- "$new_cmd" "$sig" || {
            echo "unable to add command '$@' to trap $sig" >&2
            return 1
        }
    done < <(echo "$sigs,")
}


## prefixes every line from stdin with given command line
prefix() {
    cat -  | sed_compat 's/^(.*)$/'"$*"'\1/g'
}


## self destruct temp dir
settmpdir() {
    local varname="${1:-${exname}_TMPDIR}" var
    var=${!varname}
    [ "$var" ] && {
        debug 'Use given $'"$varname"' variable ('"$var"')'
        return 0
    }
    declare -g $varname=$(mktemp -d)
    trap_add EXIT "rm -rf \"${!varname:?}\" ; debug \"destructed tmp dir ${!varname}.\""
    debug "Temporary directory set up, variable \$$varname ready."
}

common:init() {
    depends basename

    ## We want to force exname in the current session
    # [ -n "$exname" ] || exname="$("$basename" "$0")"
    # [ -n "$fullexname" ] || fullexname="$0"
    exname="$("$basename" "$0")"
    fullexname="$0"

    export exname fullexname
}

## End libcommon.sh
