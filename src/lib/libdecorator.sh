## Begin libdecorator.sh

include common
include parse
include bparse
include fn


## List all decorated functions
decorator._find_all_fn() {
    declare -f | sed -nr '/[^ ]+ \(\) $/{N;N;/\n([[:space:]]+:[^\n]*)$/{s/^([^ ]+) .*$/\1/M;P}}'
}

decorator.fn_parse_all_decorators() {
    local fn="$1" e
    while bparse.read e ; do
        if [[ "$e" =~ ^":"[a-zA-Z0-9_-]+":" ]]; then
            p0 "$e"
        else
            p0 ""
            e "$e"$'\n'
            ## exhaust the end of the file
            cat
        fi
    done < <(fn.body "$fn")
}


## This preparation is only needed for now because we don't have
## a proper hack in bash. This function will simply replace the
## body of the function (not the decorator part)
##
## f() {
##    :dec: a b c
##    CODE;
## }
##
## Should become:
##
## f() {
##    f() {
##        CODE
##    }
##    :dec: a b c
##    f "$@"
## }
##
## With the possibility for :dec: to change f if it needs to.
##
decorator._mangle_fn() {
    local fn="$1" __body dec_lines dec_line
    while read-0 dec_line; do
        [ -z "$dec_line" ] && { read-0 __body; break; }
        dec_lines+="$dec_line || { 
                errlvl=\$?
                err \"following decorator call failed with errlvl \$errlvl:\"\$'\n'\"\$(e $dec_line | prefix \"  \")\"
                return \$((96 + errlvl))
            }"$'\n'
    done < <(decorator.fn_parse_all_decorators "$fn")
    eval "$fn() {
              $fn() {
                  $__body
              }
              $dec_lines
              $fn \"\$@\"
          }"
}


decorator.mangle() {
    local fn
    for fn in $(decorator._find_all_fn); do
        decorator._mangle_fn "$fn"
    done
}

## End libdecorator.sh