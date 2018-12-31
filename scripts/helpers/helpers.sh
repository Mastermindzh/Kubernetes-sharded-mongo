# switch to a given color
# first argument is a string
# options: ["yellow","blue","green","red","default"]
# wrong / no options will revert to default
switchColor() {
    local mycolor=""

    case "$1" in
        yellow)
            mycolor="93";;
        blue)
            mycolor="94";;
        green)
            mycolor="32";;
        red)
            mycolor="31";;
        *)
            mycolor="0";;
    esac

    printf "\e[${mycolor}m"
}

# echo a yellow message
systemMessage(){
    if [[ $# -ne 2 ]] ; then
        echo ""
    fi
    
    switchColor "yellow"
    if ! [ -z ${1+x} ]; then echo -e "$1"; fi
    switchColor
}

# echo a red message
errorMessage(){
    switchColor "red"
    if ! [ -z ${1+x} ]; then echo -e "Error: $1"; fi
}

internalSystemMessage(){
    switchColor "blue"
    if ! [ -z ${1+x} ]; then echo -e "$1"; fi
    switchColor
}