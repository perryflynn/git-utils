
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
