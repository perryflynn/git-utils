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
    echo "-l, --link            Link local und remote branches with the same name"
    echo "-p, --pull            Merge fetched changes into local branches"
    echo "-d, --delete-orpaned  Delete orphaned local branches"
    echo "-p, --push            Push all local branches and tags to all remotes"
    echo "-s, --summary         Show an summary after all other operations"
    echo
    echo "Other options:"
    echo "--force               Do not ask anything. Just do it."
    echo "-h, --help            Print this help and exit"
    echo
    echo "All operations leave the current working copy alone."
    echo "So you can use this script to sync and do an merge afterwards."
    echo
    echo "The currently selected branch must be pulled manually."
    echo
    echo "Changes in the current branch will pushed,"
    echo "if there are no uncommited changes."
    echo

    exit 0
fi


#
# -> Startup
#

# check required git version
REQUIRED_VERSION=$([ $(printf '%s\n' "2.13.2" "$(git --version | awk '{print $3}')" | sort -V | head -n1) == "2.13.2" ]; echo $?)
if [ $REQUIRED_VERSION -ne 0 ]
then
    echo "This script requires at least git version 2.13.2."
    exit 1
fi

# branch name of the working copy
CURRENT_BRANCH=$(git rev-parse --abbrev-ref HEAD 2> /dev/null)

# is the current working directory a git repo?
GITSTATUS=$?
if [ $GITSTATUS -ne 0 ]
then
    echo "Unable to find an git repository.";
    echo "Is the shell in the correct working directory?"
    exit 1
fi

# status of the working copy
CURRENT_STATUS=$(git status | grep "nothing to commit, working tree clean" > /dev/null 2> /dev/null; echo $?)

info "Current directory: $(pwd)"
