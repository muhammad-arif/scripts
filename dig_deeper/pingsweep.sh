#!/bin/bash
#simple ping and Name sweep

## Help Dialog
#########################################################
howd () {
cat <<"EOF"                                                                                                   
                                                                                                                  
█████╗█████╗█████╗█████╗█████╗█████╗█████╗█████╗█████╗█████╗█████╗█████╗█████╗█████╗█████╗█████╗
╚════╝╚════╝╚════╝╚════╝╚════╝╚════╝╚════╝╚════╝╚════╝╚════╝╚════╝╚════╝╚════╝╚════╝╚════╝╚════╝
██╗        ██████╗ ██╗ ██████╗     ██████╗ ███████╗███████╗██████╗ ███████╗██████╗            ██╗
██║        ██╔══██╗██║██╔════╝     ██╔══██╗██╔════╝██╔════╝██╔══██╗██╔════╝██╔══██╗           ██║
██║        ██║  ██║██║██║  ███╗    ██║  ██║█████╗  █████╗  ██████╔╝█████╗  ██████╔╝           ██║
██║        ██║  ██║██║██║   ██║    ██║  ██║██╔══╝  ██╔══╝  ██╔═══╝ ██╔══╝  ██╔══██╗           ██║
██║        ██████╔╝██║╚██████╔╝    ██████╔╝███████╗███████╗██║     ███████╗██║  ██║           ██║
╚═╝        ╚═════╝ ╚═╝ ╚═════╝     ╚═════╝ ╚══════╝╚══════╝╚═╝     ╚══════╝╚═╝  ╚═╝           ╚═╝
█████╗█████╗█████╗█████╗█████╗█████╗█████╗█████╗█████╗█████╗█████╗█████╗█████╗█████╗█████╗█████╗
╚════╝╚════╝╚════╝╚════╝╚════╝╚════╝╚════╝╚════╝╚════╝╚════╝╚════╝╚════╝╚════╝╚════╝╚════╝╚════╝

EOF
}
help () {
cat <<"EOF"

This script can be use for basic reconaissance. This script works as a pingsweeper along with nameresolver(digdeeper). 

    - Takes minimum two argument and maximum three argument
    - Fist two argument is IP range. E.g. 192.168.0.1 192.168.0.5. Here 192.168.0.1-5 IP's will be pinged and resolved.
    - Third argument is nameserver and an optional argument. If you want to use a specific nameserver then use `@nameserver` as a third argument.

For example: 

1. Sweeping 192.168.0.1-192.168.0.5 with default Name Server
./pingsweep.sh 192.168.0.1 192.168.0.5

2. Sweeping 192.168.0.1-192.168.0.5 with user specific Name Server
./pingsweep.sh 192.168.0.1 192.168.0.5 8.8.8.8

EOF
}
howd
## Validatiing Arguments
#########################################################

## First Argument into variable ip1
if [ "$1" != "" ]; then ip1=$1
else	help && exit 1
fi

## Second Argument into variable ip2
if [ "$2" != "" ]; then ip2=$2
else	help && exit 1
fi

## Third Argument into variable pns
if [ "$3" != "" ]; then 
	pns=$3
	pns1=@$pns
fi


## Checking If Dig is available 
#########################################################
dig +short +nocmd +noall
digstat=$(echo $?)
if [[ $digstat -eq 0 ]]; then printf "Yeyy! Will do dig sweep too.\n"
else printf "Damn it! Can't do dig sweep"
fi

## Necessery functions
#########################################################

## Function for sanity check
function die() { printf '\n\033[0;31m%s \033[0m\n\n' "$1" ; exit 1; }


## Function for scanning IP's with default Name server 
function scanningwithDefNS()
{

	local ip=$1
	printf "\n\n\n----------------------------------------------------------------------------\n"
	printf "IP: $ip"
	printf "\n--------------------------------------------------------\n"
	ping -c1 -W1 $ip 2>&1 > /dev/null
	local stat=$(echo $?)
	if [[ $stat -ne 1 ]]; then
		echo "Host Up"
		ping -c 1 -W 1 $ip | sed -n 2p | sed -r 's/^.*ttl=([[:digit:]]{1,3})[[:space:]]time=([[:digit:]]{1,5}(\.[[:digit:]]{1,6})?[[:space:]]ms)$/TTL: \1\nRTT: \2/'
		ns=$(dig -x $ip  +short)
		if [ "$ns" != "" ]; then
			printf "\nName Server: $ns\n"
			echo "---------------------------------------------"
			printf "\nA Records:\n"
			echo "---------------------------------------------"
			dig +noall +answer $ns A +short
			
			local AAAA=$(dig +noall +answer $ns AAAA +short)
			if [ "$AAAA" != "" ]; then
				printf "\nAAAA Records:\n"
				echo '---------------------------------------------'
				echo $AAAA | sed -r 's/[[:space:]]/\n/g'
			fi
			
			local NSSERVER=$(dig +noall +answer $ns NS +short)
			if [ "$NSSERVER" != "" ]; then
				printf '\nName Servers:\n'
				echo '---------------------------------------------'
				echo $NSSERVER | sed -r 's/[[:space:]]/\n/g'
			fi
			
			local MX=$(dig +noall +answer $ns MX +short)
			if [ "$MX" != "" ]; then
				printf "\nMX Records:\n"
				echo '---------------------------------------------'
				echo $MX | sed -r 's/\.[[:space:]]/\n/g'
			fi
			
			local SOA=$(dig +noall +answer $ns SOA +short)
			if [ "$SOA" != "" ]; then
				printf "\nSOA Records:\n"
				echo '---------------------------------------------'
				echo $SOA 
			fi
			
			
			echo "----------------------------------------------------------------------------"

		else printf "No Name found"
		fi

	else echo "Host Down"
	fi
}


## Function for scanning IP's with Specified Name server 
function scanningwithSpecNS()
{

	local ip=$1
	printf "\n\n\n----------------------------------------------------------------------------\n"
	printf "IP: $ip"
	printf "\n--------------------------------------------------------\n"
	ping -c1 -W1 $ip 2>&1 > /dev/null
	local stat=$(echo $?)
	if [[ $stat -ne 1 ]]; then
		echo "Host Up"
		ping -c 1 -W 1 $ip | sed -n 2p | sed -r 's/^.*ttl=([[:digit:]]{1,3})[[:space:]]time=([[:digit:]]{1,5}(\.[[:digit:]]{1,6})?[[:space:]]ms)$/TTL: \1\nRTT: \2/'
		ns=$(dig -x $ip  +short $pns1)
		if [ "$ns" != "" ]; then
			printf "\nName Server: $ns\n"
			echo "---------------------------------------------"
			printf "\nA Records:\n"
			echo "---------------------------------------------"
			dig +noall +answer $ns A +short $pns1
						
			local AAAA=$(dig +noall +answer $ns AAAA +short $pns1)
			if [ "$AAAA" != "" ]; then
				printf "\nAAAA Records:\n"
				echo '---------------------------------------------'
				echo $AAAA | sed -r 's/[[:space:]]/\n/g'
			fi
			
			local NSSERVER=$(dig +noall +answer $ns NS +short $pns1)
			if [ "$NSSERVER" != "" ]; then
				printf '\nName Servers:\n'
				echo '---------------------------------------------'
				echo $NSSERVER | sed -r 's/[[:space:]]/\n/g'
				
			fi
			
			local MX=$(dig +noall +answer $ns MX +short $pns1)			
			if [ "$MX" != "" ]; then
				printf "\nMX Records:\n"
				echo '---------------------------------------------'
				echo $MX | sed -r 's/[[:space:]]/\n/g'
				
			fi
			
			local SOA=$(dig +noall +answer $ns SOA +short $pns1)	
			if [ "$SOA" != "" ]; then
				printf "\nSOA Records:\n"
				echo "---------------------------------------------"
				echo $SOA
			fi
			
			
			echo "----------------------------------------------------------------------------"

		else printf "No Name found"
		fi

	else echo "Host Down"
	fi
}



## Function for Scanning IP only
function scanningonlyIP()
{

	local ip=$1
	printf "\n\n\n--------------------------------------------------------\n"
	printf "IP: $ip"
	printf "\n--------------------------------------------------------\n"
	ping -c1 -W1 $ip 2>&1 > /dev/null
	local stat=$(echo $?)
	if [[ $stat -ne 1 ]]; then
		echo "Host Up"
		ping -c 1 -W 1 $ip | sed -n 2p | sed -r 's/^.*ttl=([[:digit:]]{1,3})[[:space:]]time=([[:digit:]]{1,5}\.[[:digit:]]{1,6}[[:space:]]ms)$/TTL: \1\nRTT: \2/'
		echo "--------------------------------------------------------"
	else echo "Host Down"
	fi
}



## Function for IP Validation
function valid_ip()
{
    local  ip=$1
    local  stat=1

    if [[ $ip =~ ^[0-9]{1,3}\.[0-9]{1,3}\.[0-9]{1,3}\.[0-9]{1,3}$ ]]; then
        OIFS=$IFS
        IFS='.'
        ip=($ip)
        IFS=$OIFS
        [[ ${ip[0]} -le 255 && ${ip[1]} -le 255 \
            && ${ip[2]} -le 255 && ${ip[3]} -le 255 ]]
        stat=$?
    fi
    return $stat
}

## IP Format Validation
#########################################################

## Validating First IP
if valid_ip $ip1 || die "|| STEP 2 || - Wrong ip. Correct IP format \"xxx.xxx.xxx.xxx\" where X represent number and in one octate highest value is 255"; then echo "Correct IP1."
fi

## Validating 2nd IP
if valid_ip $ip2 || die "|| STEP 3 || - Wrong ip. Correct IP format \"xxx.xxx.xxx.xxx\" where X represent number and in one octate highest value is 255"; then echo "Correct IP2"
fi

## Validating Nameserver 
if [ "$pns" != "" ]; then
	if valid_ip $pns || die "|| STEP 4 || - Wrong ip. Correct IP format \"xxx.xxx.xxx.xxx\" where X represent number and in one octate highest value is 255"; then echo "Correct NS1."
	fi
fi


## IP Fragmantation and sweeper start here
#########################################################

if [[ $ip1 =~ ^[0-9]{1,3}\.[0-9]{1,3}\.[0-9]{1,3}\.[0-9]{1,3}$ && $ip2 =~ ^[0-9]{1,3}\.[0-9]{1,3}\.[0-9]{1,3}\.[0-9]{1,3}$ ]]; then
        OIFS=$IFS
        IFS='.'
        ip1=($ip1)
        ip2=($ip2)
        IFS=$OIFS

        IP1_oct1=${ip1[0]}
        IP1_oct2=${ip1[1]}
        IP1_oct3=${ip1[2]}
        IP1_oct4=${ip1[3]}
        IP2_oct1=${ip2[0]}
        IP2_oct2=${ip2[1]}
        IP2_oct3=${ip2[2]}
        IP2_oct4=${ip2[3]}

	while [ $IP1_oct1 -le $IP2_oct1 ]; do

		
		while [ $IP1_oct2 -le $IP2_oct2 ]; do

			
			while [ $IP1_oct3 -le $IP2_oct3 ]; do
				


				while [ $IP1_oct4 -le $IP2_oct4 ]; do

					IP=$IP1_oct1\.$IP1_oct2\.$IP1_oct3\.$IP1_oct4
					
					if [[ $digstat -eq 0 ]]; then
						if [ "$pns1" != "" ]; then
							scanningwithSpecNS $IP
						else scanningwithDefNS $IP
						fi
					else scanningonlyIP $IP
					fi

					IP1_oct4=$(($IP1_oct4+1))
				done
				
				IP1_oct3=$(($IP1_oct3+1))
			done

			IP1_oct2=$(($IP1_oct2+1))
		done

		IP1_oct1=$(($IP1_oct1+1))
	done
fi




<< --MULTILINE-COMMENT--

--MULTILINE-COMMENT--