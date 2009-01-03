## Begin libperm.sh

include common

depends getent grep

function cur_user_get() {
    echo "$("$getent" passwd | "$grep" "^.\+:.*:$UID:" | cut -f 1 -d ":" | head -n 1)" ;
}

function cur_group_get() {
    echo "$("$getent" group | grep  "^.\+:.*:$GROUPS:" | cut -f 1 -d ":")" ;
}

function cur_home_get() {
    echo "$("$getent" passwd | "$grep" "^.\+:.*:$UID:" | cut -f 6 -d ":")" ;

}

## End libperm.sh
