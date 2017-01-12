## Begin libdecorator

include parse

## Reads a from given function name the code of this function and
## extracts the given decorator in the output using 'NUL' between the
## decorator commandline and the body of the function minus the
## decorator line.
decorator.parse_fn() {
    local decorator="$1" fn="$2" found
    prefix="$fn() {"
    found=
    done=
    while IFS=$'\n' read -r line ; do
        [ "$done" == "true" ] && { echo "$line"; continue; }
        line_trimmed="${line#"${line%%[![:space:]]*}"}"
        if [[ "$line_trimmed" == ":$decorator:"* ]]; then
            found="${line_trimmed#:$decorator:}"
            ## keep the last ";" to avoid having an empty string in '$found'
        fi
        if [ "$found" ] || [[ "$line_trimmed" != *:*:* ]]; then
            found=${found%;}
            echo -n "${found#"${found%%[![:space:]]*}"}"
            echo -en '\0'
            echo "$prefix"
            done=true
            continue
        fi
        prefix="$prefix"$'\n'"$line"
    done < <(declare -f "$fn" | tail -n "+3")
}


decorator.load() {
    local decorator="$1" code= statement= body=
}

:decorator:() {
    local decorator=${FUNCNAME[1]} _statement body_arg="$1"
    read-0 _statement d_body < <(decorator.parse_fn decorator "$decorator")
    eval "
          ${decorator}:source() {
              $([ "$body_arg" ] && echo "local ${body_arg}=\$__decorator_body")
              $(echo "$d_body" | tail -n +2 )
          $decorator() {
                  local __decorator_body
                  echo \"IN: \${FUNCNAME[*]}\"
                  fn=\${FUNCNAME[1]}
                  [ \"\$fn\" ] || {
                      echo \"\$FUNCNAME: $decorator: couldn't get caller information.\" >&2
                      exit 1
                  }
                  read-0 statement __decorator_body < <(decorator.parse_fn $decorator \"\$fn\")
                  #local fn=\"\$fn\" statement=\"\$statement\" body=\"\$body\"
                  ${decorator}:source \"\$@\"
          }"
    decorator=${decorator##:}
    decorator=${decorator%%:}
    [ -z "$body_arg" -o -z "${FUNCNAME[2]}" ] ||
        read-0 _statement "$body_arg" < <(decorator.parse_fn "$decorator" "${FUNCNAME[2]}")
    # echo "XXX: ${FUNCNAME[1]}:source" "${FUNCNAME[2]}" "$statement" "$body"
    # "${FUNCNAME[1]}:source" "${FUNCNAME[2]}" "$statement" "$body"
}

## End libcommon.sh
