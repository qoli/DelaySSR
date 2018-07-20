#! /usr/bin/env python
import sys
import base64
from json import dumps
from pprint import pprint
from urllib import urlencode
from urlparse import urlparse
from urlparse import parse_qs

def qs(query):
	return dict([(k,v[0]) for k,v in parse_qs(query).items()])

def decode_base64(data):
	"""Decode base64, padding being optional.

	:param data: Base64 data as an ASCII byte string
	:returns: The decoded byte string.

	"""
	missing_padding = len(data) % 4
	if missing_padding != 0:
		data += b'='* (4 - missing_padding)
	return base64.decodestring(data)

if len(sys.argv) < 2:
	print(sys.version)
	print("usage:")
	print("	"+sys.argv[0]+" all			all")
	print("	"+sys.argv[0]+" server name		one config")
	exit();

with open(sys.argv[1]) as f:
	lines = f.readlines()

for thisLine in lines:
	conf = thisLine.strip().split("/")
	base = conf[0].split(":")
	query = qs(urlparse(conf[1]).query)

	if "protoparam" not in query:
		query['protoparam'] = ""
		pass
	if "obfsparam" not in query:
		query['obfsparam'] = ""
		pass

	json={
		"protocol_param": decode_base64(query['protoparam']),
		"method": base[3],
		"protocol" : base[2],
		"server" : base[0],
		"password" : decode_base64(base[5]),
		"local_address" : "127.0.0.1",
		"server_port" : 443,
		"timeout" : 60,
		"local_port" : 2014,
		"obfs_param": decode_base64(query['obfsparam']),
		"obfs" : base[4],
		}

	js = dumps(json, sort_keys=True, indent=4, separators=(',', ':'))
	if sys.argv[2] == "all":
		print(js)
	else:
		if sys.argv[2] == base[0]: print(js)
