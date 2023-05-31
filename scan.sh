#!/bin/bash

currentdir=()
exclude_folders=()
stop=false
found=false
element_count=0
folder_count=0
filename=$1
directory=$2



#-------------------------------------
#CHECK FOR ARGUMENTS VALIDITY

if [[ ! -d "$directory" ]]; then
  exit 1 
fi

if [[ $# -ge 3 ]]; then
  for ((i=2; i<=$#; i++))
  do
    if [[ $exclude_folder == $directory ]]; then
      exit 2 
    elif [[ ! -d ${!i} ]]; then
      exit 3
    else
      exclude_folders+=("${!i}")
    fi
  done
fi


#-------------------------------------
#EXECUTION OF RESEARCH

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

    if [[ $stop == true && $found == true ]]; then
      echo "$file_path"
      exit 0 
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
    exit 4 
    stop=true
  fi

done


