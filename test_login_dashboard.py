import urllib.request
import json

data = json.dumps({
    "username": "testuserx2",
    "password": "123"
}).encode('utf-8')

req = urllib.request.Request("http://10.172.116.69:8000/auth/login/", data=data, headers={'Content-Type': 'application/json'}, method='POST')

try:
    with urllib.request.urlopen(req) as f:
        resp = f.read().decode('utf-8')
        print("SUCCESS LOGIN:", resp[:50], "...")
        token = json.loads(resp).get('access')
        
        # Test dashboard
        req2 = urllib.request.Request("http://10.172.116.69:8000/", headers={'Authorization': 'Bearer ' + token})
        with urllib.request.urlopen(req2) as f2:
            print("SUCCESS DASH:", f2.read().decode('utf-8')[:100], "...")
            
        # Test goals
        req3 = urllib.request.Request("http://10.172.116.69:8000/goals/", headers={'Authorization': 'Bearer ' + token})
        with urllib.request.urlopen(req3) as f3:
            print("SUCCESS GOALS:", f3.read().decode('utf-8')[:100], "...")
            
except urllib.error.HTTPError as e:
    print("HTTP ERROR:", e.code, e.read().decode('utf-8')[:200])
except Exception as e:
    print("OTHER ERROR:", e)
