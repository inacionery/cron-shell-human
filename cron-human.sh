#!/bin/bash
set -o noglob

function Pretty_Time {
	unset prettymin prettyhour prettydow prettymonth prettydom prettydays
    
    if [[ "*" != ${DoM}]] && [["*" != ${DoW} ]]; then
        if [[ "*" = ${DoM:0:1}]] || [["*" = ${DoW:0:1} ]]; then
            prettydays="if it's"
        else    
            prettydays="and"
        fi
    else
        prettydays=""
    fi

    if [[ ${DoM} = "*" ]]; then
		prettydom=""	
	else
		prettydom="on "
        Pretty_DoM
	fi

    if [[ ${Month} = "*" ]]; then
		prettymonth=""	
	else
        prettymonth="in "
        Pretty_Month
	fi
	
    if [[ ${DoW} = "*" ]]; then
		prettydow=""	
	else
		prettydow="on "
        Pretty_DoW
	fi

    if [[  "${min}" =~ ^[0-9]+$ ]] && [[ "${hour}" =~ ^[0-9]+$ ]]; then
        if [[ $(echo ${min} | wc -m ) -le 2 ]]; then 
            prettymin="0${min}"
        else
            prettymin="${min}"
        fi

        if [[ $(echo ${hour} | wc -m ) -le 2 ]]; then
            prettyhour="0${hour}"
        else
            prettyhour="${hour}"
        fi        

        prettytime="At ${prettyhour}:${prettymin} ${prettydom} ${prettydays} ${prettydow} ${prettymonth}.";
        prettytime=$(echo "$prettytime" | tr -s " ")
    else
        prettymin=""
        Pretty_Min

        if [[ ${hour} = "*" ]]; then
            prettyhour=""	
        else
            prettyhour="past "
            Pretty_Hour
        fi

	    prettytime="At ${prettymin} ${prettyhour} ${prettydom} ${prettydays} ${prettydow} ${prettymonth}."
        prettytime=$(echo "$prettytime" | tr -s " ")
	fi
}

function Pretty_DoW {
	DAYS=(Sunday Monday Tuesday Wednesday Thursday Friday Saturday)

    IFS=','
    read -a dowArray  <<< "${DoW}"
    dowArrayLength=${#dowArray[*]}
    dowsArray=()
    for (( n=0; n < ${dowArrayLength}; n++)); do
        if [[ ${dowArray[n]} = "*" ]]; then
		    tempdow="every day-of-week"
        else
            tempdow=""
            values=()
            curArray=${dowArray[n]}
            while [[ "$curArray" =~ [0-9]+|[^0-9]+ ]]; do
                values+=(${BASH_REMATCH[0]})
                curArray="${curArray:${#BASH_REMATCH[0]}}"
            done
            firstValue=${values[0]}
            if [[ "${firstValue}" =~ ^[0-9]+$ ]]; then
                if [[ ${#values[*]} -eq 1 ]]; then
                    tempdow="${DAYS[${firstValue}]}"
                elif [[ "${#values[*]}" -eq 3 ]] && [[ "${values[1]}" = "/" ]] && [[ "${values[2]}" =~ ^[0-9]+$ ]]; then
                    Digit=${values[2]}
			        F_Suffix
                    tempdow="every ${suffix} dow from ${DAYS[${firstValue}]} through ${DAYS[7]}"
                elif [[ "${#values[*]}" -eq 3 ]] && [[ "${values[1]}" = "-" ]] && [[ "${values[2]}" =~ ^[0-9]+$ ]] && [[ "${values[2]}" -ge "${firstValue}" ]]; then
                    tempdow="every day-of-week ${DAYS[${firstValue}]} through ${DAYS[${values[2]}]}"
                elif [[ "${#values[*]}" -eq 5 ]] && [[ "${values[1]}" = "-" ]] && [[ "${values[2]}" =~ ^[0-9]+$ ]] && [[ "${values[2]}" -ge "${firstValue}" ]] && [[ "${values[3]}" = "/" ]] && [[ "${values[4]}" =~ ^[0-9]+$ ]] && [[ 1 -le "${values[4]}" ]]; then
                    Digit=${values[4]}
			        F_Suffix
                    tempdow="every ${suffix} day-of-week from ${DAYS[${firstValue}]} through ${DAYS[${values[2]}]}"
                fi
            elif [[ "${#values[*]}" -eq 3 ]] && [[ "${values[1]}" = "/" ]] && [[ "${values[2]}" =~ ^[0-9]+$ ]] && [[ "${values[0]}" = "*" ]] ; then
                Digit=${values[2]}
                F_Suffix
                tempdow="every ${suffix} day-of-week"
            fi
        fi
        dowsArray+=($tempdow)
    done

    dowArrayLength=${#dowsArray[*]}
    case ${dowArrayLength} in
		0) prettydow+="" ;;
		1) prettydow+="${dowsArray[0]}" ;;
		2) prettydow+="${dowsArray[0]} and ${dowsArray[1]}" ;;
		*) 
            prettydow+="${dowsArray[0]}, "
            for (( n=0; n < ${dowArrayLength} - 1; n++)); do
                prettydow+="${dowsArray[n]}, "
            done
            prettydow+=" and ${dowsArray[${dowArrayLength} - 1]}"
            ;;
	esac
    
    prettydow=${prettydow/every 1st/every}
    prettydow=${prettydow/day-of-week every/every}
    prettydow=${prettydow/, day-of-week/, }
    prettydow=${prettydow/, and day-of-week/, and } 
}

function Pretty_DoM {
    IFS=','
    read -a domArray  <<< "${DoM}"
    domArrayLength=${#domArray[*]}
    domsArray=()
    for (( n=0; n < ${domArrayLength}; n++)); do
        if [[ ${domArray[n]} = "*" ]]; then
		    tempdom="every day-of-month"
        else
            tempdom=""
            values=()
            curArray=${domArray[n]}
            while [[ "$curArray" =~ [0-9]+|[^0-9]+ ]]; do
                values+=(${BASH_REMATCH[0]})
                curArray="${curArray:${#BASH_REMATCH[0]}}"
            done
            firstValue=${values[0]}
            if [[ "${firstValue}" =~ ^[0-9]+$ ]]; then
                if [[ "${#values[*]}" -eq 1 ]]; then
                    tempdom="${firstValue}"
                elif [[ "${#values[*]}" -eq 3 ]] && [[ "${values[1]}" = "/" ]] && [[ "${values[2]}" =~ ^[0-9]+$ ]]; then
                    Digit=${values[2]}
			        F_Suffix
                    tempdom="every ${suffix} day-of-month from ${firstValue} through 31"
                elif [[ "${#values[*]}" -eq 3 ]] && [[ "${values[1]}" = "-" ]] && [[ "${values[2]}" =~ ^[0-9]+$ ]] && [[ "${values[2]}" -ge "${firstValue}" ]]; then
                    tempdom="every day-of-month ${firstValue} through ${values[2]}"
                elif [[ "${#values[*]}" -eq 5 ]] && [[ "${values[1]}" = "-" ]] && [[ "${values[2]}" =~ ^[0-9]+$ ]] && [[ "${values[2]}" -ge "${firstValue}" ]] && [[ "${values[3]}" = "/" ]] && [[ "${values[4]}" =~ ^[0-9]+$ ]] && [[ 1 -le "${values[4]}" ]]; then
                    Digit=${values[4]}
			        F_Suffix
                    tempdom="every ${suffix} day-of-month from ${firstValue} through ${values[2]}"
                fi
            elif [[ "${#values[*]}" -eq 3 ]] && [[ "${values[1]}" = "/" ]] && [[ "${values[2]}" =~ ^[0-9]+$ ]] && [[ "${values[0]}" = "*" ]] ; then
                Digit=${values[2]}
                F_Suffix
                tempdom="every ${suffix} day-of-month"
            fi
        fi
        domsArray+=($tempdom)
    done

    domArrayLength=${#domsArray[*]}
    prettydom+="day-of-month "
    case ${domArrayLength} in
		0) prettydom+="" ;;
		1) prettydom+="${domsArray[0]}" ;;
		2) prettydom+="${domsArray[0]} and ${domsArray[1]}" ;;
		*) 
            prettydom+="${domsArray[0]}, "
            for (( n=0; n < ${domArrayLength} - 1; n++)); do
                prettydom+="${domsArray[n]}, "
            done
            prettydom+=" and ${domsArray[${domArrayLength} - 1]}"
            ;;
	esac
    
    prettydom=${prettydom/every 1st/every}
    prettydom=${prettydom/day-of-month every/every}
    prettydom=${prettydom/, day-of-month/, }
    prettydom=${prettydom/, and day-of-month/, and } 
}

function Pretty_Min {
    IFS=','
    read -a minArray  <<< "${min}"
    minArrayLength=${#minArray[*]}
    minsArray=()
    for (( n=0; n < ${minArrayLength}; n++)); do
        if [[ ${minArray[n]} = "*" ]]; then
		    tempmin="every minute"
        else
            tempmin=""
            values=()
            curArray=${minArray[n]}
            while [[ "$curArray" =~ [0-9]+|[^0-9]+ ]]; do
                values+=(${BASH_REMATCH[0]})
                curArray="${curArray:${#BASH_REMATCH[0]}}"
            done
            firstValue=${values[0]}
            if [[ "${firstValue}" =~ ^[0-9]+$ ]]; then
                if [[ "${#values[*]}" -eq 1 ]]; then
                    tempmin="${firstValue}"
                elif [[ "${#values[*]}" -eq 3 ]] && [[ "${values[1]}" = "/" ]] && [[ "${values[2]}" =~ ^[0-9]+$ ]]; then
                    Digit=${values[2]}
			        F_Suffix
                    tempmin="every ${suffix} minute from ${firstValue} through 59"
                elif [[ "${#values[*]}" -eq 3 ]] && [[ "${values[1]}" = "-" ]] && [[ "${values[2]}" =~ ^[0-9]+$ ]] && [[ "${values[2]}" -ge "${firstValue}" ]]; then
                    tempmin="every minute ${firstValue} through ${values[2]}"
                elif [[ "${#values[*]}" -eq 5 ]] && [[ "${values[1]}" = "-" ]] && [[ "${values[2]}" =~ ^[0-9]+$ ]] && [[ "${values[2]}" -ge "${firstValue}" ]] && [[ "${values[3]}" = "/" ]] && [[ "${values[4]}" =~ ^[0-9]+$ ]] && [[ 1 -le "${values[4]}" ]]; then
                    Digit=${values[4]}
			        F_Suffix
                    tempmin="every ${suffix} minute from ${firstValue} through ${values[2]}"
                fi
            elif [[ "${#values[*]}" -eq 3 ]] && [[ "${values[1]}" = "/" ]] && [[ "${values[2]}" =~ ^[0-9]+$ ]] && [[ "${values[0]}" = "*" ]] ; then
                Digit=${values[2]}
                F_Suffix
                tempmin="every ${suffix} minute"
            fi
        fi
        minsArray+=($tempmin)
    done

    minArrayLength=${#minsArray[*]}
    prettymin+="minute "
    case ${minArrayLength} in
		0) prettymin+="" ;;
		1) prettymin+="${minsArray[0]}" ;;
		2) prettymin+="${minsArray[0]} and ${minsArray[1]}" ;;
		*) 
            prettymin+="${minsArray[0]}, "
            for (( n=0; n < ${minArrayLength} - 1; n++)); do
                prettymin+="${minsArray[n]}, "
            done
            prettymin+=" and ${minsArray[${minArrayLength} - 1]}"
            ;;
	esac
    
    prettymin=${prettymin/every 1st/every}
    prettymin=${prettymin/minute every/every}
    prettymin=${prettymin/, minute/, }
    prettymin=${prettymin/, and minute/, and } 
}

function Pretty_Hour {
    IFS=','
    read -a hourArray  <<< "${hour}"
    hourArrayLength=${#hourArray[*]}
    hoursArray=()
    for (( n=0; n < ${hourArrayLength}; n++)); do
        if [[ ${hourArray[n]} = "*" ]]; then
		    temphour="every hour"
        else
            temphour=""
            values=()
            curArray=${hourArray[n]}
            while [[ "$curArray" =~ [0-9]+|[^0-9]+ ]]; do
                values+=(${BASH_REMATCH[0]})
                curArray="${curArray:${#BASH_REMATCH[0]}}"
            done
            firstValue=${values[0]}
            if [[ "${firstValue}" =~ ^[0-9]+$ ]]; then
                if [[ "${#values[*]}" -eq 1 ]]; then
                    temphour="${firstValue}"
                elif [[ "${#values[*]}" -eq 3 ]] && [[ "${values[1]}" = "/" ]] && [[ "${values[2]}" =~ ^[0-9]+$ ]]; then
                    Digit=${values[2]}
			        F_Suffix
                    temphour="every ${suffix} hour from ${firstValue} through 23"
                elif [[ "${#values[*]}" -eq 3 ]] && [[ "${values[1]}" = "-" ]] && [[ "${values[2]}" =~ ^[0-9]+$ ]] && [[ "${values[2]}" -ge "${firstValue}" ]]; then
                    temphour="every hour ${firstValue} through ${values[2]}"
                elif [[ "${#values[*]}" -eq 5 ]] && [[ "${values[1]}" = "-" ]] && [[ "${values[2]}" =~ ^[0-9]+$ ]] && [[ "${values[2]}" -ge "${firstValue}" ]] && [[ "${values[3]}" = "/" ]] && [[ "${values[4]}" =~ ^[0-9]+$ ]] && [[ 1 -le "${values[4]}" ]]; then
                    Digit=${values[4]}
			        F_Suffix
                    temphour="every ${suffix} hour from ${firstValue} through ${values[2]}"
                fi
            elif [[ "${#values[*]}" -eq 3 ]] && [[ "${values[1]}" = "/" ]] && [[ "${values[2]}" =~ ^[0-9]+$ ]] && [[ "${values[0]}" = "*" ]] ; then
                Digit=${values[2]}
                F_Suffix
                temphour="every ${suffix} hour"
            fi
        fi
        hoursArray+=($temphour)
    done

    hourArrayLength=${#hoursArray[*]}
    prettyhour+="hour "
    case ${hourArrayLength} in
		0) prettyhour+="" ;;
		1) prettyhour+="${hoursArray[0]}" ;;
		2) prettyhour+="${hoursArray[0]} and ${hoursArray[1]}" ;;
		*) 
            prettyhour+="${hoursArray[0]}, "
            for (( n=0; n < ${hourArrayLength} - 1; n++)); do
                prettyhour+="${hoursArray[n]}, "
            done
            prettyhour+=" and ${hoursArray[${hourArrayLength} - 1]}"
            ;;
	esac
    
    prettyhour=${prettyhour/every 1st/every}
    prettyhour=${prettyhour/hour every/every}
    prettyhour=${prettyhour/, hour/, }
    prettyhour=${prettyhour/, and hour/, and } 
}

function Pretty_Month {
	MONTHS=(ZERO January February March April May June July August September October November December)

    IFS=','
    read -a monthArray  <<< "${Month}"
    monthArrayLength=${#monthArray[*]}
    monthsArray=()
    for (( n=0; n < ${monthArrayLength}; n++)); do
    
        if [[ ${monthArray[n]} = "*" ]]; then
		    tempmonth="every month"
        else
            tempmonth=""
            values=()
            curArray=${monthArray[n]}
            while [[ "$curArray" =~ [0-9]+|[^0-9]+ ]]; do
                values+=(${BASH_REMATCH[0]})
                curArray="${curArray:${#BASH_REMATCH[0]}}"
            done
            firstValue=${values[0]}
            if [[ "${firstValue}" =~ ^[0-9]+$ ]]; then
                if [[ "${#values[*]}" -eq 1 ]]; then
                    tempmonth="${MONTHS[${firstValue}]}"
                elif [[ "${#values[*]}" -eq 3 ]] && [[ "${values[1]}" = "/" ]] && [[ "${values[2]}" =~ ^[0-9]+$ ]]; then
                    Digit=${values[2]}
			        F_Suffix
                    tempmonth="every ${suffix} month from ${MONTHS[${firstValue}]} through ${MONTHS[12]}"
                elif [[ "${#values[*]}" -eq 3 ]] && [[ "${values[1]}" = "-" ]] && [[ "${values[2]}" =~ ^[0-9]+$ ]] && [[ "${values[2]}" -ge "${firstValue}" ]]; then
                    tempmonth="every month ${MONTHS[${firstValue}]} through ${MONTHS[${values[2]}]}"
                elif [[ "${#values[*]}" -eq 5 ]] && [[ "${values[1]}" = "-" ]] && [[ "${values[2]}" =~ ^[0-9]+$ ]] && [[ "${values[2]}" -ge "${firstValue}" ]] && [[ "${values[3]}" = "/" ]] && [[ "${values[4]}" =~ ^[0-9]+$ ]] && [[ 1 -le "${values[4]}" ]]; then
                    Digit=${values[4]}
			        F_Suffix
                    tempmonth="every ${suffix} month from ${MONTHS[${firstValue}]} through ${MONTHS[${values[2]}]}"
                fi
            elif [[ "${#values[*]}" -eq 3 ]] && [[ "${values[1]}" = "/" ]] && [[ "${values[2]}" =~ ^[0-9]+$ ]] && [[ "${values[0]}" = "*" ]] ; then
                Digit=${values[2]}
                F_Suffix
                tempmonth="every ${suffix} month"
            fi
        fi
        monthsArray+=($tempmonth)
    done

    monthArrayLength=${#monthsArray[*]}
    case ${monthArrayLength} in
		0) prettymonth+="" ;;
		1) prettymonth+="${monthsArray[0]}" ;;
		2) prettymonth+="${monthsArray[0]} and ${monthsArray[1]}" ;;
		*) 
            prettymonth+="${monthsArray[0]}, "
            for (( n=0; n < ${monthArrayLength} - 1; n++)); do
                prettymonth+="${monthsArray[n]}, "
            done
            prettymonth+=" and ${monthsArray[${monthArrayLength} - 1]}"
            ;;
	esac
    
    prettymonth=${prettymonth/every 1st/every}
    prettymonth=${prettymonth/month every/every}
    prettymonth=${prettymonth/, month/, }
    prettymonth=${prettymonth/, and month/, and } 
}

function F_Suffix {
	case ${Digit} in
		1) suffix="${Digit}st" ;;
		2) suffix="${Digit}nd" ;;
		3) suffix="${Digit}rd" ;;
		*) suffix="${Digit}th" ;;
	esac
}

echo "1-2/2,3 4-5/14,15 16 12 7" | egrep -v "^#|^$"| while read min hour DoM Month DoW CMD; do 

	export crontime=$(printf "%s %s %s %s %s\n" "$min" "$hour" "$DoM" "$Month" "$DoW") 
	
	Pretty_Time

	echo ""
	echo "CronTime is ${crontime}" 
	echo "${prettytime}"
done
