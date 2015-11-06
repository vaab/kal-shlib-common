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

function is_uint () {  [[ "$1" =~ ^[0-9]+$ ]] ; }
function is_int () {  [[ "$1" =~ ^-?[0-9]+$ ]] ; }
function is_bash_int () {  [ "$1" -eq "$1" ] 2>/dev/null ; }
function is_float () {  [[ "$1" =~ ^-?[0-9]*(.[0-9]*)?$ ]] ; }
function is_num () { is_float "$1" ; }


## End libparse.sh
