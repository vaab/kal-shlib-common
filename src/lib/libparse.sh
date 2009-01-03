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

## End libparse.sh
