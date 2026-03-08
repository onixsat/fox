#!/bin/bash
logo2=(

)
function _spinner() {
    # $1 start/stop
    #
    # on start: $2 display message
    # on stop : $2 process exit status
    #           $3 spinner function pid (supplied from stop_spinner)

    local on_success="DONE"
    local on_fail="FAIL"
    local white="\e[1;37m"
    local green="\e[1;32m"
    local red="\e[1;31m"
    local nc="\e[0m"

    case $1 in
        start)
            # calculate the column where spinner and status msg will be displayed
            let column=$(tput cols)-${#2}-8
            # display message and position the cursor in $column column
            echo -ne ${2}
            printf "%${column}s"

            # start spinner
            i=1
            sp='\|/-'
            delay=${SPINNER_DELAY:-0.15}

            while :
            do
                printf "\b${sp:i++%${#sp}:1}"
                sleep $delay
            done
            ;;
        stop)
            if [[ -z ${3} ]]; then
                echo "spinner is not running.."
                exit 1
            fi

            kill $3 > /dev/null 2>&1

            # inform the user uppon success or failure
            echo -en "\b["
            if [[ $2 -eq 0 ]]; then
                echo -en "${green}${on_success}${nc}"
            else
                echo -en "${red}${on_fail}${nc}"
            fi
            echo -e "]"
            ;;
        *)
            echo "invalid argument, try {start/stop}"
            exit 1
            ;;
    esac
}
function start_spinner {
    # $1 : msg to display
    _spinner "start" "${1}" &
    # set global spinner pid
    _sp_pid=$!
    disown
}
function stop_spinner {
    # $1 : command exit status
    _spinner "stop" $1 $_sp_pid
    unset _sp_pid
}
menu=(
"Update"
"Password"
"Reload"
"Process Stats"
"Network Stats"
"Disk Stats"
"Exit"
)
# Off and on cursor
tput civis
trap ctrl_c INT
function ctrl_c() {
    tput cnorm
    clear
    return 1
    #reload "return" "$GLOBAL_VAR"
}

clear
selected=0

function show-menu {
    rows=$(tput lines)
    cols=$(tput cols)
    menu_length=${#menu[@]}
    current_row=$((rows / 2 - menu_length / 2))

    # logo
    for i in "${!logo[@]}"; do
        tput cup $current_row $((cols / 2 - ${#logo[$i]} / 2))
        echo "${logo[$i]}"
        ((current_row++))
    done

    # Menu
    for i in "${!menu[@]}"; do
        if [[ $i -eq $selected ]]; then
            tput cup $current_row $((cols / 2 - ${#menu[$i]} / 2))
            echo "> ${menu[$i]}"
        else
            tput cup $current_row $((cols / 2 - ${#menu[$i]} / 2))
            echo "  ${menu[$i]}"
        fi
        ((current_row++))
    done
}

function sub-menu {
    if [[ "$1" == "menuServidor" ]]; then
        echo "All is good ${1}"

    elif [[ "$1" == "menuNginx" ]]; then
        while true; do
                          show-menu
                          read -rsn1 key
                          case $key in
                              "")
                                  clear
                                  if [[ $selected -eq $(( ${#menu[@]} - 1 )) ]]; then # Exit
                                      tput cnorm
                                      break
                                  else
                                      line=${menu[$selected]}
                                      # Main Code
                                      if [ "$line" == "Update" ]
                                      then
                                        banner "Nginx" "Configuracão" "Atualização"
                                          titulo "Atualizando o sistema..."


                                          function app0(){

                                            declare -A myArray
                                              myArray[A]="sudo apt-get update -y"
                                              myArray[B]="sudo apt-get upgrade -y"

                                            dados=$(jstrings ' && ' "${myArray[@]}")
                                            #echo $dados >> update.txt
                                            esperar "$dados" "${WHITE}Atualizando..." "Atualizado!"

                                          }
                                          #app0

                                          function app1(){

                                            start=$(date +%s%3N)

                                            start_loading "Atualizando..."
                                            sudo apt-get update -y
                                            sudo apt-get upgrade -y > /dev/null 2>&1
                                            stop_loading $?

                                            end=$(date +%s%3N)
                                            echo "Tempo de execução: $(($end-$start)) segundos" > tempo.txt


                                        }
                                          esperar app1 "${WHITE}Atualizando... " "Atualizado!"
                                          var=$(cat tempo.txt)
                                          clearLastLines 1
                                          echo -e "$var\n"


                                      elif [ "$line" == "Password" ]
                                      then
                                          banner "Nginx" "Configuracão" "Password"
                                          titulo "Atualizando a password..."

                                          word=$(whiptail --title "Password root" --passwordbox "Nova password?" 10 60 "${password}" 3>&1 1>&2 2>&3)
                                          exitstatus=$?
                                          if [ $exitstatus = 0 ]; then
                                            esperar "${word} | passwd --stdin root" "${WHITE}Atualizando..." "Atualizado"
                                            return 0
                                          else
                                            echo "Cancelou a operação."
                                            return 0
                                          fi


                                      elif [ "$line" == "Reload" ]
                                      then
                                        banner "Nginx" "Configuracão" "Cnf1"
                                          titulo "Reload nginx"
                                          declare -A myArray
										  sudo su
										  pause
                                            myArray[A]="sudo nginx -t"
                                            myArray[B]="sudo systemctl reload nginx"
                                          dados=$(jstrings ' && ' "${myArray[@]}")
                                          #echo $dados >> cnf1.txt
                                          esperar "$dados" "${WHITE}Atualizando..." "Nginx reloaded!"
										  return 0




                                      elif [ "$line" == "Process Stats" ]
                                          then
                                          ps=$(ps -Ao comm,user,cputime,pcpu,pmem,sz,rss,vsz,nlwp,psr,pri,ni)
                                          printf "%s\n" "${ps[@]}" | head -n 1
                                          printf "%s\n" "${ps[@]}" | sort -r -nk4 | head -n 20
                                      elif [ "$line" == "Network Stats" ]
                                          then
                                          ss -t
                                      elif [ "$line" == "Disk Stats" ]
                                          then
                                          lsblk -e7
                                      fi
                                      read -p "Press Enter to continue..."
                                  fi
                                  clear
                              ;;
                              # up
                              "A"|"a")
                                  if [[ $selected -gt 0 ]]; then
                                      selected=$((selected-1))
                                  fi
                              ;;
                              "B"|"b")
                               # down
                                  if [[ $selected -lt $(( ${#menu[@]} - 1 )) ]]; then
                                      selected=$((selected+1))
                                  fi
                              ;;
                          esac
                      done
    else
        return 1
    fi
}


if [[ $? -eq 0 ]]; then
    #echo rest of the script goes here
    #sleep 5
    function ctrl_c() {
        tput cnorm
        clear
        return 1
        #reload "return" "$GLOBAL_VAR"
    }
fi
