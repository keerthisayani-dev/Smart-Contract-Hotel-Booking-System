import requests

# Correct Flask endpoint
url = "http://127.0.0.1:5050/book"

# Booking payload with UNIX timestamps
payload = {
    "checkIn": 1698796800,     # Example: Nov 1, 2023
    "checkOut": 1699142400     # Example: Nov 5, 2023
}

# Headers to specify JSON content
headers = {
    "Content-Type": "application/json"
}

# Send POST request to Flask backend
try:
    response = requests.post(url, json=payload, headers=headers)
    print("Status Code:", response.status_code)

    # Try to parse JSON response
    try:
        print("Response:", response.json())
    except ValueError:
        print("Raw Response:", response.text)

except requests.exceptions.ConnectionError as conn_err:
    print("Connection Error: Could not reach the server at", url)
    print("Details:", conn_err)

except requests.exceptions.RequestException as req_err:
    print("Request failed:", req_err)
