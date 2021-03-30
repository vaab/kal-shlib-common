
include common


##
## Basic and incomplete bash parser to separate instructions
##
## Missing:
##   - < and > in expressions
##   - $1 $? $# $! $- $$
##   - $x_a
##   - ${...} inside is not done yet too


bparse._on_token() {
    [ -z "$word" ] && return 0
    # echo "ON token word: '$word' '$expr_buf'" >&2
    expr_args+=("$word")
    if [ "${#expr_args[@]}" == 1 ]; then
        case "${expr_args[0]}" in
            "then"|"esac"|"done"|"fi")
                token=${expr_args[0]}
                matched="$expr_buf"
                return "$_BPARSER_UNEXPECTED_TOKEN"
                ;;
            "if")
                expected_word=then
                while true; do
                    # echo "BEF" >&2
                    expr=
                    bparse.expr
                    errlvl="$?"
                    expr_buf+="$matched"
                    case "$errlvl" in
                        1)
                            err "Parser in subexpression failed."
                            return 1
                            ;;
                        "$_BPARSER_UNEXPECTED_TOKEN")
                            if [[ "$token" != "$expected_word" ]]; then
                                err "Got unexpected token '$token'."
                                return 1
                            fi

                            # echo "FOUND EXPECTED: $token" >&2
                            [ "$expected_word" == "fi" ] && break
                            expected_word=fi
                            ;;
                        # *)
                        #     echo "CONTINUE" >&2
                        #     continue
                        #     ;;
                    esac
                done
                ;;
            "case"|"while"|"for")
                die "Parsing '${expr_args[0]}' syntax is not supported yet"
                ;;
        esac
    fi

    # if [[ "$word" =~ ^[0-9]*> ]]; then  ## redirect
    #     "[0-9]"
    # fi
    return 0
}


bparse._subshell() {
    local expr_buf="( "
    ((_BPARSER_IDX++))
    while true; do
        bparse._expr
        case "$?" in
            "$_BPARSER_UNEXPECTED_TOKEN")
                if [[ "${line:$_BPARSER_IDX:1}" != ")" ]]; then
                    err "Got unexpected token '${line:$_BPARSER_IDX:1}'."
                    return $_BPARSER_UNEXPECTED_TOKEN
                fi
                expr_buf+="$matched"
                break
                ;;
            "$_BPARSER_EOF")
                err "Unmatched open parenthesis."
                return $_BPARSER_SYNTAX_ERROR
                ;;
            0)
                expr_buf+="$matched;"$'\n'
                ;;
            *)
                err "Parser in subexpression failed."
                return 1
                ;;
        esac
    done
    matched="${expr_buf} )"
}


bparse._double_quoted_string() {
    local expr_buf="\"" char
    while true; do
        char="${line:$((++_BPARSER_IDX)):1}"
        case "$char" in
            "\"") break;;
            \\)
                ## Ignore next char
                expr_buf+="$char"
                char="${line:$((++_BPARSER_IDX)):1}"
                ;;
            \$)
                bparse._dollar_expression || return $?
                expr_buf+="$matched"
                ((--_BPARSER_IDX))
                continue
                ;;
            "")
                ## End line
                expr_buf+=$'\n'
                if ! read -r line; then
                    err "Unterminated double-quoted string."
                    return "$_BPARSER_SYNTAX_ERROR"
                fi
                _BPARSER_IDX=-1
                continue
                ;;
        esac
        expr_buf+="$char"
    done
    matched="${expr_buf}\""
}


bparse._single_quoted_string() {
    local expr_buf="'" char
    while true; do
        char="${line:$((++_BPARSER_IDX)):1}"
        case "$char" in
            "'") break;;
            "")
                ## End line
                expr_buf+=$'\n'
                if ! read -r line; then
                    err "Unterminated single-quoted string."
                    return $_BPARSER_SYNTAX_ERROR
                fi
                _BPARSER_IDX=-1
                continue
                ;;
        esac
        expr_buf+="$char"
    done
    matched="${expr_buf}'"
}

bparse._variable_identifier() {
    local expr_buf="$1" char
    while true; do
        char="${line:$((++_BPARSER_IDX)):1}"
        # echo "CHARV: '$char'" >&2
        [[ "$char" == [[:alnum:]] ]] || break
        expr_buf+="$char"
    done
    matched="${expr_buf}"
}


bparse._variable_bracket_expr() {
    local expr_buf="{" char
    while true; do
        char="${line:$((++_BPARSER_IDX)):1}"
        [[ "$char" != "}" ]] || {
            ((_BPARSER_IDX++))
            break
        }
        expr_buf+="$char"
    done
    matched="${expr_buf}}"
}


bparse._dollar_expression() {
    local expr_buf="$" char
    ((_BPARSER_IDX++))
    while true; do
        char="${line:$_BPARSER_IDX:1}"
        case "$char" in
            [[:alpha:]]|"_")
                bparse._variable_identifier "$char" || return $?
                expr_buf+="$matched"
                break
                ;;
            \@|\*|\?|\-|\!|\$|\#)
                expr_buf+="$char"
                ((_BPARSER_IDX++))
                break
                ;;
            \{)
                bparse._variable_bracket_expr || return $?
                expr_buf+="$matched"
                break
                ;;
            "(")
                bparse._subshell || return $?
                expr_buf+="$matched"
                ;;
            *) break;;
        esac
        ((_BPARSER_IDX++))
    done
    matched="${expr_buf}"
}


## return bash expressions separated with a NUL chars
bparse._expr() {
    local expr_args=() expr_buf= word= char=
    while true; do
        char="${line:$_BPARSER_IDX:1}"
        #[ -n "$DEBUG_BPARSE" ] && echo "CHAR: '$char', _BPARSER_IDX=$_BPARSER_IDX, LINE: '$line'" >&2
        case "$char" in
            ")")
                token="$char"
                matched="$expr_buf"
                return $_BPARSER_UNEXPECTED_TOKEN
                ;;
            "(")
                bparse._subshell || return $?
                expr_buf+="$matched"
                ;;
            "\"")
                [ -z "$word" ] && [ -n "$expr_buf" ] && { expr_buf+=" "; }
                bparse._double_quoted_string || return $?
                expr_buf+="$matched"
                ;;
            "'")
                [ -z "$word" ] && [ -n "$expr_buf" ] && { expr_buf+=" "; }
                bparse._single_quoted_string || return $?
                expr_buf+="$matched"
                ;;
            \\)
                # echo -n "$DARKRED${line:$_BPARSER_IDX:1}$NORMAL"
                expr_buf+="${line:$_BPARSER_IDX:2}"
                ## Ignore next char
                ((_BPARSER_IDX++))
                # echo -n "$DARKRED${line:$_BPARSER_IDX:1}$NORMAL"
                ;;
            "|")
                [ -n "$expr_buf" ] && { expr_buf+=" "; word=;}
                expr_buf+="$char"
                char="${line:$((++_BPARSER_IDX)):1}"
                case "$char" in
                    "|")
                        expr_buf+="$char"
                        ((_BPARSER_IDX++))
                        bparse._expr || return $?
                        if [ -z "$matched" ]; then
                            err "Expression required after '||'."
                            return $_BPARSER_SYNTAX_ERROR
                        fi
                        expr_buf+=" $matched"
                        continue
                        ;;
                    *)
                        # echo -n "$WHITE${char}$NORMAL"
                        bparse._expr || return $?
                        if [ -z "$matched" ]; then
                            err "Expression required."
                            return $_BPARSER_SYNTAX_ERROR
                        fi
                        expr_buf+=" $matched"
                        continue
                        ;;
                esac

                ;;
            \;)
                if [ -z "$expr_buf" ]; then
                    err "Unexpected token \`$char'."
                    return 1
                fi
                # bparse._on_token || return $?
                if [ "$char" == "&" ]; then
                    expr_buf+="$char"
                fi
                ((_BPARSER_IDX++))
                word=""
                break
                ;;
            "&")
                if [ -z "$expr_buf" ]; then
                    err "Unexpected token \`$char'."
                    return $_BPARSER_SYNTAX_ERROR
                fi
                #expr_buf+="$char"
                if [[ "${line:$((_BPARSER_IDX - 1)):1}" == \> ]]; then
                    word+="$char"
                    expr_buf+="$char"
                    ((_BPARSER_IDX++))
                    continue
                fi
                word=
                char="${line:$((++_BPARSER_IDX)):1}"
                case "$char" in
                    "&")
                        ((_BPARSER_IDX++))
                        bparse._expr || return $?
                        if [ -z "$matched" ]; then
                            err "Expression required after '&&'."
                            return $_BPARSER_SYNTAX_ERROR
                        fi
                        expr_buf+=" && $matched"
                        continue
                        ;;
                    *)
                        expr_buf+=" &"
                        # bparse._on_token || return $?
                        break
                        ;;
                esac
                ;;
            "")
                # bparse._on_token || return $?
                # echo "expr_buf: '$expr_buf', _BPARSER_IDX=$_BPARSER_IDX" >&2
                if [ -z "$expr_buf" ]; then

                    read -r line || return "$_BPARSER_EOF"
                    [ -n "$DEBUG_BPARSE" ] && printf "Reading line: %s\n" "$line" >&2
                    _BPARSER_IDX=0
                    continue
                fi
                #expr_buf+=$'\n'
                ## End line
                # echo "ENDLINE '${expr_buf}'" >&2
                # if ! read -r line; then
                #     expr="$expr_buf"
                #     _BPARSER_IDX=0
                #     word=""
                #     return "$_BPARSER_EOF"
                # fi
                _BPARSER_IDX=0
                word=""
                line=""
                # read -r line || return "$_BPARSER_EOF"
                break
                ;;
            " ")
                word=
                ((++_BPARSER_IDX))
                ## add only one space
                # bparse._on_token || return $?
                continue
                ;;
            \$)
                [ -z "$word" ] && [ -n "$expr_buf" ] && { expr_buf+=" "; }
                bparse._dollar_expression || return $?
                expr_buf+="$matched"
                word+="$matched"
                continue
                ;;
            # \>)
            #     word=
            #     [ -n "$expr_buf" ] && { expr_buf+=" "; }
            #     word+="$char"
            #     expr_buf+="$char"
            #     ;;
            *)
                [ -z "$word" ] && [ -n "$expr_buf" ] && { expr_buf+=" "; }
                word+="$char"
                expr_buf+="$char"
                ;;
        esac
        ((_BPARSER_IDX++))
    done
    matched="$expr_buf"

}



## return bash expressions separated with a NUL chars
bparse.read() {
    local expname="$1" oldifs="$IFS"
    # line=
    export IFS=""
    bparse._expr
    errlvl="$?"
    export IFS="$oldifs"
    case "$errlvl" in
        1)
            err "Parser in subexpression failed."
            return 127
            ;;
        "$_BPARSER_UNEXPECTED_TOKEN")
            err "Got unexpected token '$token'."
            return 2
            ;;
        "$_BPARSER_EOF")
            return "$_BPARSER_EOF"
            ;;
        "$_BPARSER_SYNTAX_ERROR")
            err "Syntax error"
            return "$_BPARSER_SYNTAX_ERROR"
            ;;
        0)
            export "$expname"="${matched}"
            return 0
            ;;
        *)
            err "Unexpected bash parsing errorlevel: $errlvl"
            return "$errlvl"
            ;;
    esac
}

bparse() {
    local i=15 e line
    while bparse.read e 2>/dev/null || { errlvl=$? ; [ "$errlvl" != "$_BPARSER_EOF" ] && return "$errlvl"; }; do
        ## Could get some: 'printf: write error: Broken pipe' when stdout is closed.
        printf "%s\0" "$e" 2>/dev/null || true
    done
}


bparse:init() {

    _BPARSER_UNEXPECTED_TOKEN=2
    _BPARSER_SYNTAX_ERROR=4
    _BPARSER_EOF=3

    _BPARSER_LINE=
    _BPARSER_IDX=0

    export _BPARSER_{EOF,UNEXPECTED_TOKEN,SYNTAX_ERROR,LINE,IDX}
}

