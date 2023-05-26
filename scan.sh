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
  else
    echo -e "\033[${style};${color}m$3\033[0m"
  fi
}

# Usage: text "style" "color" "string" "-n"


currentdir=()
deeperdir=()
stop=false
found=false

read -p "Enter the name of the file you are looking for: " filename
read -p "Enter the path of the directory where you want to start the research: " directory

#controllo input
if [[ ! -d "$directory" ]]; then
    text "" "red" "Error: Directory not found: $directory"
else 
#creazione primo livello di profondità in currentdir e scan per il file
    cd "$directory"
    output=$(ls -a)
    for first in $output; do
      if [ -f $first ]; then
        if [[ $first == $filename ]]; then
          file_path=$(pwd)/$first
          text "" "green" "Found: $first\nPosition: $file_path"
          break
        fi
      elif [[ -d $first && $first != ".." && $first != "." ]]; then
        cd_path=$(pwd)/$first
        currentdir+=($cd_path)
      fi
    done

    #esplorazione dei livelli sottostanti
    while true
    do 
    #controllo ogni cartella del livello corrente
      for deep in "${currentdir[@]}"; do
        cd $deep
        output=$(ls -a)
        #scan per il file e creazione nuovo livello di profondità in deeperdir
          for any in $output; do
            if [[ $any != "." && $any != ".." ]]; then
              if [[ -f $any && $any == $filename ]]; then
                file_path=$(pwd)/$any
                text "" "green" "Found: $any\nPosition: $file_path"
                found=true
                stop=true
                break
              elif [[ -d $any ]]; then
                cd_path=$(pwd)/$any
                deeperdir+=($cd_path)
              fi
            fi
          done
          if [[ $stop == true ]]; then
            break
          fi
      done
#controllo se il livello di profondità successivo deeperdir è vuoto (fine ricerca)
      if [[ -z $deeperdir && $found == false ]]; then
        text "" "red" "File not found"
        stop=true
      else 
      #imposto il livello appena creato a quello corrente da 
        for ((i=0; i<${#deeperdir[@]}; i++))
        do
            currentdir[$i]=${deeperdir[$i]}
        done
        currentdir=$deeperdir
        deeperdir=()
      fi
      #se il file è stato trovato o se non ci sono più livelli da analizzare, esco dal ciclo
      if [[ $stop == true ]]; then
        break
      fi

    done

fi

  
