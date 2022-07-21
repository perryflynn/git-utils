#
# -> Arguments
#

ARG_START=""
ARG_END=""
ARG_PRSTR=""
ARG_FORMATADDITION=""
ARG_REMOTE=origin
ARG_HELP=0
UNKNOWN_OPTION=0

if [ $# -ge 1 ]
then
    while [[ $# -ge 1 ]]
    do
        key="$1"
        case $key in
            -s|--start)
                ARG_START=$2
                shift
                ;;
            -e|--end)
                ARG_END=$2
                shift
                ;;
            -f|--format-addition)
                ARG_FORMATADDITION=$2
                shift
                ;;
            -p|--pr-string)
                ARG_PRSTR=$2
                shift
                ;;
            -h|--help)
                ARG_HELP=1
                ;;
            --azure-devops)
                ARG_PRSTR="Merged PR"
                ARG_FORMATADDITION=" - %s"
                ;;
            --gitlab)
                ARG_PRSTR="See merge request"
                ARG_FORMATADDITION=" - %b"
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