from flask import Flask, request, jsonify
import requests
import os
import logging

# Initialize Flask app
application = Flask(__name__)

# Configure logging
logging.basicConfig(level=logging.INFO)

# Environment variable for the authentication service URL
AUTH_SERVICE_URL = os.getenv('AUTH_SERVICE_URL', 'http://0.0.0.0:5001/auth')

# Configure request session with retry logic
session = requests.Session()
from requests.adapters import HTTPAdapter
from requests.packages.urllib3.util.retry import Retry

retry = Retry(connect=3, backoff_factor=0.5)
adapter = HTTPAdapter(max_retries=retry)
session.mount('http://', adapter)


@application.route('/hello', methods=['GET'])
def hello():
    logging.info("Received request on /hello endpoint")
    return 'Hello there'


@application.route('/jobs', methods=['POST'])
def jobs():
    token = request.headers.get('Authorization')
    if not token:
        return jsonify({"error": "Authorization token missing"}), 401

    data = {"token": token}
    try:
        result = session.post(AUTH_SERVICE_URL, data=data, timeout=5).text
        if result == "density":
            return jsonify({"job": {"title": "DevOps", "description": "Awesome"}})
        else:
            return jsonify({"error": "fail"}), 403
    except requests.exceptions.RequestException as e:
        logging.error("Error contacting auth service: %s", e)
        return jsonify({"error": "Auth service unavailable"}), 503


@application.route('/healthz', methods=['GET'])
def health_check():
    return 'Healthy', 200


@application.route('/readyz', methods=['GET'])
def readiness_check():
    return 'Ready', 200


@application.after_request
def add_security_headers(response):
    response.headers['X-Content-Type-Options'] = 'nosniff'
    response.headers['X-Frame-Options'] = 'DENY'
    return response


if __name__ == "__main__":
    application.run(host='0.0.0.0', port=5000)

