#!/bin/bash

base_folder="${HOME}/pictures/screenshots"
file_name=$(date "+scr-%Y-%m-%d-%H-%M.png")
file_path=${base_folder}/${file_name}

echo ${filepath}
gnome-screenshot --area --file=${file_path}
