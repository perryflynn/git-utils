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
    echo "git cleanup and synchronization script"
    echo
    echo "The operations will executed in the order as displayed here:"
    echo
    echo "Operations:"
    echo "-a, --all-pull        Perform all local operations"
    echo "-aa, --all-twoway     Perform all local and remote (push) operations"
    echo "-aaa, --all-full      Perform everything including"
    echo "                      for the current working copy branch"
    echo "-t, --temp-branch     Create a temporary branch to make"
    echo "                      operations on the current working copy possible"
    echo "-f, --fetch           Download all current changes"
    echo "--head                Update main branch / HEAD reference from remote"
    echo "-l, --link            Link local und remote branches with the same name"
    echo "-p, --pull            Merge fetched changes into local branches"
    echo "-d, --delete-orpaned  Delete orphaned local branches"
    echo "-p, --push            Push all local branches and tags to all remotes"
    echo "-s, --summary         Show an summary after all other operations"
    echo
    echo "Other options:"
    echo "--force               Do not ask anything. Just do it."
    echo "-r, --remote           Set the default remote, default: origin"
    echo "-h, --help            Print this help and exit"
    echo
    echo "All operations leave the current working copy alone."
    echo "So you can use this script to sync and do an merge afterwards."
    echo
    echo "If the --temp-branch option is used the current selected branch"
    echo "is updated as well. Be careful with uncommitted/unstaged changes/files."
    echo
    echo "The currently selected branch must be pulled manually"
    echo "(except --temp-branch is used)."
    echo
    echo "Changes in the current branch will pushed,"
    echo "if there are no uncommited changes."
    echo

    exit 0
fi
