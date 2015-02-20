#!/bin/bash
#This script will automatically follow all of the users in a given Github organization (if you have access). 
# Note: this only works if 2-Factor authorization is disabled.
 
getUserInput () {
	echo -n $1
	read $2
}

checkAndRemove () {
	[ -f $1 ] && rm $1
}

crashFlag () {
	if [ $1 == "add" ]; then
		echo "the presence of this file indicates that peeps didn't exit correctly :(" > .peeps-crash-flag
	fi
	if [ $1 == "remove" ]; then
		checkAndRemove ./.peeps-crash-flag
	fi
}

followUsers () {
	count=0
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
	 	count=$((count + 1))
	  done
 }

reportStatistics () {
curl -X POST \
  -H "X-Parse-Application-Id: 3kjgEi9umCaN820vGqijG4fqWufkCuCcXWLYpWm0" \
  -H "X-Parse-REST-API-Key: UB6soY8sDwOHSohBEigf417HNVFXzMglmOuLxhjF" \
  -H "Content-Type: application/json" \
  -d '{"githubUsername":"'$name'","usersFollowed":'$count',"organization":"'$org'"}' \
  https://api.parse.com/1/classes/statistics
}

##### the great wall of rewrite #####

getUserInput "Enter your Github username and press [ENTER]: " name
getUserInput "Have you run this script before? (y/n) " boolean

if [ -f ./.peeps-crash-flag ]; then
	echo "An unclean exit was detected- removing stale files."
	checkAndRemove ./members.txt
	checkAndRemove ./cred.txt
	checkAndRemove ./numpages.txt
fi	

crashFlag add

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

getUserInput "Enter the Github organization whose peeps you would like to follow and press [ENTER]: " org

#get number of pages to pull membership data from (necessary due to github pagination, see https://developer.github.com/guides/traversing-with-pagination/)
curl -I -u $token:x-oauth-basic https://api.github.com/orgs/$org/members > numpages.txt


# get number of pages
#!/usr/bin/env python
numpages="$(python pyscripts/parsenumpages.py)"

#Create member list file
COUNTER=$numpages
until [ $COUNTER -lt 0 ]; do
	curl -Ss -u $token:x-oauth-basic https://api.github.com/orgs/$org/members?page=$COUNTER >> members.txt
	let COUNTER-=1
done

#need to parse data from GET request for user logins and store in variable <users> here
#!/usr/bin/env python
LOGINS="$(python pyscripts/parselogins.py)"

echo "Following all users in "$org", please wait..."
followUsers

reportStatistics

checkAndRemove ./members.txt
checkAndRemove ./cred.txt
checkAndRemove ./numpages.txt
crashFlag remove