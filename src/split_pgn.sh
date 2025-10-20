#!/bin/bash

# function that makes sure we got exactly 2 arguments
validate_args_amount(){
    if [ $# != 2 ]; then   
        echo -e "\e[31mUsage: $0 <source_pgn_file> <destination_directory>\e[0m"
        exit 1
    fi
}

# validate that the PGN file exist
validate_input_exist(){
    if ! [ -f "$1" ]; then
        echo -e "\e[31mError: File '$1' does not exist.\e[0m"
        exit 1
    fi
}

# create folder name
create_folder_name(){
    dir=$(dirname "$(dirname "$1")")
    echo "$dir/$2"
}

# create folder if necessary
create_folder_if_necessary(){
    if ! [ -d "$1" ]; then
        echo -e "\e[32mCreated directory '$2'.\e[0m"
        mkdir "$1"
    fi
}

# split the PNG file
split(){
    # create variables
    local input_file_path="$1"
    local output_folder="$2"
    local file_name_with_extension=$(basename "$input_file_path")
    local file_name_without_extension="${file_name_with_extension%.*}"
    local new_lines_amount=0
    local game_number=0
    local is_new_file=true

    # iterate over the lines in the input file
    while read line; do
        # create new file
        if $is_new_file; then
            ((game_number++))
            local temp_file_path="$output_folder/$file_name_without_extension"_"$game_number".pgn
            touch "$temp_file_path"
            is_new_file=false
        fi
        # handle empty line
        if [ -z "$line" ]; then
            ((new_lines_amount++))
            # handle end of game
            if [ "$new_lines_amount" = 2 ]; then
                new_lines_amount=0
                is_new_file=true
                echo -e "Saved game to ${temp_file_path#./}"
                continue
            fi
        fi
        # write the line into the file
        echo "$line" >> "$temp_file_path"
    done <$input_file_path
    echo -e "\e[32mAll games have been split and saved to '${output_folder#./}'.\e[0m"
}

# script starts here

# validate the amount of arguments
validate_args_amount "$@"
# validate the input file exist
validate_input_exist "$1"
# create and save the output folder name
output_folder=$(create_folder_name "$1" "$2")
# create the output folder if it's not exist
create_folder_if_necessary "$output_folder" "$2"
# split the file
split "$1" "$output_folder"
