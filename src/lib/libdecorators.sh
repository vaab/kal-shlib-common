## Begin libdecorators.sh


:statedir:() {
    :include: statedir
    :once: state:init

    local fn="$1" statement="$2" body="$3"
    eval "$fn() { local statedir=\${${exname}_STATEDIR}"$'\n'"$(echo "$body" | tail -n +2 )"
}



decorator:uses() {
    local fn="$1" statement="$2" body="$3"
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
