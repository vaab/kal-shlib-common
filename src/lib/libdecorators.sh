## Begin libdecorators.sh

include decorator


:uses:() {
    uses "$@"
}


:from:() {
    from "$@"
}


:include:() {
    include "$@"
}


:depends:() {
    depends "$@"
}

:once:() {
    "$@"
}


## End libdecorators.sh
