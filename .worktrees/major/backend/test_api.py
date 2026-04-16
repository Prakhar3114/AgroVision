import requests

url = "http://192.168.0.102:5000/predict"

files = {"file": open("test_image.jpg", "rb")}

response = requests.post(url, files=files)

print(response.json())