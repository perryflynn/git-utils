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
