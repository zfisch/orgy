#! /bin/bash
#This script will automatically follow all of the users in a given Github organization (if you have access). 
# Note: this only works if 2-Factor authorization is disabled.
 
#1
# get username for authentication
echo -n "Enter your Github username and press [ENTER]: "
read name

 
#2
#grab existing token or authenticate user with necesarry permissions
echo -n "Have you run this script before? (y/n) "
read boolean

if [ $boolean = "y" ];
then
	curl -Ss -u $name https://api.github.com/authorizations > cred.txt
	#!/usr/bin/env python
	token="$(python pyscripts/parsetoken.py)"
	echo $token
else
	curl -Ss -u $name -d '{"scopes": ["user", "read:org","user:follow"], "note": "follow peeps"}' https://api.github.com/authorizations > cred.txt
	#!/usr/bin/env python
	token="$(python pyscripts/parsetoken2.py)"
	echo $token
fi

# looks to see if we receive a token. 
	# if we do, we run through the script, and clear the files.
	# if not, we report exiting program through validation error
if [ "$token" != "" ];
then
	
	#4 
	#find members of given github organization
	echo -n "Enter the Github organization whose peeps you would like to follow and press [ENTER]: "
	read org

	# find number of pages for followers
	curl -I -u $token:x-oauth-basic https://api.github.com/user/following > numpagesFollowers.txt	

	# get number of pages
	#!/usr/bin/env python
	numpagesFollowers="$(python pyscripts/parsenumpages.py)"
	# List of people user is following:
	COUNTER2=$numpagesFollowers
	echo "following pages "$COUNTER2
	# quoting in comparisons to avoid unary operator error
	until [ "$COUNTER2" -le 0 ]; do
		curl -Ss -u  $token:x-oauth-basic https://api.github.com/user/following?page=$COUNTER2 >> already.txt
		# for any POSIX compatible shell, use this notation rather than let:
		COUNTER2=$(($COUNTER2-1))
	done

	#3
	#get number of pages to pull membership data from (necessary due to github pagination, see https://developer.github.com/guides/traversing-with-pagination/)
	curl -I -u $token:x-oauth-basic https://api.github.com/orgs/$org/members > numpages.txt	

	# get number of pages
	#!/usr/bin/env python
	numpages="$(python pyscripts/parsenumpages.py)"
	# echo $numpages

	#4
	#Create organization member list file
	COUNTER=$numpages
	# quoting in comparisons to avoid unary operator error
	until [ "$COUNTER" -le 0 ]; do
		curl -Ss -u $token:x-oauth-basic https://api.github.com/orgs/$org/members?page=$COUNTER >> members.txt
		# for any POSIX compatible shell, use this notation rather than let:
		COUNTER=$(($COUNTER-1))
	done

	# 5
	# need to parse data from GET request for user logins and store in variable <users> here
	# !/usr/bin/env python
	LOGINS="$(python pyscripts/parselogins.py)"
	echo "New peeps to be followed: "$LOGINS
	#6
	#follow all users
	echo "Following remaining users in "$org", please wait..."
	x=0
	for i in ${LOGINS[@]};
	  do 
		# echo $i
		if [[ "$i" != "$name" ]]
			then
	    	response=$(curl --silent --write-out %{http_code} --output /dev/null -u $token:x-oauth-basic -X PUT https://api.github.com/user/following/$i)
		 	if [ $response == "204" ]
		 		then
		 		echo "You are now following: "$i
		 		x=$(($x+1))
		 	else
		 		echo $response
		 		echo "There was a problem following: "$i
		 	fi
		fi
	 	sleep .01
	  done
	echo "You just followed an additional "$x" people!"

	#7
	#clean up
	rm ./members.txt
	rm ./already.txt
	rm ./cred.txt
	rm ./numpages.txt
	rm ./numpagesFollowers.txt

else
	echo "Exiting program with token validation error"

fi
