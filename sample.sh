#!/bin/bash

path=$(./scan.sh [file_to_search] [starting_directory] [excluded_directory] [excluded_directory] [...])
exit_code=$?

if [[ $exit_code -eq 0 ]]; then
  echo $exit_code
  # exit = 0
  # file found
  # path of the file = $path
elif [[ $exit_code -eq 1 ]]; then
  echo $exit_code
  # exit = 1
  # main folder not found
elif [[ $exit_code -eq 2 ]]; then
  echo $exit_code
  # exit = 2
  # main folder excluded
elif [[ $exit_code -eq 3 ]]; then
  echo $exit_code
  # exit = 3
  # excluded folder not found
elif [[ $exit_code -eq 4 ]]; then
  echo $exit_code
  # exit = 4
  # file not found
else
  echo "unknown error"
  # unknown error
fi