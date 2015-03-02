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
    if [ "$?" == 0 ]
    then
        [ "$CONSOLE" == "/dev/console" ] && SIZE=$(stty size < $CONSOLE) \
            || SIZE=$(stty size)

        ## Strip off the rows leaving the columns

        COLUMNS=${SIZE#*\ }
        LINES=${SIZE%\ *}
    else
        COLUMNS=80
        LINES=24
    fi

fi


SEP_LIST_ELT=""
SEP_ELT_INFO=" "
SEP_INFO_STATUS=" "
SEP_STATUS_CHAR=" "

SEP_LIST_ELT_SIZE=$(echo -n "$SEP_LIST_ELT" | wc -c)
SEP_ELT_INFO_SIZE=$(echo -n "$SEP_ELT_INFO" | wc -c)
SEP_INFO_STATUS_SIZE=$(echo -n "$SEP_INFO_STATUS" | wc -c)
SEP_STATUS_CHAR_SIZE=$(echo -n "$SEP_STATUS_CHAR" | wc -c)


SIZE_LINE=$COLUMNS                            ## full line size
SIZE_INFO=20                                  ## zone info size in chars
SIZE_STATUS=8                                 ## status info size in chars
SIZE_LIST=3                                   ## status info size in chars
SIZE_CHAR=1                                   ## status char info size
SIZE_ELT=$[$SIZE_LINE - 1
    - $SIZE_INFO
    - $SIZE_STATUS
    - $SIZE_LIST
    - $SIZE_CHAR
    - $SEP_LIST_ELT_SIZE
    - $SEP_ELT_INFO_SIZE
    - $SEP_INFO_STATUS_SIZE
    - $SEP_STATUS_CHAR_SIZE
]                 ## elt info size in chars

COL_CHAR=$[$COLUMNS - 1 - $SIZE_CHAR]
COL_STATUS=$[$COL_CHAR - $SEP_STATUS_CHAR_SIZE - $SIZE_STATUS]
COL_INFO=$[$COLUMNS - $SEP_INFO_STATUS_SIZE - $SIZE_INFO]
COL_ELT=$[$COLUMNS - $SEP_ELT_INFO_SIZE - $SIZE_ELT]


function ansi_color()
{
    if [ "$1" != "no" ]; then

        SET_COL_CHAR=$(echo -en "\e[${COL_CHAR}G")
        SET_COL_STATUS=$(echo -en "\e[${COL_STATUS}G")
        SET_COL_INFO=$(echo -en "\e[${COL_INFO}G")
        SET_COL_ELT=$(echo -en "\e[${COL_ELT}G")

        SET_BEGINCOL=$(echo -en "\e[0G")

        UP=$(echo -en "\e[1A")
        DOWN=$(echo -en "\e[1B")
        LEFT=$(echo -en "\e[1D")
        RIGHT=$(echo -en "\e[1C")

        SAVE=$(echo -en "\e7")
        RESTORE=$(echo -en "\e8")

        NORMAL=$(echo -en "\e[0m")
        RED=$(echo -en "\e[1;31m")
        GREEN=$(echo -en "\e[1;32m")
        YELLOW=$(echo -en "\e[1;33m")
        BLUE=$(echo -en "\e[1;34m")
        GRAY=$(echo -en "\e[1;30m")
        WHITE=$(echo -en "\e[1;37m")


        DARKGREEN=$(echo -en "\e[0;32m")
        DARKYELLOW=$(echo -en "\e[0;33m")

        CYAN=$(echo -en "\e[1;36m")
        PINK=$(echo -en "\e[1;35m")

        SUCCESS=$GREEN
        WARNING=$YELLOW
        FAILURE=$RED
        NOOP=$BLUE
        ON=$SUCCESS
        OFF=$FAILURE
        ERROR=$FAILURE

        ansi_color="yes"

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

        DARKGREEN=
        DARKYELLOW=

        SUCCESS=
        WARNING=
        FAILURE=
        NOOP=
        ON=
        OFF=
        ERROR=

        ansi_color="no"

    fi

}

ansi_color "$ansi_color"

## End libcolor.sh
