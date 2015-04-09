#!/usr/bin/python

import re

data=open("already.txt").read()

def findLogins():
	users = data.split('login')
	# print "fsdfs",len(users)
	count=0
	logins = []
	for user in users:
		str(user)
		loginLine = user.splitlines()[0]
		login = re.sub(r'[^a-zA-Z0-9\-]', '', loginLine)
		logins.append(login)
		if len(login)>0:
			count+=1
	logins.pop(0)
	bashArray = ' '.join(logins)
	return bashArray

findLogins()