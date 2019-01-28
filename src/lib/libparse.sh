## Begin libparse.sh

include common
include color


remove() {
    content=$(cat -)

    while test "$1"; do
	    case "$1" in
	        "comment")
		        content=$(echo "$content" | sed_compat 's/\#.*$//g')
		        ;;
	        "empty-line")
		        content=$(echo "$content" | grep -v "^$")

		        ;;
            "trim-lines")
		        # TODO : DO NOT WORK WITH TABS !!
		        content=$(echo "$content" | sed_compat 's/^\s+//g;s/\s+$//g')
		        ;;
	    esac
	    shift
    done

    echo "$content"
}

## Outputs on stdout the content of "$1" with these replaced:
##   \\ -> \
##   \0 -> NUL
##
## Effectively unquoting what was quoted with ``quote-0``.
unquote-0 () {
    local input="$1" chunk

    while [ "$input" ]; do
        case "${input::2}" in
            '\\'|"\0")
                printf "${input::2}"
                input=${input:2}
                ;;
            *)
                chunk="${input%%\\[0\\]*}"
                printf "%s" "$chunk"
                input="${input:${#chunk}}"
                ;;
        esac
    done
}


## Outputs on stdout the content of stdin with these replaced:
##   \0  -> \\0
##   NUL -> \0
##
## You can then store the stdin in a bash variable or pass it as argument.
quote-0() {
    local c chunk end=
    while true; do
        read-0 c || end=true
        while [ "$c" ]; do
            chunk="${c%%\\0*}"
            printf "%s" "${chunk}"
            if [ "$chunk" != "$c" ]; then
                chunk="$chunk\\"
                printf "%s" '\\'
            fi
            c="${c:${#chunk}}"
        done
        [ "$end" ] && break
        echo -n '\0'
    done
}


## Check
## https://vaab.blog.kal.fr/2015/01/03/bash-lore-how-to-properly-parse-nul-separated-fields/
## for more info on parsing separated fields and the implementation of
## this function.
read-0() {
    local eof= IFS=''
    while [ "$1" ]; do
        read -r -d '' -- "$1" || eof=1
        shift
    done
    [ -z "$eof" ]
}


p0() {
    printf "%s\0" "$@"
}

read-0a() {
    local eof= IFS=''
    while [ "$1" ]; do
        IFS='' read -r -d $'\n' -- "$1" || eof=1
        shift
    done
    [ -z "$eof" ]
}


aexport() {
    local aname fullname value
    for aname in "$@"; do
        fullname="${aname}[@]"
        value=$(args_serialize "${!fullname}") || return 1
        export "${aname}__SERIALIZED"="$value"
    done
}


aimport() {
    local aname fullname
    for aname in "$@"; do
        fullname="${aname}__SERIALIZED"
        array_deserialize "$aname" "${!fullname}"
    done
}


args_serialize() {
    printf "%s\0" "$@" | quote-0
}

array_deserialize() {
    local array_name="$1" arg
    args=()
    while read-0 arg; do
        args+=("$arg")
    done < <(unquote-0 "$2")
    eval "$array_name=(\"\${args[@]}\")"
}


## output on stdout the next record on stdin separated by a '\0'
next-0() {
    local ans IFS=''
    read -r -d '' ans &&
    echo -n "$ans"
}


is_uint () {  [[ "$1" =~ ^[0-9]+$ ]] ; }
is_int () {  [[ "$1" =~ ^-?[0-9]+$ ]] ; }
is_bash_int () {  [ "$1" -eq "$1" ] 2>/dev/null ; }
is_float () {  [[ "$1" =~ ^-?[0-9]*(.[0-9]*)?$ ]] ; }
is_num () { is_float "$1" ; }

## End libparse.sh
