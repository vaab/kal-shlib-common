## Begin of libconf.sh

include common

function read_conf() {

    config_file=$(find_conf_file "$1")
    if ! [ -f "$config_file" ];then
	print_error "Couldn't find a correct config file."
	return 1
    fi

    if [ -f "$config_file" -a -r "$config_file" ];then

	include parse

	config_content="$("$cat" "$config_file" | remove comment empty-line trim-lines )"
    else
	config_content=""
	print_error "Couldn't access '$config_file' ..."
	return 1

    fi
}

## Begin of libconf.sh
