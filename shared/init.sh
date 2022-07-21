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

# default remote
REMOTE_EXISTS=$(git remote | grep -P "^$ARG_REMOTE$" 2>&1 > /dev/null; echo $?)

if [ $REMOTE_EXISTS -ne 0 ]
then
    echo "The remote '$ARG_REMOTE' does not exist."
    echo "Please define your default remote by the --remote option."
    exit 1
fi

info "Current directory: $(pwd)"
info "Main branch for remote '$ARG_REMOTE': $(mainbranch "$ARG_REMOTE")"
