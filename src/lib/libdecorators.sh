## Begin libdecorators.sh

include decorator


# :statedir:() {
#     :decorator: body
#     :include: statedir
#     :once: state:init
#     local statement="$@"

#     eval "$fn() { local statedir=\${${exname}_STATEDIR}"$'\n'"$(echo "$body" | tail -n +2 )"
# }


:uses:() {
    :decorator: body
    local statement="$@"
    uses $statement
    eval "$body"
}


:from:() {
    :decorator: body
    local statement="$@"
    from $statement
    eval "$body"
}


:include:() {
    :decorator: body
    local statement="$@"
    include $statement
    eval "$body"
}


:depends:() {
    :decorator: body
    local statement="$@"
    depends $statement
    eval "$body"
}


:once:() {
    :decorator: body
    local statement="$@"
    eval "$statement"$'\n'"$body"
}


## End libdecorators.sh
