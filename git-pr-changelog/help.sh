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
    echo "Create changelogs from Pull Request commit messages"
    echo
    echo "-s, --start             Perform all local operations"
    echo "-e, --end               Perform all local and remote (push) operations"
    echo "--azure-devops          Preset for Azure Devops managed git repos"
    echo "--gitlab                Preset for gitlab managed git repos"
    echo
    echo "Manual format:"
    echo "-f, --format-addition   Choose which fields to be shown. See git-log format"
    echo "-p, --pr-string         String to find pull requests in commit list"
    echo
    echo "Other options:"
    echo "-h, --help              Print this help and exit"
    echo

    exit 0
fi
