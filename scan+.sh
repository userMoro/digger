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
currentdir+=$directory

while true
do                                                                                                 
  for folder in "${currentdir[@]}"; 
  do
    avoid=false
    for pass in "${exclude_folders[@]}"; do                                                                             
      if [ "$pass" == "$folder" ]; then
        avoid=true
        text "" "yellow" "Avoiding: $folder"
        sleep 0.5s                                                                                              
      fi
    done                                                                                              
    if [[ $avoid == false ]]; then
      current_depth=$(awk -F/ '{print NF-1}' <<< "$folder")
      cd $folder
      ((folder_count++))
      text "bold" "yellow" "ENTRO IN $folder"
      output=$(ls -a)
      for any in $output; do
        if [[ $any != "." && $any != ".." && $any != ".git"  && $any != ".cache" ]]; then
          ((element_count++))                                                                                              
          echo "depth: $current_depth "
          echo "folders digged: $folder_count"
          echo "checked elements: $element_count"
          echo "current element: $any"
          echo "current position: $folder"
          echo -n "elementi currentdir:"
          for y in "${currentdir[@]}"                                                                          
          do                                                                                                   
            echo -n " $y"                                                                                         
          done 
          echo   
          echo -n "elementi deeperdir: "
          for yy in "${deeperdir[@]}"                                                                          
          do                                                                                                   
            echo -n " $yy"                                                                                         
          done                                                                                                
          echo
          echo
          sleep 1s                                                                                             
          if [[ -f $any && $any == $filename ]]; then                                                                                     
            file_path=$(pwd)/$any
            text "" "green" "\n\nFound: $any\nPosition: $file_path\n"
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

  text "bold" "yellow" "checking elements of currentdir and depths"
  currentdir=()
  for xx in "${deeperdir[@]}"; 
  do
    this_depth=$(awk -F/ '{print NF-1}' <<< "$xx")
    echo $xx $this_depth
    if [[ $this_depth != $current_depth ]]; then 
      currentdir+=("$xx")
      text "bold" "green" "added $xx"
    fi
  done
  text "bold" "yellow" "ELEMENTI DI CURRENTDIR:"
  for xxx in "${currentdir[@]}"; 
  do 
    echo $xxx
  done
  sleep 5s
  deeperdir=()


  if [[ -z $currentdir && $found == false ]]; then
    text "" "red" "File not found"
    echo $found
    stop=true
  fi
  if [[ $stop == true ]]; then
    break
  fi

done
end_time=$(date +%s)
duration=$((end_time - start_time))
text "bold" "blue" "$element_count elements" "-n"
text "" "blue" " from " "-n"
text "bold" "blue" "$folder_count folders " "-n"
text "" "blue" "scanned starting from " "-n"
text "bold" "blue" "$directory" "-n"
text "" "blue" " in " "-n" 
text "bold" "blue" "$duration seconds"


#currentdir viene implementata male: viene concatenato tutto al primo elemento