#!/bin/bash


text() {
  style=0
  if [[ "$1" == "bold" ]]; then
    style=1
  elif [[ "$1" == "underlined" ]]; then
    style=4
  elif [[ "$1" == "italics" ]]; then
    style=3
  fi

  color=37
  if [[ "$2" == "red" ]]; then
    color=31
  elif [[ "$2" == "yellow" ]]; then
    color=33
  elif [[ "$2" == "green" ]]; then
    color=32
  elif [[ "$2" == "blue" ]]; then
    color=34
  else 
    color=37
  fi

  if [[ -z "$4" ]]; then
    echo -e "\033[${style};${color}m$3\033[0m"
  elif [[ "$4" == "-n" ]]; then
    echo -e -n "\033[${style};${color}m$3\033[0m"
  elif [[ "$4" == "-ne" ]]; then 
    echo -ne "\033[${style};${color}m$3\033[0m"
  else
    echo -e "\033[${style};${color}m$3\033[0m"
  fi
}

currentdir=()
exclude_folders=()
stop=false
found=false
element_count=0
folder_count=0
filename=$1
directory=$2


#-------------------------------------

if [[ ! -d "$directory" ]]; then
  exit 1 #argomento indica una cartella non esistente
fi

if [[ $# -ge 3 ]]; then
  for ((i=2; i<=$#; i++))
  do
    if [[ $exclude_folder == $directory ]]; then
      exit 2 # argomento vuole escludere cartella di partenza
    elif [[ ! -d ${!i} ]]; then
      exit 1 # argomento indica una cartella non esistente
    else
      exclude_folders+=("${!i}")
    fi
  done
fi


#-------------------------------------

currentdir+=$directory
while true;
  do                                                                                            
  for folder in "${currentdir[@]}"; 
  do
    avoid=false
    for pass in "${exclude_folders[@]}"; do                                                                             
      if [ "$pass" == "$folder" ]; then
        avoid=true                                                                                          
      fi
    done                                                                                              
    if [[ $avoid == false ]]; then
      current_depth=$(awk -F/ '{print NF-1}' <<< "$folder")
      cd $folder
      ((folder_count++))
      output=$(ls -a)
      for any in $output; do
        if [[ $any != "." && $any != ".." && $any != ".git"  && $any != ".cache" ]]; then                                                                                      
          if [[ -f $any && $any == $filename ]]; then                                                                                     
            file_path=$(pwd)/$any
            echo $file_path
            found=true
            stop=true
            break
          elif [[ -d $any ]]; then                                                                                
            cd_path=$(pwd)/$any                                                                                                                                                             
            deeperdir+=($cd_path)
          fi
        fi
      done
    fi
      
      if [[ $stop == true ]]; then
        break
      fi
  done

  currentdir=()
  for xx in "${deeperdir[@]}"; 
  do
    this_depth=$(awk -F/ '{print NF-1}' <<< "$xx")
    if [[ $this_depth != $current_depth ]]; then 
      currentdir+=("$xx")
    fi
  done
  deeperdir=()

  if [[ -z $currentdir && $found == false ]]; then
    exit 3 #file specificato non trovato
    stop=true
  fi
  if [[ $stop == true ]]; then
    break
  fi
done
