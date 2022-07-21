#
# -> Print Help
#

if [ $ARG_HELP -eq 1 ]
then
    if [ $UNKNOWN_OPTION -eq 1 ]
    then
        echo
        echo "Error: Unknown arguments found."
    fi

    echo
    echo "git cleanup script"
    echo
    echo "The operations will executed in the order as displayed here:"
    echo
    echo "Operations:"
    echo "-a, --all                     Perform all operations"
    echo "                              operations on the current working copy possible"
    echo "--local-branches              Delete local branches unchanged more than X days"
    echo "--untracked-remote-branches   Delete untracked remote branches unchanged more than X days"
    echo
    echo "Other options:"
    echo "--max-age 60                  Max branch age in days, default is 60"
    echo "-r, --remote                  Set the default remote, default: origin"
    echo "-h, --help                    Print this help and exit"
    echo

    exit 0
fi
