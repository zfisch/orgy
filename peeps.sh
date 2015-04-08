#!/bin/bash
#This script will automatically follow all of the users in a given Github organization (if you have access). 
# Note: this only works if 2-Factor authorization is disabled.
 
#1
#get username for authentication
echo "Enter your Github username and press [ENTER]: "
read name
 
#2
#grab existing token or authenticate user with necesarry permissions
echo "Have you run this script before? (y/n) "
read boolean

if [ $boolean == "y" ]
then
	curl -Ss -u $name https://api.github.com/authorizations > cred.txt
	#!/usr/bin/env python
	token="$(python pyscripts/parsetoken.py)"
else
	curl -Ss -u $name -d '{"scopes": ["user", "read:org"], "note": "follow peeps"}' https://api.github.com/authorizations > cred.txt
	#!/usr/bin/env python
	token="$(python pyscripts/parsetoken2.py)"
fi

echo "Would you like to follow an organization or a team? Enter y to follow an organization. Any other value will follow a team."
read followOrg

if [ $followOrg == "y" ]
then
	#4 
	#find members of given github organization
	echo "Enter the Github organization whose peeps you would like to follow and press [ENTER]: "
	read org

	#3
	#get number of pages to pull membership data from (necessary due to github pagination, see https://developer.github.com/guides/traversing-with-pagination/)
	curl -I -u $token:x-oauth-basic https://api.github.com/orgs/$org/members > numpages.txt

	#4
	#Create member list file
	COUNTER=$numpages
	until [ $COUNTER -lt 0 ]; do
		curl -Ss -u $token:x-oauth-basic https://api.github.com/orgs/$org/members?page=$COUNTER >> members.txt
		let COUNTER-=1
	done
else
	#find members of given github team
	echo "Enter the GitHub team ID whose peeps you would like to follow and press [ENTER]: "
	read team

	#get number of pages to pull membership data from
	curl -I -u $token:x-oauth-basic https://api.github.com/teams/$team/members > numpages.txt
fi

#get number of pages
#!/usr/bin/env python
numpages="$(python pyscripts/parsenumpages.py)"

#Create member list file
COUNTER=$numpages
until [ $COUNTER -lt 0 ]; do
	if [ $followOrg == "y" ]
	then
		curl -Ss -u $token:x-oauth-basic https://api.github.com/orgs/$org/members?page=$COUNTER >> members.txt
	else
		curl -Ss -u $token:x-oauth-basic https://api.github.com/teams/$team/members?page=$COUNTER >> members.txt
	fi
	let COUNTER-=1
done
 
#5
#need to parse data from GET request for user logins and store in variable <users> here
#!/usr/bin/env python
LOGINS="$(python pyscripts/parselogins.py)"
 
#6
#follow all users
echo "Following all users in "$org", please wait..."
for i in ${LOGINS[@]};
  do 
    response=$(curl --silent --write-out %{http_code} --output /dev/null -u $token:x-oauth-basic -X PUT https://api.github.com/user/following/$i)
 	if [ $response == "204" ]
 		then
 		echo "You are now following: "$i
 	else
 		echo "There was a problem following: "$i
 	fi
 	sleep .01
  done

#7
#clean up
rm ./members.txt
rm ./cred.txt
rm ./numpages.txt