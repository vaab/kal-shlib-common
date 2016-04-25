## Begin libparse.sh

include common
include color

function remove() {

    depends sed

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
		content=$(echo "$content" | sed_compat 's/^ +//g')
		content=$(echo "$content" | sed_compat 's/ +$//g')
		;;

	esac
	shift
    done

   echo "$content";

}

## Check
## https://vaab.blog.kal.fr/2015/01/03/bash-lore-how-to-properly-parse-nul-separated-fields/
## for more info on parsing separated fields and the implementation of
## this function.
read-0() {
    local eof= IFS=''
    while [ "$1" ]; do
        read -r -d '' "$1" || eof=true
        shift
    done
    test "$eof" != true
}

function is_uint () {  [[ "$1" =~ ^[0-9]+$ ]] ; }
function is_int () {  [[ "$1" =~ ^-?[0-9]+$ ]] ; }
function is_bash_int () {  [ "$1" -eq "$1" ] 2>/dev/null ; }
function is_float () {  [[ "$1" =~ ^-?[0-9]*(.[0-9]*)?$ ]] ; }
function is_num () { is_float "$1" ; }


## End libparse.sh
