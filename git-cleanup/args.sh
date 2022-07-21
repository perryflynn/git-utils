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
