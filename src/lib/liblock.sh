## start of liblock.sh

include common

LOCK_DIR=${LOCK_DIR:-"/var/lock/shlib"}

depends mkdir ps rm touch

function lock() {

  if ! [ -d "$LOCK_DIR" ]; then
        if ! "$mkdir" -p "$LOCK_DIR"; then
                print_error "lock directory : '$LOCK_DIR' not found."
                return 1
        fi
  fi

  if [ -z "$1" ]; then
        print_syntax_error "'$FUNCNAME' must be called at least with an argument."
        return 1
  fi

  # TODO : make a test for the label must be only alphanumerical

  if [ -f "$LOCK_DIR/$1" ]; then
      # lock exists
      return 1
  fi

  "$touch" "$LOCK_DIR/$1"

}

function unlock() {

  if ! [ -d "$LOCK_DIR" ]; then
        print_error "lock directory : '$LOCK_DIR' not found."
        return 1
  fi

  if [ -z "$1" ]; then
        print_syntax_error "'$FUNCNAME' must be called at least with an argument."
        return 1
  fi

  # TODO : make a test for the label must be only alphanumerical

  if [ -f "$LOCK_DIR/$1" ]; then
      # lock exists
      "$rm" -f "$LOCK_DIR/$1"
      return 0
  fi

  return 1
}


## PID locking


function pid_lock_get() {

  local pid_file
  pid_file=$1

  ##
  ## Lock on execution to prevent 2 instance of this program to run together.
  ##

  if [ -e "$pid_file" ]; then
    echo -n "Pid file $pid_file exists ! Checking that it is valid..." >&2

    pid=$(cat "$pid_file")
    echo -n "process $pid owns the lock" >&2
    if "$ps" -p "$pid" > /dev/null 2>&1; then
        echo " and he is alive. Quitting" >&2
        exit 1
    fi
    echo " and he does not exists anymore. Removing lock file." >&2
    "$rm" -f "$pid_file"
  fi

  echo "$$" > "$pid_file"

}


function pid_lock_release() {

  local pid_file
  pid_file=$1

  if [ -e "$pid_file" ]; then
      pid=$(cat "$pid_file")

      if [ "$pid" != "$$" ]; then
           echo "This script is not allowed to remove '$pid_file' because it's not it's own PID inside." >&2
           exit 1
      fi
      "$rm" "$pid_file"
  else
      echo "Cannot release lock '$pid_file' as it is not set !!" >&2
      exit 1
  fi
}

## end of liblock.sh
