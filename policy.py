import json
import requests
import sys
from requests.auth import HTTPBasicAuth


def load_policies():
    filename = "rules.json"
    with open(filename) as f:
        data = f.read()
        data = json.loads(data)
    return data


def onos_get(url, headers):
    user = HTTPBasicAuth('onos', 'rocks')
    r = requests.get(url, headers=headers, auth=user)
    print("HTTP status code: " + str(r.status_code))
    return r.text


def onos_post(url, headers, data):
    user = HTTPBasicAuth('onos', 'rocks')
    r = requests.post(url, headers=headers, auth=user, data=data)
    print("HTTP status code: " + str(r.status_code))
    print(r.text)


def get_devices():
    headers = {"Accept": "application/json"}
    url = "http://localhost:8181/onos/v1/devices"
    devices = onos_get(url, headers)
    devices = json.loads(devices)
    li = devices["devices"]
    ids = []
    for di in li:
        ids.append(di["id"])
    return ids


def post_rules(device):
    headers = {"Accept": "application/json", "Content-Type": "application/json"}
    url = "http://localhost:8181/onos/v1/flows?appId=policy"
    data = load_policies()
    for i in range(len(data["flows"])):
        data["flows"][i]["deviceId"] = device
    data = json.dumps(data)
    onos_post(url, headers, data)


def main():
    devices = get_devices()
    print(devices)
    for device in devices:
        post_rules(device)


if __name__ == "__main__":
    # execute only if run as a script
    main()

