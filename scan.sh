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


depth=$(awk -F/ '{print NF-1}' <<< "$path")

currentdir=()
deeperdir=()
stop=false
found=false
err=false
level=1
count=0

while true
do
  echo
  read -p "Enter the name of the file you are looking for: " filename
  read -p "Enter the path of the directory where you want to start the research: " directory
  echo
  read -p "Do you want to exclude some folders from the research? (y) " exclude
  if [[ $exclude == "y" ]]; then
    read -p "Enter the path of the folders you want to exclude (separated by a space): " exclude_folder
    exclude_folders=($exclude_folder)
    for element in "${exclude_folders[@]}"
    do
      if [[ $element == $directory ]]; then
        err=true
        break
      fi
    done
  fi
  echo 

  text "italics" "" "Searching for " "-n"
  text "bold" "" "'$filename' " "-n" 
  text "italics" "" "starting from " "-n"
  text "bold" "" "'$directory'" "-n"
  text "italics" "" ";\nExcluding:\n" "-n"
  for x in "${exclude_folders[@]}"
  do
    text "bold" "" "-$directory/$x" "-n"
    echo ";"
  done
  text "bold" "" "-.git" "-n"
  text "italics" "" "(default)"
  text "bold" "" "-.cache" "-n"
  text "italics" "" "(default)"
  echo
  read -p "proceed? (y) " correct
  if [[ $correct == "y" ]]; then
    break
  fi
done

start_time=$(date +%s)
if [[ ! -d "$directory" ]]; then
  text "" "red" "Error: Directory not found: $directory"
elif [[ $err == true ]]; then
  text "" "red" "Error: You can't exclude the directory you are searching in"

  #searching in the main directory
else 
  depth=$(awk -F/ '{print NF-1}' <<< "$directory")
  echo -e "depth: $level "
  cd "$directory"
  output=$(ls -a)
    for first in $output; do
      if [[ $first != "." && $first != ".." && $first != ".git"  && $any != ".cache" ]]; then
        ((count++))
        if [ -f $first ]; then
          if [[ $first == $filename ]]; then
            file_path=$(pwd)/$first
            text "" "green" "Found: $first\nPosition: $file_path"
            break
          fi
        elif [[ -d $first ]]; then
          cd_path=$(pwd)/$first
          currentdir+=($cd_path)
        fi
      fi
    done
#searching in deeper levels
    while true
    do 
      ((level++))
      actual_depth=$((depth + level))
      for folder in "${currentdir[@]}"; 
      do
        avoid=false

        for pass in "${exclude_folders[@]}"; do
          if [ "$pass" == "$folder" ]; then
            avoid=true
            text "" "yellow" "Avoiding: $folder"
            sleep 1s
          fi
        done

        if [[ $avoid == false ]]; then
          cd $folder
          output=$(ls -a)
          for any in $output; do
            clear 
            echo "dept: $level "
            echo "checked elements: $count"
            echo "current position: $folder"
            for y in "${currentdir[@]}"
            do
              echo $y
            done
            sleep 1s
            if [[ $any != "." && $any != ".." && $any != ".git"  && $any != ".cache" ]]; then
              ((count++))
              if [[ -f $any && $any == $filename ]]; then
                file_path=$(pwd)/$any
                text "" "green" "\n\nFound: $any\nPosition: $file_path\n"
                found=true
                stop=true
                break
              elif [[ -d $any ]]; then
                cd_path=$(pwd)/$any
                thisdepth=$(awk -F/ '{print NF-1}' <<< "$path")
                if [[ $actual_depth -eq $thisdepth ]]; then
                  currentdir+=($cd_path)
                fi
              fi
            fi
          done
        fi
          
          if [[ $stop == true ]]; then
            break
          fi
      done
      if [[ -z $deeperdir && $found == false ]]; then
        text "" "red" "File not found"
        stop=true
      else 
        for ((i=0; i<${#deeperdir[@]}; i++))
        do
            currentdir[$i]=${deeperdir[$i]}
        done
        currentdir=$deeperdir
        deeperdir=()
      fi
      if [[ $stop == true ]]; then
        break
      fi

    done
    end_time=$(date +%s)
    duration=$((end_time - start_time))
    echo "$duration"

fi


#aggiungere possibilità di escludere cartelle dalla ricerca - 
#aggiungere possibilità di visualizzare file trovati col nome simile
#controllare differenza tra folder e path
#controllare funzionamento di esclusione
#sistemare output e provare 'clear'
#trovare soluzione per fare tutto dentro al while
#trasformare in funzione utilizzabile in altre cose 
#codice si ripete probabilmente quando un ramo si esaurisce - fixed controllare


