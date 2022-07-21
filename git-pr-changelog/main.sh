if [ -z "$ARG_START" ]; then
    echo
    echo "Argument --start is required."
    exit 1
fi

if [ -z "$ARG_END" ]; then
    echo
    echo "Argument --end is required."
    exit 1
fi

if [ -z "$ARG_FORMATADDITION" ] || [ -z "$ARG_PRSTR" ]; then
    echo
    echo "Format and pr string or preset required."
    echo "See --help for more infos."
    exit 1
fi

# colors
#bakheadl='\033[100m'   # Black - Background
txtheadl='\033[4;94m' # Yellow - underline
txthl='\033[0;32m' # Green
txtrst='\033[0m'    # Text Reset

# show choosen range
echo
echo -e "${txtheadl}Changelog based on completed Merge Reuqests${txtrst}"
echo
echo -e "Project: ${txthl}$(pwd)${txtrst}"
echo
echo -e "Current Branch: ${txthl}$(git symbolic-ref --short HEAD)${txtrst}"
echo -e "Remote: ${txthl}$(git remote get-url --push origin)${txtrst}"
echo -e "Start Ref: ${txthl}${ARG_START}${txtrst}"
echo -e "End Ref: ${txthl}${ARG_END}${txtrst}"
echo

# fancy log messages
while read LINE; do

    git show -s --format="%h - %ar${ARG_FORMATADDITION}" "$LINE" | tr '\n' ' '
    echo

done <<< "$(git --no-pager log --pretty=format:"%h" --grep="$ARG_PRSTR" ${ARG_START}..${ARG_END})"

echo
echo -e "Generated at ${txthl}$(date)${txtrst}"
