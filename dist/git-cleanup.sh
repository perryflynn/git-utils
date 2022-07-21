#!/bin/bash

# by Christian Blechert <christian@serverless.industries>
# License: MIT
# https://github.com/perryflynn/git-utils

set -u



#
# -> Functions
#

# prints an info from type of 'action'
action() {
    echo -e "\e[95m[*] $1\e[39m"
}

# prints an info from type of 'info'
info() {
    echo -e "[i] $1"
}

# prints an info from type of 'input'
input() {
    echo -e "\e[94m[>] $1\e[39m"
}

# pipes command output to stdout with an 'output' prefix
output() {
    sed -re 's/^/[<] /g'
}

# pipes command error output to stdout with an 'error' prefix
error() {
    sed -r 's/^\s+//g' | sed -r $'s/^/\e[31m[!] /g' | sed -re $'s/$/\e[39m/g'
}

# asks an question
question() {
    echo -ne "\e[93m"
    read -p "[?] ${1}? (yes/no/all) [no] " answer
    echo -ne "\e[39m"

    RESULT=1
    case $answer in
        y|yes)
            RESULT=0
            ;;
        n|no)
            RESULT=1
            ;;
        a|all)
            RESULT=2
            ;;
    esac

    return $RESULT
}

# asks multiple questions and handle "all" answer
multiquestion() {
    local questiontext=$1
    local allvar=$2

    answer=${!allvar}

    if [ "$answer" -eq 2 ]
    then
        # 'all' is active, send 'yes' as answer
        return 0
    else
        # 'all' is not active, ask the question
        question "$questiontext"
        answer=$?

        # was the answer 'all'?
        if [ "$answer" == "2" ]
        then
            declare -g ${allvar}=2
            return 0
        else
            return $answer
        fi
    fi
}

# execute the callback function for each tracking branch
execon_trackingbranches() {
    local command=$1
    local runcondition=${2:-}

    input "git branch -vv"

    tracked=$(git branch -vv --format "%(refname:short)%09%(upstream:remotename)%09%(upstream:lstrip=3)%09%(upstream:track)%09" | grep -P '^[^\t]+\t[^\t]+\t' | grep -v -P '\t\[gone\]\t$')
    tracked_result=$?
    tracked_oneline=$(echo "$tracked" | awk '{print $1}' | sed -z 's/\n/, /g' | sed -r 's/[ ,]+$//g')
    tracked_count=$(echo "$tracked" | wc -l)

    if [ $tracked_result -ne 0 ]; then
        tracked_count=0
    fi

    info "Found $tracked_count tracked local branches: $tracked_oneline"

    # execute run condition check
    if [ ! -z "$runcondition" ] && type -t $runcondition 2>&1 > /dev/null
    then
        if $runcondition "$tracked_result" "$tracked_count" "$tracked" "$tracked_oneline"
        then
            return 1
        fi
    fi

    # loop all tracked branches
    I=1
    while [ $I -le $tracked_count ]
    do
        branchline=$(echo "$tracked" | tail -n +$I | head -n 1)
        branchremote=$(echo "$branchline" | awk '{print $2}')
        branchname=$(echo "$branchline" | awk '{print $1}')
        branchnameremote=$(echo "$branchline" | awk '{print $3}')

        # execute the given command for each tracking branch
        $command "$branchname" "$branchremote" "$branchnameremote"

        I=$(($I+1))
    done
}

# execute the callback function for each untracked branch
execon_untrackedbranches() {
    local command=$1
    local runcondition=${2:-}

    input "git branch -vv"
    untracked=$(git branch -vv --format "%(refname:short)%09%(upstream:remotename)%09%(upstream:lstrip=3)%09%(upstream:track)%09" | grep -v -P "^.+\t.+\t.+\t$")
    untracked_result=$?
    untracked=$(echo "$untracked" | awk '{print $1}')
    untracked_oneline=$(echo "$untracked" | sed -z 's/\n/, /g' | sed -r 's/[ ,]+$//g')
    untracked_count=$(echo "$untracked" | wc -l)

    if [ $untracked_result -ne 0 ]; then
        untracked_count=0
    fi

    info "Found $untracked_count untracked local branches: $untracked_oneline"

    # execute run condition check
    if [ ! -z "$runcondition" ] && type -t $runcondition 2>&1 > /dev/null
    then
        if $runcondition "$untracked_result" "$untracked_count" "$untracked" "$untracked_oneline"
        then
            return 1
        fi
    fi

    # loop all tracked branches
    I=1

    while [ $I -le $untracked_count ]
    do
        branchname=$(echo "$untracked" | tail -n +$I | head -n 1)

        # execute callback function with branch
        $command "$branchname"

        I=$(($I+1))
    done
}

execon_untrackedremotebranches() {
    local command=$1

    # get tracking remote branched
    input "git branch -vv"

    tracked=$(git branch -vv --format "%(refname:short)%09%(upstream:remotename)%09%(upstream:lstrip=2)%09%(upstream:track)%09" | grep -P '^[^\t]+\t[^\t]+\t' | grep -v -P '\t\[gone\]\t$')
    tracked_result=$?
    tracked_count=$(echo "$tracked" | wc -l)

    if [ $tracked_result -ne 0 ]; then
        tracked_count=0
    fi

    # get untracked remote branches
    untrackedremotes=""
    untrackedremotes_count=0
    untrackedremotes_result=1
    
    if [ $tracked_count -gt 0 ]; then
        # remove tracked remote branches from the remote branches list
        tracked_regex=$(echo "$tracked" | awk '{print $3}' | sed -z 's/\n/|/g' | sed -r 's/[ |]+$//g')

        # get remote branched and remove all tracked by local branches
        input "git branch -r -vv"

        untrackedremotes=$(git branch -r -vv --format "%(refname:lstrip=2)" | grep -v -P "/HEAD$" | grep -v -P "^($tracked_regex)$")
        untrackedremotes_result=$?
        untrackedremotes_count=$(echo "$untrackedremotes" | wc -l)
    else
        # no tracked remote branches, use all remote branches
        untrackedremotes=$(git branch -r -vv --format "%(refname:lstrip=2)" | grep -v -P "/HEAD$")
        untrackedremotes_result=$?
        untrackedremotes_count=$(echo "$untrackedremotes" | wc -l)
    fi

    if [ $untrackedremotes_result -ne 0 ]; then
        untrackedremotes_count=0
    fi

    untrackedremotes_oneline=$(echo "$untrackedremotes" | sed -z 's/\n/, /g' | sed -r 's/[ ,]+$//g')
    info "Found $untrackedremotes_count untracked remote branches: $untrackedremotes_oneline"

    # loop all tracked branches
    I=1

    while [ $I -le $untrackedremotes_count ]
    do
        branchinfo=$(echo "$untrackedremotes" | tail -n +$I | head -n 1 | sed -re 's|^([^/]+)/(.*)$|\1\t\2|g')
        remotename=$(echo "$branchinfo" | awk '{print $1}')
        branchname=$(echo "$branchinfo" | awk '{print $2}')

        # execute callback function with branch
        $command "$remotename" "$branchname"

        I=$(($I+1))
    done
}

execon_localbranches() {
    local command=$1
    local runcondition=${2:-}

    input "git branch -vv"

    branches=$(git branch -vv --format "%(refname:short)%09" | grep -P '^[^\t]+\t')
    branches_result=$?
    branches_oneline=$(echo "$branches" | awk '{print $1}' | sed -z 's/\n/, /g' | sed -r 's/[ ,]+$//g')
    branches_count=$(echo "$branches" | wc -l)

    if [ $branches_result -ne 0 ]; then
        branches_count=0
    fi

    info "Found $branches_count local branches: $branches_oneline"

    # execute run condition check
    if [ ! -z "$runcondition" ] && type -t $runcondition 2>&1 > /dev/null
    then
        if $runcondition "$branches_result" "$branches_count" "$branches" "$branches_oneline"
        then
            return 1
        fi
    fi

    # loop all local branches
    I=1
    while [ $I -le $branches_count ]
    do
        branchline=$(echo "$branches" | tail -n +$I | head -n 1)
        branchname=$(echo "$branchline" | awk '{print $1}')

        # execute the given command for each tracking branch
        $command "$branchname"

        I=$(($I+1))
    done
}

isreforphaned() {
    local ref=$1
    local maxageindays=$2

    now=$(date +%s)
    maxage=$(( $now - (60 * 60 * 24 * $maxageindays) ))

    branchage=$(git show --quiet --format="%ct" "$ref" | tr -d ' \n\r\t')
    
    date -d "@$branchage" "+%Y-%m-%dT%H:%M"

    if [ $branchage -lt $maxage ]; then
        return 0
    else
        return 1
    fi
}

mainbranch() {
    local remote=$1
    git symbolic-ref "refs/remotes/$remote/HEAD" | sed "s@^refs/remotes/$remote/@@"
}



#
# -> Arguments
#

ARG_UNTRACKEDREMOTEBRANCHES=0
ARG_LOCALBRANCHES=0
ARG_MAXAGEDAYS=60
ARG_REMOTE=origin
ARG_FORCE=0
ARG_DRY=0
ARG_HELP=0
UNKNOWN_OPTION=0

if [ $# -ge 1 ]
then
    while [[ $# -ge 1 ]]
    do
        key="$1"
        case $key in
            -a|--all)
                ARG_UNTRACKEDREMOTEBRANCHES=1
                ARG_LOCALBRANCHES=1
                ;;
            --local-branches)
                ARG_LOCALBRANCHES=1
                ;;
            --untracked-remote-branches)
                ARG_UNTRACKEDREMOTEBRANCHES=1
                ;;
            --max-age)
                ARG_MAXAGEDAYS=$2
                shift
                ;;
            -r|--remote)
                ARG_REMOTE=$2
                shift
                ;;
            --dry-run)
                ARG_DRY=1
                ;;
            --force)
                ARG_FORCE=1
                ;;
            -h|--help)
                ARG_HELP=1
                ;;
            *)
                # unknown option
                ARG_HELP=1
                UNKNOWN_OPTION=1
                ;;
        esac
        shift # past argument or value
    done
else
    # no arguments passed, show help
    ARG_HELP=1
fi



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




if [ $ARG_DRY -ne 0 ]; then
    info "Dry-run mode is active"
fi

#
# -> Local branches
#

if [ $ARG_LOCALBRANCHES -eq 1 ]
then
    # Workflow:
    # - loop through all local branches
    # - if not main branch and last commit older than X days
    # - delete branch

    DELETEALL=1

    if [ $ARG_FORCE -eq 1 ]; then
        # skip delete questions if force argument is set
        DELETEALL=2
    fi

    action "Delete orphaned local branches..."

    deleteoldlocals() {
        local branch=$1

        remotemain=$(mainbranch "$ARG_REMOTE")
        if [ "$remotemain" == "$branch" ]; then
            # skip main branch
            info "Skip local branch '$branch', since it's the main branch"
            return
        fi

        branchts=$(isreforphaned "refs/heads/$branch" 60)
        isorphaned=$?

        if [ $isorphaned -eq 0 ]; then
            multiquestion "Delete local branch '$branch' (last commit: $branchts)" "DELETEALL"
            answer=$?

            if [ $answer -eq 0 ]; then
                info "Delete local branch '$branch'"
                input "git branch -D $branch"
                if [ $ARG_DRY -eq 0 ]; then
                    { git branch -D "$branch" 2>&3 | output; } 3>&1 1>&2 | error
                fi
            fi
        else
            info "Skip local branch '$branch'; last commit: $branchts"
        fi
    }

    # call function for all local branches
    execon_localbranches "deleteoldlocals"

fi


#
# -> Untracked remote branches
#

if [ $ARG_UNTRACKEDREMOTEBRANCHES -eq 1 ]
then
    # Workflow:
    # - Loop through remote branches
    # - If branch not checked out
    # - If branch not the main branch
    # - If the last commit is older than X days
    # - Delete the branch on remote

    DELETEALL=1

    if [ $ARG_FORCE -eq 1 ]; then
        # skip delete questions if force argument is set
        DELETEALL=2
    fi

    action "Delete orphaned remote branches..."

    deleteoldremotes() {
        local remote=$1
        local branch=$2

        remotemain=$(mainbranch "$remote")
        if [ "$remotemain" == "$branch" ]; then
            # skip main branch
            info "Skip remote branch '$branch', since it's the main branch"
            return
        fi

        ref="remotes/$remote/$branch"
        branchts=$(isreforphaned "$ref" 60)
        isorphaned=$?

        if [ $isorphaned -eq 0 ]; then
            multiquestion "Delete remote branch '$ref' (last commit: $branchts)" "DELETEALL"
            answer=$?

            if [ $answer -eq 0 ]; then
                info "Delete remote branch '$branch'"
                input "git push $remote --delete $branch"
                if [ $ARG_DRY -eq 0 ]; then
                    { git push "$remote" --delete "$branch" 2>&3 | output; } 3>&1 1>&2 | error
                fi
            fi
        else
            info "Skip remote branch '$ref'; last commit: $branchts"
        fi
    }

    # call function for all untracked remote branches
    execon_untrackedremotebranches "deleteoldremotes"

fi



