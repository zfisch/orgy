#!/usr/bin/python

import re

data=open("members.txt").read()
data_already=open("already.txt").read()
def findLogins(data):
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
	# bashArray = ' '.join(logins)
	#print bashArray,"count",count
	return logins

def findNotYet(new,present):
	toBeAdded=[]
	for i in new:
		if not(i in present):
			toBeAdded.append(i)
	toBeAddedString=' '.join(toBeAdded)
	print toBeAddedString

already=findLogins(data_already)
logins=findLogins(data)
notYet=findNotYet(logins,already)
