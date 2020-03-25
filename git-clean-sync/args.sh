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
