## Begin libcolor.sh

## If COLUMNS hasn't been set yet (bash sets it but not when called as sh), do
## it ourself

if [ -z "$COLUMNS" ]; then

    ## Get the console device if we don't have it already. This is ok by the
    ## FHS as there is a fallback if /usr/bin/tty isn't available, for example
    ## at bootup.

    test -x /usr/bin/tty && CONSOLE=`/usr/bin/tty`
    test -z "$CONSOLE" && CONSOLE=/dev/console

    ## Get the console size (rows columns)

    stty size > /dev/null 2>&1
    if [ "$?" = 0 ]; then
        [ "$CONSOLE" = "/dev/console" ] && SIZE=$(stty size < $CONSOLE) \
            || SIZE=$(stty size)

        ## Strip off the rows leaving the columns

        COLUMNS=${SIZE#*\ }
        LINES=${SIZE%\ *}
    else
        COLUMNS=80
        LINES=24
    fi
    export COLUMNS LINES SIZE
fi

ANSI_ESC=$'\e['

export COL_CHAR COL_STATUS COL_INFO COL_ELT ANSI_ESC


ansi_color() {
    local choice="$1"

    if [ "$choice" == "tty" ]; then
        if [ -t 1 ]; then
            choice="yes"
        else
            choice="no"
        fi
    fi

    if [ "$choice" != "no" ]; then

        SET_COL_CHAR="${ANSI_ESC}${COL_CHAR}G"
        SET_COL_STATUS="${ANSI_ESC}${COL_STATUS}G"
        SET_COL_INFO="${ANSI_ESC}${COL_INFO}G"
        SET_COL_ELT="${ANSI_ESC}${COL_ELT}G"

        SET_BEGINCOL="${ANSI_ESC}0G"

        UP="${ANSI_ESC}1A"
        DOWN="${ANSI_ESC}1B"
        LEFT="${ANSI_ESC}1D"
        RIGHT="${ANSI_ESC}1C"

        SAVE="${ANSI_ESC}7"
        RESTORE="${ANSI_ESC}8"

        NORMAL="${ANSI_ESC}0m"

        GRAY="${ANSI_ESC}1;30m"
        RED="${ANSI_ESC}1;31m"
        GREEN="${ANSI_ESC}1;32m"
        YELLOW="${ANSI_ESC}1;33m"
        BLUE="${ANSI_ESC}1;34m"
        PINK="${ANSI_ESC}1;35m"
        CYAN="${ANSI_ESC}1;36m"
        WHITE="${ANSI_ESC}1;37m"

        DARKGRAY="${ANSI_ESC}0;30m"
        DARKRED="${ANSI_ESC}0;31m"
        DARKGREEN="${ANSI_ESC}0;32m"
        DARKYELLOW="${ANSI_ESC}0;33m"
        DARKBLUE="${ANSI_ESC}0;34m"
        DARKPINK="${ANSI_ESC}0;35m"
        DARKCYAN="${ANSI_ESC}0;36m"

        SUCCESS=$GREEN
        WARNING=$YELLOW
        FAILURE=$RED
        NOOP=$BLUE
        ON=$SUCCESS
        OFF=$FAILURE
        ERROR=$FAILURE

    else

        SET_COL_CHAR=
        SET_COL_STATUS=
        SET_COL_INFO=
        SET_COL_ELT=

        SET_BEGINCOL=

        NORMAL=
        RED=
        GREEN=
        YELLOW=
        BLUE=
        GRAY=
        WHITE=

        DARKGRAY=
        DARKRED=
        DARKGREEN=
        DARKYELLOW=
        DARKBLUE=
        DARKPINK=
        DARKCYAN=

        SUCCESS=
        WARNING=
        FAILURE=
        NOOP=
        ON=
        OFF=
        ERROR=

    fi

    export SET_COL_CHAR SET_COL_STATUS SET_COL_INFO SET_COL_ELT \
           SET_BEGINCOL UP DOWN LEFT RIGHT SAVE RESTORE NORMAL \
           GRAY RED GREEN YELLOW BLUE PINK CYAN WHITE DARKGRAY \
           DARKRED DARKGREEN DARKYELLOW DARKBLUE DARKPINK DARKCYAN \
           SUCCESS WARNING FAILURE NOOP ON OFF ERROR ansi_color
}

color:init() {
    ansi_color "${ansi_color:-tty}"
}

## End libcolor.sh
