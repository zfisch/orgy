#!/usr/bin/python

# Parses a token for follow peeps from a newly created, single authentication.

import json
import unicodedata

json_data=open("cred.txt").read()
data = json.loads(json_data)

def findToken():
	if data['errors']:
		print 'Errors found: ',data['message'],
		print data['errors'][0]['resource']
		print data['errors'][0]['code']
		print data['documentation_url']
		print 'There is an error in retrieving your token!'
		return ""

	elif data['note']:
		if data['note'] == "follow peeps":
			token = data['token']
			return token

findToken()