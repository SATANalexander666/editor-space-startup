#!/usr/bin/bash

path_with_file=$@
file=$(echo ${path_with_file} | sed 's@.*/@@')

extensions=" .c .cpp .rs .py "
is_executable=0

for ext in ${extensions}
do
    if [[ ${file} == *"${ext}" ]]; then
        is_executable=1
        break
    fi
done

if [[ ${is_executable} == 0 ]] || [[ ${file} != *"."* ]]; 
then
    ${VISUAL:-EDITOR} ${path_with_file}
    echo "short"
    exit
fi

path=$(echo ${path_with_file} | sed 's![^/]*$!!')
path=${path::-1}

cur_work_space=$(wmctrl -d | grep '*' | cut -d ' ' -f1)
next_work_space=$((${cur_work_space} + 1))

terminator --working-dir=${path} &
terminal_pid=$!

windows_list=$(wmctrl -l)
short_path=${path#"/home/axr"}
created_terminal="${USER}@$(hostname):~${short_path}"

while [[ ${windows_list} != *"${created_terminal}"* ]]; 
do
    windows_list=$(wmctrl -l)
done

windows_list=$(wmctrl -l)
arr=(${windows_list})
arr_length=${#arr[@]}

for arr_idx in ${!arr[@]}
do
    idx=$((arr_length - arr_idx - 1)) 
    if [[ ${arr[${idx}]} == ${created_terminal} ]]; then
        terminal_addres=${arr[idx - 3]}
        break
    fi
done

wmctrl -i -r ${terminal_addres} -t ${next_work_space}

${VISUAL:-EDITOR} ${path_with_file}

kill ${terminal_pid}

