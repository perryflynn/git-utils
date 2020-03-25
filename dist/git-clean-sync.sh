#!/bin/bash

# by Christian Blechert <christian@serverless.industries>
# License: MIT
# https://github.com/perryflynn/git-utils


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
            declare ${allvar}=2
            return 0
        else
            return $answer
        fi
    fi
}

# execute the callback function for each tracking branch
execon_trackingbranches() {
    local command=$1
    local runcondition=$2

    input "git branch -vv"

    tracked=$(git branch -vv --format "%(refname:short)%09%(upstream:remotename)%09%(upstream:lstrip=3)%09%(upstream:track)%09" | grep -P '^[^\t]+\t[^\t]+\t' | grep -v -P '\t\[gone\]\t$')
    tracked_result=$?
    tracked_oneline=$(echo "$tracked" | awk '{print $1}' | sed -z 's/\n/, /g' | sed -r 's/[ ,]+$//g')
    tracked_count=$(echo "$tracked" | wc -l)

    if [ $tracked_result -ne 0 ]; then
        tracked_count=0
    fi

    info "Found $tracked_count tracked branches: $tracked_oneline"

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
    local runcondition=$2

    input "git branch -vv"
    untracked=$(git branch -vv --format "%(refname:short)%09%(upstream:remotename)%09%(upstream:lstrip=3)%09%(upstream:track)%09" | grep -v -P "^.+\t.+\t.+\t$")
    untracked_result=$?
    untracked=$(echo "$untracked" | awk '{print $1}')
    untracked_oneline=$(echo "$untracked" | sed -z 's/\n/, /g' | sed -r 's/[ ,]+$//g')
    untracked_count=$(echo "$untracked" | wc -l)

    if [ $untracked_result -ne 0 ]; then
        untracked_count=0
    fi

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



#
# -> Arguments
#

ARG_TEMPBRANCH=0
ARG_FETCH=0
ARG_LINK=0
ARG_PULL=0
ARG_DELORPHANED=0
ARG_PUSH=0
ARG_SUMMARY=0
ARG_FORCE=0
ARG_HELP=0
UNKNOWN_OPTION=0

if [ $# -ge 1 ]
then
    while [[ $# -ge 1 ]]
    do
        key="$1"
        case $key in
            -a|--all-pull)
                ARG_FETCH=1
                ARG_LINK=1
                ARG_PULL=1
                ARG_DELORPHANED=1
                ARG_SUMMARY=1
                ;;
            -aa|--all-twoway)
                ARG_FETCH=1
                ARG_LINK=1
                ARG_PULL=1
                ARG_DELORPHANED=1
                ARG_PUSH=1
                ARG_SUMMARY=1
                ;;
            -aaa|--all-full)
                ARG_TEMPBRANCH=1
                ARG_FETCH=1
                ARG_LINK=1
                ARG_PULL=1
                ARG_DELORPHANED=1
                ARG_PUSH=1
                ARG_SUMMARY=1
                ;;
            -t|--temp-branch)
                ARG_TEMPBRANCH=1
                ;;
            -f|--fetch)
                ARG_FETCH=1
                ;;
            -l|--link)
                ARG_LINK=1
                ;;
            -p|--pull)
                ARG_PULL=1
                ;;
            -d|--delete-orpaned)
                ARG_DELORPHANED=1
                ;;
            -p|--push)
                ARG_PUSH=1
                ;;
            -s|--summary)
                ARG_SUMMARY=1
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



#
# -> create temp branch
#

TEMPBRANCH=""

if [ "$ARG_TEMPBRANCH" -eq 1 ]
then
    # Workflow:
    # - create a new temp branch to make fetch/merge/etc possible on all branches

    action "Create and checkout a temporary branch..."
    TEMPBRANCH=$(basename "$(mktemp --dry-run)")

    input "git checkout -b $TEMPBRANCH"
    { git checkout -b "$TEMPBRANCH" 2>&3 | output; } 3>&1 1>&2 | error
fi


#
# -> update remote branches
#

if [ "$ARG_FETCH" -eq 1 ]
then
    # Workflow:
    # - fetch changes of all remote branches from remote to local repo
    # - create new remote branches on local repo
    # - delete remote branches on local repo if it doesn't exists on remote anymore
    # - same for tags

    action "Fetch all changes from remote..."
    input "git fetch --all --prune --tags"
    { git fetch --all --prune --tags 2>&3 | output; } 3>&1 1>&2 | error
fi


#
# -> link local branches and remote branches
#

if [ "$ARG_LINK" -eq 1 ]
then
    # Workflow:
    # For each untracked branch:
    # - find remote branch with the same name
    # - check if exactly one candidate was found
    # - check if this candidate is not used by another local branch
    # - link local branch and remote branch

    action "Find unlinked local and remote branches with the same name and link them..."

    LINKALL=1
    if [ $ARG_FORCE -eq 1 ]; then
        # skip delete questions if force argument is set
        LINKALL=2
    fi

    # this function is called for each untracked branch
    linkbranch() {
        local branchname=$1

        # find matching remote branch
        remotebranches=$(git branch -vv -r --format "%(refname:short)" | grep -P "/${branchname}$")
        remotebranches_result=$?
        remotebranches_oneline=$(echo "$remotebranches" | sed -z 's/\n/, /g' | sed -r 's/[ ,]+$//g')
        remotebranches_count=$(echo "$remotebranches" | wc -l)

        if [ $remotebranches_result -ne 0 ]; then
            remotebranches_count=0
        fi

        if [ $remotebranches_count -gt 1 ]
        then
            # multiple candidates are not supported, ask for manual action
            info "Multiple linking candidates found: $remotebranches_oneline"
            info "Please link manually with 'git branch -u remotebranch localbranch'."
        elif [ $remotebranches_count -eq 1 ]
        then

            # check if remote branch is already in use
            alreadyinuse=$(git branch -vv --format "%(upstream:lstrip=2)" | grep -P "^${remotebranches}$" 2>&1 > /dev/null; echo $?)

            if [ $alreadyinuse -ne 0 ]
            then
                multiquestion "Link '$branchname' with '$remotebranches'" "LINKALL"
                answer=$?

                # link remote and local branch together
                if [ $answer -eq 0 ]
                then
                    action "Link '$branchname' with '$remotebranches'..."
                    input "git branch -u $remotebranches $branchname"
                    { git branch -u "$remotebranches" "$branchname" 2>&3 | output; } 3>&1 1>&2 | error
                fi
            fi

        fi
    }

    # find untracked branches and pass the branch name to the linkbranch function
    execon_untrackedbranches linkbranch
fi


#
# -> update local branches
#

if [ "$ARG_PULL" -eq 1 ]
then
    # Workflow:
    # For each tracked branch:
    # - Merge changes from remote branch into existing local branch
    # - Only merge if there are incoming changes
    # - DO NOT perform an checkout

    action "Integrate changes into tracking branches..."

    # this function is called for each tracked branch
    fetchbranch() {
        local branch=$1
        local remote=$2
        local remotebranch=$3

        if [ -z "$TEMPBRANCH" ] && [ "$branch" == "$CURRENT_BRANCH" ]
        then
            # skip branch which is used by the current working copy
            info "Skip current branch '$branch'. Please do a manual 'git pull' to refresh this branch."
        else
            # check for incoming changes
            isopenchanges=$(git branch -vv --format "%(refname:short)%09%(upstream:trackshort)" | grep -P "^${branch}\t" | grep -P "\t<$" 2>&1 > /dev/null; echo $?)

            if [ $isopenchanges -eq 0 ]
            then
                # merge changes from remote branch into local branch
                input "git fetch $remote $branch:$remotebranch"
                { git fetch "$remote" "$branch":"$remotebranch" 2>&3 | output; } 3>&1 1>&2 | error
            else
                # skip because there are no incoming changes
                info "Skip branch '$branch' because there are no incoming changes."
            fi
        fi
    }

    # find tracked branches and pass the branch name to the fetchbranch function
    execon_trackingbranches fetchbranch
fi


#
# -> delete orphaned branches
#

if [ "$ARG_DELORPHANED" -eq 1 ]
then
    # Workflow:
    # - Find local branches which are linked to a remote branch
    #   where the remote branch does not exists on the remote anymore
    # - Delete the local branch (after safety-question)

    action "Find orphaned branches..."
    input "git branch -vv"

    orphaned=$(git branch -vv --format "%(refname:short)%09%(upstream:short)%09%(upstream:track)%09" | grep -P '\t\[gone\]\t$')
    orphaned_result=$?
    orphaned_count=$(echo "$orphaned" | wc -l)

    if [ $orphaned_result -ne 0 ]; then
        orphaned_count=0
    fi

    info "Found $orphaned_count orphaned branches."
    { git branch -vv | grep -F ': gone] ' 2>&3 | output; } 3>&1 1>&2 | error

    # loop all orphaned branches
    I=1
    DELETEALL=1

    if [ $ARG_FORCE -eq 1 ]; then
        # skip delete questions if force argument is set
        DELETEALL=2
    fi

    while [ $I -le $orphaned_count ]
    do
        branchline=$(echo "$orphaned" | tail -n +$I | head -n 1)
        branchname=$(echo "$branchline" | awk '{print $1}')

        if [ -z "$TEMPBRANCH" ] && [ "$branchname" == "$CURRENT_BRANCH" ]
        then
            # skip deleting branch if used by the current working copy
            info "Skip current branch '$branchname'. Please checkout an another branch and try again."
        else
            multiquestion "Delete branch '$branchname'" "DELETEALL"
            answer=$?

            if [ $answer -eq 0 ]
            then
                # delete the branch
                action "Delete branch '$branchname'..."
                input "git branch -D $branchname"
                { git branch -D "$branchname" 2>&3 | output; } 3>&1 1>&2 | error
            fi
        fi

        I=$(($I+1))
    done
fi


#
# -> push all local branches
#

if [ "$ARG_PUSH" -eq 1 ]
then
    # Workflow:
    # For each tracking branch:
    # - Push changes to respective remote
    # - Skip branch which is used by current working copy if there are pending changes
    # - Only push if the branch if there are outgoing changes
    # - DO NOT perform an checkout

    action "Push changes in tracking branches to the remotes..."

    # this function is called for each tracked branch
    pushbranch() {
        local branch=$1
        local remote=$2
        local remotebranch=$3

        if [ -z "$TEMPBRANCH" ] && [ "$branch" == "$CURRENT_BRANCH" ] && [ $CURRENT_STATUS -ne 0 ]
        then
            info "Skip current branch '$branch' because of pending changes. Check 'git status'."
        else
            # check for open changes (local branch ahead of remote branch)
            isopenchanges=$(git branch -vv --format "%(refname:short)%09%(upstream:trackshort)" | grep -P "^${branch}\t" | grep -P "\t>$" 2>&1 > /dev/null; echo $?)
            if [ $isopenchanges -eq 0 ]
            then
                # push
                input "git push $remote $branch:$remotebranch"
                { git push "$remote" "$branch":"$remotebranch" 2>&3 | output; } 3>&1 1>&2 | error
            else
                # skip, no changes available
                info "Skip branch '$branch' because there are no outgoing changes."
            fi
        fi
    }

    # find tracked branches and pass the branch name to the pushbranch function
    execon_trackingbranches pushbranch
fi


#
# -> Cleanup temporary branch
#

if [ ! -z "$TEMPBRANCH" ]
then
    # Workflow:
    # - Return to the previous selected branch
    # - Delete temporary branch

    action "Checkout '$CURRENT_BRANCH' and delete the temporary branch..."

    # check if the branch still exist
    input "git rev-parse --quiet --verify $CURRENT_BRANCH"
    isexist=$(git rev-parse --quiet --verify "$CURRENT_BRANCH" > /dev/null; echo $?)
    checkoutsuccess=1

    if [ $isexist -eq 0 ]
    then
        input "git checkout $CURRENT_BRANCH"
        { git checkout "$CURRENT_BRANCH" 2>&3 | output; } 3>&1 1>&2 | error
        checkoutsuccess=0
    else
        info "The branch '$CURRENT_BRANCH' doesn't exist anymore, use first branch in list."
        input "git branch -vv"
        fistbranch=$(git branch -vv --format "%(refname:short)" | grep -v -P "^${TEMPBRANCH}$" | head -n 1)

        if [ -z "$fistbranch" ]
        then
            info "Unable to find another branch, abort checkout."
        else
            action "Checkout '$fistbranch' as a replacement for '$CURRENT_BRANCH'..."
            input "git checkout $fistbranch"
            { git checkout "$fistbranch" 2>&3 | output; } 3>&1 1>&2 | error
            checkoutsuccess=0
        fi
    fi

    if [ $checkoutsuccess -eq 0 ]
    then
        input "git branch -D $TEMPBRANCH"
        { git branch -D "$TEMPBRANCH" 2>&3 | output; } 3>&1 1>&2 | error
    else
        info "Please checkout the desired branch manually and delete the temporary branch '$TEMPBRANCH' afterwards."
    fi
fi


#
# -> show an summary
#

if [ $ARG_SUMMARY -eq 1 ]
then
    action "Show the current state of all local branches..."
    input "git branch -vv"
    { git branch -vv 2>&3 | output; } 3>&1 1>&2 | error

    action "Show the current state of all remote branches..."
    input "git branch -vv -r"
    { git branch -vv -r 2>&3 | output; } 3>&1 1>&2 | error
fi



