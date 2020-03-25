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
