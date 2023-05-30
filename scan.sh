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
deeperdir=()
stop=false
found=false
element_count=0
folder_count=0


 #-------------------------------------

while true
do
  echo
  read -p "Enter the name of the file you are looking for: " filename
  while true 
  do 
    read -p "Enter the path of the directory where you want to start the research: " directory
    if [[ ! -d "$directory" ]]; then
      text "" "red" "Error: Directory not found"
    else 
      break
    fi
  done
  echo
  read -p "Do you want to exclude some folders from the research? (y) " exclude
  if [[ $exclude == "y" ]]; then
    exclude_folders=()
    echo "Enter the path of each folder you want to exclude: " 
    text "italics" "blue" "(press enter when you are done)\r"
    while true
    do 
      echo -n "$directory"
      read exclude_folder
      if [[ $exclude_folder == '' ]]; then
        text "italics" "green" "ok"
        break
      elif [[ $exclude_folder == $directory ]]; then 
        text "italics" "red" "Error: Invalid path"
        continue
      fi
      exclude_folder=$directory$exclude_folder
      if [[ ! -d $exclude_folder ]]; then 
        text "italics" "red" "Error: Invalid path"
        continue
      else
        exclude_folders+=($exclude_folder)
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
    text "bold" "" "-$x" "-n"
    echo ";"
  done
  text "bold" "" "-.git" "-n"
  text "italics" "" "(default)"
  text "bold" "" "-.cache" "-n"
  text "italics" "" "(default)"
  echo 
  echo "confirm = y"
  read -p "restart = [...] " correct
  if [[ $correct == "y" ]]; then
    break
  fi
done
echo

 #-------------------------------------

start_time=$(date +%s)
  #searching in the main directory

current_depth=$(awk -F/ '{print NF-1}' <<< "$directory")
tracked_depth=$current_depth
#echo -e "depth: $current_depth "                                                                         
#sleep 1s                                                                                                 
text "bold" "yellow" "ENTRO IN $directory"
cd "$directory"
((folder_count++))
output=$(ls -a)
for first in $output; do
  if [[ $first != "." && $first != ".." && $first != ".git"  && $any != ".cache" ]]; then
    ((element_count++))
    echo "depth: $current_depth "
    echo "folders digged: $folder_count"
    echo "checked elements: $element_count"
    echo "element checked: $first"
    echo "current position: $directory"
    if [ -f $first ]; then
      #echo "file $first"                                                                                 
      if [[ $first == $filename ]]; then
        file_path=$(pwd)/$first
        text "" "green" "Found: $first\nPosition: $file_path"
        break
      fi
    elif [[ -d $first ]]; then
      #echo "folder $first"                                                                                   
      cd_path=$(pwd)/$first
      currentdir+=($cd_path)
    fi
  fi
  #sleep 1s                                                                                                   
done
#searching in deeper levels
while true
do 
  #actual_current_depth=$((current_depth + level))
  #echo $level $current_depth $actual_current_depth                                                           
  #sleep 2s                                                                                                   
  for folder in "${currentdir[@]}"; 
  do
    avoid=false
    current_depth=$(awk -F/ '{print NF-1}' <<< "$folder")
    ((tracked_depth++))
    for pass in "${exclude_folders[@]}"; do
      #echo $pass , $folder                                                                                   
      if [ "$pass" == "$folder" ]; then
        avoid=true
        text "" "yellow" "Avoiding: $folder"
        sleep 0.5s                                                                                              
      fi
    done
    #sleep 2s                                                                                                 
    if [[ $avoid == false ]]; then
      cd $folder
      ((folder_count++))
      text "bold" "yellow" "ENTRO IN $folder"
      output=$(ls -a)
      for any in $output; do
        if [[ $any != "." && $any != ".." && $any != ".git"  && $any != ".cache" ]]; then
          ((element_count++))
          #clear                                                                                               
          echo "depth: $current_depth "
          echo "folders digged: $folder_count"
          echo "checked elements: $element_count"
          echo "element checked: $any"
          echo "current position: $folder"
          echo -n "elementi currentdir: "
          for y in "${currentdir[@]}"                                                                          
          do                                                                                                   
            echo -n " $y"                                                                                         
          done                                                                                                 
          echo
          sleep 1s                                                                                             
          if [[ -f $any && $any == $filename ]]; then
            #echo "file"                                                                                       
            file_path=$(pwd)/$any
            text "" "green" "\n\nFound: $any\nPosition: $file_path\n"
            found=true
            stop=true
            break
          elif [[ -d $any ]]; then
            #echo "cartella"                                                                                   
            cd_path=$(pwd)/$any
            #this_depth=$(awk -F/ '{print NF}' <<< "$path")                                                    
            #echo $thiscurrent_depth                                                                                                                                                             
            currentdir+=($cd_path)
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
    echo $found
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
text "blue" "" "$element_count elements from $directory scanned in $duration seconds"


#aggiungere possibilità di visualizzare file trovati col nome simile

#controllare funzionamento di esclusione
#sistemare output e provare 'clear'
#codice si ripete probabilmente quando un ramo si esaurisce - fixed controllare

#trovare soluzione per fare tutto dentro al while
#trasformare in funzione utilizzabile in altre cose

#livelli: controllare assegnazione di depth e capire;
# currentdir deve essere implementata quado il livello di profondità contato equivale a quello rilevato dal percorso
# 


#analizzare elementi di currentdir ed eliminare quelli con il livello inferiore