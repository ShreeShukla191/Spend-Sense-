import urllib.request
import json
import re

data = json.dumps({
    "username": "testuserx2",
    "email": "test@test.com",
    "password": "123",
    "password_confirm": "123"
}).encode('utf-8')

req = urllib.request.Request("http://10.172.116.69:8000/auth/register/", data=data, headers={'Content-Type': 'application/json'}, method='POST')

try:
    with urllib.request.urlopen(req) as f:
        print("SUCCESS:", f.read().decode('utf-8'))
except urllib.error.HTTPError as e:
    body = e.read().decode('utf-8')
    title = re.search(r'<title>(.*?)</title>', body, re.IGNORECASE)
    print("HTTP ERROR:", e.code)
    if title:
        print("TITLE:", title.group(1))
    else:
        print("BODY:", body[:500])
except Exception as e:
    print("OTHER ERROR:", e)
