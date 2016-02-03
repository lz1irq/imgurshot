#!/bin/bash


base_folder="${HOME}/pictures/screenshots"
file_name=$(date "+scr-%Y-%m-%d-%H-%M.png")
file_path=${base_folder}/${file_name}

# imgur upload settings
imgur_anon_id="9e603f08c0e541c"
upload_connect_timeout="5"
upload_timeout="120"
upload_retries="3"

handle_upload_success() {
    echo $1
    echo $2 
}

handle_upload_error() {
    echo $1
    echo $2
}

# Origial by jomo from the imgur-screenshot project 
upload_anonymous_image() {
    echo "Uploading '${1}'..."
    title="$(echo "${1}" | rev | cut -d "/" -f 1 | cut -d "." -f 2- | rev)"
    response="$(curl --compressed --connect-timeout "${upload_connect_timeout}" -m "${upload_timeout}" --retry "${upload_retries}" -fsSL --stderr - -H "Authorization: Client-ID ${imgur_anon_id}" -F "title=${title}" -F "image=@\"${1}\"" https://api.imgur.com/3/image)"
    # JSON parser premium edition (not really)
    if egrep -q '"success":\s*true' <<<"${response}"; then
        img_id="$(egrep -o '"id":\s*"[^"]+"' <<<"${response}" | cut -d "\"" -f 4)"
        img_ext="$(egrep -o '"link":\s*"[^"]+"' <<<"${response}" | cut -d "\"" -f 4 | rev | cut -d "." -f 1 | rev)" # "link" itself has ugly '\/' escaping and no https!
        del_id="$(egrep -o '"deletehash":\s*"[^"]+"' <<<"${response}" | cut -d "\"" -f 4)"
    
        handle_upload_success "https://i.imgur.com/${img_id}.${img_ext}" "https://imgur.com/delete/${del_id}" "${1}"
    else 
        err_msg="$(egrep -o '"error":\s*"[^"]+"' <<<"${response}" | cut -d "\"" -f 4)"
        test -z "${err_msg}" && err_msg="${response}"
        handle_upload_error "${err_msg}" "${1}"
    fi
}

gnome-screenshot --area --file=${file_path}
upload_anonymous_image ${file_path}
