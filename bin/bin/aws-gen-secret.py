#!/usr/bin/env python

import base64
import hashlib
import hmac
import sys


clientId = sys.argv[1].encode()
secretKey = sys.argv[2].encode()
username = sys.argv[3].encode()

digest = hmac.new(
    secretKey, msg=username + clientId, digestmod=hashlib.sha256
).digest()

print(base64.b64encode(digest).decode())
