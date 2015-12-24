#! /bin/bash

# function to create all dirs til file can be made
function mkdirs {
    file="$1"
    dir="/"

    # convert to full path
    if [ "${file##/*}" ]; then
        file="${PWD}/${file}"
    fi

    # dir name of following dir
    next="${file#/}"

    # while not filename
    while [ "${next//[^\/]/}" ]; do
        # create dir if doesn't exist
        [ -d "${dir}" ] || mkdir "${dir}"
        dir="${dir}/${next%%/*}"
        next="${next#*/}"
    done

    # last directory to make
    [ -d "${dir}" ] || mkdir "${dir}"
}

# get optional 'o' flag, this will open the image after download
getopts 'o' option
[[ $option = 'o' ]] && shift

# parse arguments
files=${1}
shift
query="$@"
[ -z "$query" ] && exit 1  # insufficient arguments

# set user agent, customize this by visiting http://whatsmyuseragent.com/
useragent='Mozilla/5.0 (X11; Ubuntu; Linux i686; rv:31.0) Gecko/20100101 Firefox/31.0'

# construct google link
link="www.google.cz/search?q=${query}\&tbm=isch&safe=off&tbs=isz:lt,islt:6mp"

# fetch link for download
imageslink=$(wget -e robots=off --user-agent "$useragent" -qO - "$link")


for count in $(seq 1 $files)
do
imagelink=$(echo $imageslink | sed 's/</\n</g' | grep '<a href.*\(png\|jpg\|jpeg\)' | sed 's/.*imgurl=\([^&]*\)\&.*/\1/' | head -n $count | tail -n1)
imagelink="${imagelink%\%*}"

# get file extention (.png, .jpg, .jpeg)
ext=$(echo $imagelink | sed "s/.*\(\.[^\.]*\)$/\1/")

# set default save location and file name change this!!
dir="$PWD"
file="image_${query}_${count}"

# construct image link: add 'echo "${google_image}"'
# after this line for debug output
google_image="${dir}/${file}"

# get actual picture and store in google_image.$ext
wget --max-redirect 0 -qO "${google_image}" "${imagelink}" &

# if 'o' flag supplied: open image
[[ $option = "o" ]] && gnome-open "${google_image}"
done
# successful execution, exit code 0
exit 0
