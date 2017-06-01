#!/bin/bash

# usage ./chaincode_update.sh 
# with no parameters the script will update the network with the chaincode specified in chaincode.cfg
# pass the parameter 'cli' to enter the cli docker container directly (for instance to issue invoke / query commands 

source ./chaincode.cfg

if [[ -z "$CHAINCODE_PATH" ]]; then 
	echo "no chaincode path specified in chaincode.cfg"
	exit 3
fi

# get container id of a running container
# -q (quiet mode, only output id)
# -f (filter)
ID=$(docker ps -qf "name=cli")

# if the container was not running, find the id from the stopped containers
# -a (all containers, including stopped)
if [[ -z "$ID" ]]; then
	ID=$(docker ps -aqf "name=cli")
	# restart the container for 60 seconds
	docker restart -t 60 $ID
fi

if [[ "$1" -eq "cli" ]]; then 
	# enter a bash shell for the container
	docker exec -it $ID bash
	exit 0
fi

# copy the given $CHAINCODE_PATH from the local GOPATH to the container's GOPATH
# NOTE: /opt/gopath is the $GOPATH for the container that was set in the docker-compose-e2e-template.yaml file
docker cp $GOPATH/src/$CHAINCODE_PATH $ID:/opt/gopath/src


CC_VERSION_MAJOR=1
CC_VERSION_MINOR=0
rc=0
while [[ $rc -eq 0 ]] 
	do
	CC_VERSION=$CC_VERSION_MAJOR.$CC_VERSION_MINOR
	echo "attempting installation of $CHAINCODE_PATH as version v$CC_VERSION"
	# install the updated chaincode
	docker exec -it $ID peer chaincode install -n mycc -v $CC_VERSION -p $CHAINCODE_PATH &>log.txt || true
	
	# check if the version was previously installed
	VERSION_EXISTS=$(cat log.txt | grep 'Error endorsing' | grep 'exists' | wc -l)
	
	if [[ $VERSION_EXISTS -ne 0 ]]; then 
		echo "VERSION EXISTS"
		CC_VERSION_MINOR=$[CC_VERSION_MINOR+1]
		echo "incrementing version to v"$CC_VERSION_MAJOR.$CC_VERSION_MINOR
	else 
		rc=$(cat log.txt | grep 'Installed remotely' | grep 'status:200' | wc -l)
		if [[ $rc -ne 0 ]]; then 
			# run peer update chaincode command
			docker exec -it $ID peer chaincode upgrade -C chaindev -v $CC_VERSION -p $CHAINCODE_PATH -n mycc -o orderer.example.com:7050 -c '{"Args":["init"]}' &>log.txt
			echo "Installed as version " $CC_VERSION
		else 
			cat log.txt
			break
		fi
	fi
	
done

# run the validation script
# from the docker-compose-e2e-template.yaml file --- command: /bin/bash -c './scripts/fileshare_script.sh ${CHANNEL_NAME}; sleep $TIMEOUT'

