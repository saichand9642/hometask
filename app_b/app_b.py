from flask import Flask, request, jsonify
import sqlite3 as sql
import os
import logging

# Initialize Flask app
application = Flask(__name__)

# Configure logging
logging.basicConfig(level=logging.INFO)

# Environment variable for database path
DATABASE_PATH = os.getenv('DATABASE_PATH', 'database.db')


@application.route('/auth', methods=['POST'])
def auth():
    try:
        token = request.form['token']
        con = sql.connect(DATABASE_PATH)
        cur = con.cursor()
        cur.execute(
            "SELECT username FROM users WHERE token = (?) LIMIT 1",
            (token,))
        result = cur.fetchone()
        con.close()
        if result:
            username = result[0]
            return username
        else:
            return jsonify({"error": "Invalid token"}), 403
    except Exception as e:
        logging.error("Error during authentication: %s", e)
        return jsonify({"error": "Database error"}), 500


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
    application.run(host='0.0.0.0', port=5001)

