currentdir=()
deeperdir=()
stop=false

read -p "Enter the name of the file you are looking for: " filename
read -p "Enter the path of the directory where you want to start the research: " directory

#controllo input
if [[ ! -d "$directory" ]]; then
    echo "Error: Directory not found: $directory"
else 
#creazione primo livello di profondità in currentdir e scan per il file
    cd "$directory"
    output=$(ls -a)
    for first in $output; do
      if [ -f $first ]; then
        if [[ $first == $filename ]]; then
          file_path=$(pwd)/$first
          echo -e "Found: $first\nPosition: $file_path"
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
      echo -n "ELEMENTI LIVELLO CORRENTE: "
      for element in "${currentdir[@]}"; do
        echo -n $element "; "
      done
      sleep 2
    #controllo ogni cartella del livello corrente
      for deep in "${currentdir[@]}"; do
        echo -e "\nDENTRO A " $deep ":"
        echo
        sleep 2
        cd $deep
        pwd
        output=$(ls -a)
        echo $output
        #scan per il file e creazione nuovo livello di profondità in deeperdir
          for any in $output; do
            if [[ $any != "." && $any != ".." ]]; then
              echo -e "\nesamino " $any "..."
              echo 
              sleep 2
              if [ -f $any ]; then
                if [[ $any == $filename ]]; then
                  file_path=$(pwd)/$any
                  echo -e "Found: $any\nPosition: $file_path"
                  stop=true
                  break
                fi
              elif [[ -d $any ]]; then
                cd_path=$(pwd)/$any
                echo "aggiungo" $cd_path "al prossimo livello"
                deeperdir+=($cd_path)
                echo -n "DEEPERDIR: "
                for x in "${deeperdir[@]}"; do
                  echo -n $x "; "
                done 
              fi
            fi
          done
          if [[ $stop == true ]]; then
            break
          fi
      done
#controllo se il livello di profondità successivo deeperdir è vuoto (fine ricerca)
      if [[ -z $deeperdir ]]; then
        echo "File not found"
        stop=true
      else 
      #imposto il livello appena creato a quello corrente da 
        echo "VERSO " $deeperdir
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

  
