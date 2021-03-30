## Begin libheader.sh

include bparse
include parse

## stdout stream of header expressions separated by NUL chars
## note: a header is defined as the first lines of the function
##   that start by a ": "
header.get() {
    local fname="$1"
    {
        read -r line  ## function name
        read -r line  ## {
        while read-0 expr; do
            [[ "${expr:0:2}" == ": " ]] || break
            printf "%s\0" "$expr"
        done < <(bparse)
    } < <(declare -f "$fname")
}

## End libheader.sh
