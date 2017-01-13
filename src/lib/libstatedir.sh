## Begin libstatedir.sh

state:init() {
    local varname="${exname}_STATEDIR"
    {
        is_set "$varname" &&
            test -d "${!varname}"
    } || settmpdir "${exname}_STATEDIR"
}

## End libstatedir.sh
