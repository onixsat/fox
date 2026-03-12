function setOriginalIFS() {
    if [[ -z "${OIFS+x}" ]]; then
        export DEFAULT_IFS=$' \t\n'
        if [[ "$IFS" = "|" ]]; then
            OIFS="$DEFAULT_IFS";
        else
            OIFS="$IFS";
        fi
    fi
}
function resetIFS() {
    IFS="$OIFS";
}
function createMenu() {
    local menuName="$1"
    local menuTitle="$2"
    printf -v $( getMenuItmPointer "$menuName" ) ""
    printf -v $( getMenuCmdPointer "$menuName" ) ""
    printf -v $( getMenuTitlePointer "$menuName" ) "$menuTitle"
}
function addMenuItem() {
    local menuName="$1"
    local newItm="$2"
    shift 2
    local newCmd="$@"
    local itmPointer="$( getMenuItmPointer "$menuName" )"
    local cmdPointer="$( getMenuCmdPointer "$menuName" )"
    local itmVal="${!itmPointer}"
    local cmdVal="${!cmdPointer}"
    printf -v $itmPointer "${itmVal}|${newItm}"
    printf -v $cmdPointer "${cmdVal}|${newCmd}"
}
function loadMenu() {
    local menuName="$1"    
    if isValidMenu "$menuName"; then
        local titlePointer="$( getMenuTitlePointer "$menuName" )"
        local itmPointer="$( getMenuItmPointer "$menuName" )"
        local cmdPointer="$( getMenuCmdPointer "$menuName" )"
        local itmVal="${!itmPointer}"
        local cmdVal="${!cmdPointer}"
        setOriginalIFS
        IFS='|';
        local itmArray=($itmVal)
        local cmdArray=($cmdVal)
        clearTerm
        echo "$HEADER"
        shouldShowZeroNav "$menuName" && printZeroNav
        echo "  ${!titlePointer}"
        for ((i=1; i < ${#itmArray[@]}; i++)); do
            echo "    $i - ${itmArray[$i]}"
        done
        readSelectedOption
        clearTerm
        if $( isValidMenuOption "$selectedOption" "${#cmdArray[@]}" ); then
            local cmdString="${cmdArray[$selectedOption]}"
            resetIFS
            eval "$cmdString"
            IFS='|';
        else
 return 0
        fi
        
        resetIFS
    else
        echo "Oops! The menu ($menuName) does not exist :("
        echo "Please check your config for this menu"
        pause
        return 1
    fi
}
function shouldShowZeroNav() {
    local menuName="$1"
    if [[ "$menuName" == "mainMenu" ]]; then
        return 1
    else
        return 0
    fi
}
function isValidMenu() {
    local menuName="$1"   
    local itmPointer="$( getMenuItmPointer "$menuName" )"
    local itmVal="${!itmPointer}"
    if [[ ${#itmVal} -gt 0 ]]; then
        return 0 # true
    else
        return 1 # false
    fi
}
function isValidMenuOption() {
    local opt="$1"
    local lim="$2"
    if ! [[ "$opt" =~ ^[0-9]+$ && $opt -lt $lim ]]; then
        return 1
    else
        return 0
    fi
}
function printMenuStrs() {
    local menuName="$1"
    local itmPointer="$( getMenuItmPointer "$menuName" )"
    local cmdPointer="$( getMenuCmdPointer "$menuName" )"
    local titlePointer="$( getMenuTitlePointer "$menuName" )"
    echo "${itmPointer}: ${!itmPointer}"
    echo "${cmdPointer}: ${!cmdPointer}"
    echo "${titlePointer}: ${!titlePointer}"
}
function getMenuItmPointer() {
    local menuName="$1"
    echo "${menuName}Items"
}
function getMenuCmdPointer() {
    local menuName="$1"
    echo "${menuName}Commands"
}
function getMenuTitlePointer() {
    local menuName="$1"
    echo "${menuName}Title"
}
function printZeroNav() {
    echo "    0 - back to main menu"
}
function l8r() {
    echo "Goodbye!"
	lsof -t -nP -iTCP -sTCP:LISTEN | xargs kill -9
    keepGoing=1
	sleep 2
    clearTerm
}
function pause() {
    read -p "Press Enter to continue..."
}
function readSelectedOption() {
echo ""
tput cuu1
tput el
    read -p "  Choose an option1: " selectedOption
}
function clearTerm() {
    clear
}
