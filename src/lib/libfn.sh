## start of libfn.sh

fn.exists() { declare -F "$1" >/dev/null; }

fn.cp() {
    local src="$1" dst="$2"
    eval "$(echo "$dst() " ; declare -f "$src" | tail -n +2)"
}

fn.mv() { fn.cp "$1" "$2"; unset -f "$1"; }

fn.def() {
    local name="$1" code="$2"
    eval "$(echo "$name() { $code"$'\n'" }")"
}

fn.body() {
    local fn="$1"
    declare -f "$fn" | tail -n "+3" | head -n -1
}

## end of libfn.sh
