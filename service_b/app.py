"""Service B: Data processing service that fetches user data from Service A and analyzes it."""
# service_b/app.py
# Simple User Data Processing Service
import os
import requests
from flask import Flask, jsonify

app = Flask(__name__)

# Configuration
SERVICE_A_URL = os.getenv("SERVICE_A_URL", "http://service_a:5000")


def split_name(name):
    """Split name into parts"""
    parts = name.split()
    return {
        "first_name": parts[0] if parts else "",
        "middle_names": parts[1:-1] if len(parts) > 2 else [],
        "last_name": parts[-1] if len(parts) > 1 else "",
        "total_parts": len(parts),
    }


def analyze_email(email):
    """Basic email analysis"""
    username, domain = email.split("@")
    return {
        "username": username,
        "domain": domain,
        "is_corporate": not any(
            x in domain for x in ["gmail", "yahoo", "hotmail", "outlook"]
        ),
    }


@app.route("/")
def home():
    """Simple home page with UI"""
    return """
    <html>
    <head>
        <title>Data Processing Service</title>
        <style>
            body { font-family: Arial, sans-serif; max-width: 800px; margin: 0 auto; padding: 20px; }
            .form-section { padding: 20px; border: 1px solid #ccc; border-radius: 5px; margin-bottom: 20px; }
            .form-group { margin-bottom: 15px; }
            label { display: block; margin-bottom: 5px; }
            input { width: 100%; padding: 8px; margin-bottom: 10px; }
            button {
                background-color: #4CAF50;
                color: white;
                padding: 10px 15px;
                border: none;
                border-radius: 4px;
                cursor: pointer;
            }
            button:hover { background-color: #45a049; }
            #result { margin-top: 20px; padding: 10px; border: 1px solid #ddd; border-radius: 4px; }
            .name-part { color: #2196F3; }
            .email-part { color: #4CAF50; }
        </style>
    </head>
    <body>
        <h1>Data Processing Service</h1>
        <div class="form-section">
            <h2>Process User Data</h2>
            <form id="processForm">
                <div class="form-group">
                    <label for="userId">User ID:</label>
                    <input type="text" id="userId" name="userId" required>
                </div>
                <button type="submit">Process User Data</button>
            </form>
            <div id="result"></div>
        </div>

        <script>
            document.getElementById('processForm').addEventListener('submit', async (e) => {
                e.preventDefault();
                const userId = document.getElementById('userId').value;

                try {
                    const response = await fetch(`/process/user/${userId}`, {
                        method: 'POST'
                    });
                    const data = await response.json();

                    if (data.error) {
                        document.getElementById('result').innerHTML =
                            `<pre class="error">Error: ${data.error}</pre>`;
                        return;
                    }

                    let resultHtml = '<div class="analysis-result">';

                    // Basic Info
                    resultHtml += '<h3>Basic Information</h3>';
                    resultHtml += `<p><strong>User ID:</strong> ${data.user_id}</p>`;
                    resultHtml += `<p><strong>Full Name:</strong> ${data.name}</p>`;
                    resultHtml += `<p><strong>Email:</strong> ${data.email}</p>`;

                    // Name Analysis
                    resultHtml += '<h3>Name Analysis</h3>';
                    resultHtml += `
                        <p><strong>First Name:</strong>
                            <span class="name-part">${data.name_analysis.first_name}</span>
                        </p>
                    `;
                    if (data.name_analysis.middle_names.length > 0) {
                        resultHtml += `
                            <p><strong>Middle Names:</strong>
                                <span class="name-part">${data.name_analysis.middle_names.join(' ')}</span>
                            </p>
                        `;
                    }
                    resultHtml += `
                        <p><strong>Last Name:</strong>
                            <span class="name-part">${data.name_analysis.last_name}</span>
                        </p>
                    `;
                    resultHtml += `<p><strong>Total Name Parts:</strong> ${data.name_analysis.total_parts}</p>`;

                    // Email Analysis
                    resultHtml += '<h3>Email Analysis</h3>';
                    resultHtml += `
                        <p><strong>Username:</strong>
                            <span class="email-part">${data.email_analysis.username}</span>
                        </p>
                    `;
                    resultHtml += `
                        <p><strong>Domain:</strong>
                            <span class="email-part">${data.email_analysis.domain}</span>
                        </p>
                    `;
                    resultHtml += `
                        <p><strong>Corporate Email:</strong>
                            ${data.email_analysis.is_corporate ? 'Yes' : 'No'}
                        </p>
                    `;

                    resultHtml += '</div>';
                    document.getElementById('result').innerHTML = resultHtml;
                } catch (error) {
                    document.getElementById('result').innerHTML =
                        `<pre class="error">Error: ${error.message}</pre>`;
                }
            });
        </script>
    </body>
    </html>
    """


@app.route("/process/user/<user_id>", methods=["POST"])
def process_user_data(user_id):
    """Process data for a specific user"""
    try:
        # Fetch user data from Service A (add timeout to avoid hangs)
        response = requests.get(f"{SERVICE_A_URL}/users/{user_id}", timeout=5)

        if response.status_code == 404:
            return jsonify({"error": "User not found"}), 404

        user_data = response.json()

        # Process the data
        name_analysis = split_name(user_data["name"])
        email_analysis = analyze_email(user_data["email"])

        # Prepare final response
        processed_data = {
            "user_id": user_data["id"],
            "name": user_data["name"],
            "email": user_data["email"],
            "email_domain": email_analysis["domain"],
            "name_analysis": name_analysis,
            "email_analysis": email_analysis,
        }

        return jsonify(processed_data), 200

    except requests.RequestException as e:
        return jsonify({"error": f"Service A connection error: {str(e)}"}), 503
    except (KeyError, ValueError) as e:
        return jsonify({"error": f"Invalid user data from Service A: {str(e)}"}), 502


if __name__ == "__main__":
    app.run(host="0.0.0.0", port=5001, debug=True)
