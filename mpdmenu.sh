#!/bin/bash
MPC="mpc --quiet -p ${1:-6600}"

DMENU() {
    # Vertical menu if $3 is given
    echo -e "$1" | dmenu -i -b -p "$2" ${3:+"-l"} $3
}

add() {
    local artist=$(DMENU "$($MPC list Artist)\nall" "Select artist" 20)

    if [ "$artist" = "all" ]; then
        $MPC listall | $MPC add;
    elif [ -n "$artist" ]; then
        local albums=$($MPC list Album Artist "$artist")
        local album=$(DMENU "$albums\nall" "Select album" 20)

        if [ "$album" = "all" ]; then
            $MPC findadd Artist "$artist"
        elif [ -n "$album" ]; then
            local songs=$($MPC list Title Album "$album")
            local song=$(DMENU "$songs\nall" "Select song" 20)

            if [ "$song" = "all" ]; then
                $MPC findadd Album "$album"
            elif [ -n "$song" ]; then
                $MPC findadd Title "$song"
            fi
        fi
    fi
}

get_playlist() {
    $MPC -f "%position% - %artist% - %album% - %title%" playlist
}

remove() {
    local playlist=$(get_playlist)
    local height=$(echo $playlist | wc -l)
    local song=$(DMENU "$playlist" "Select song" $height)

    [ -n "$song" ] && $MPC del ${song%%\ *}
}

jump() {
    local playlist=$(get_playlist)
    local list_length=$(echo $get_playlist | wc -l)

    if [ $list_length -gt 40 ]; then
        list_length=40
    fi

    local song=$(DMENU "$playlist" "Select song" $list_length)

    [ -n "$song" ] && $MPC play ${song%%\ *}
}

while true; do
    action=$(DMENU "Clear\nAdd\nRemove\nJump" "Do you want to")
    case $action in
        Clear) $MPC clear;;
        Add) add;;
        Remove) remove;;
        Jump) jump;;
        "") exit 0;;
    esac
done
