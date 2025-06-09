from flask import Flask, request, jsonify
from typing import Dict

app = Flask(__name__)

# In-memory storage for users
users: Dict[str, dict] = {}

@app.route('/')
def home():
    """Simple home page with UI"""
    return '''
    <html>
    <head>
        <title>User Service</title>
        <style>
            body { font-family: Arial, sans-serif; max-width: 800px; margin: 0 auto; padding: 20px; }
            .container { display: flex; flex-direction: column; gap: 20px; }
            .form-section { padding: 20px; border: 1px solid #ccc; border-radius: 5px; }
            .form-group { margin-bottom: 15px; }
            label { display: block; margin-bottom: 5px; }
            input { width: 100%; padding: 8px; margin-bottom: 10px; }
            button { background-color: #4CAF50; color: white; padding: 10px 15px; border: none; border-radius: 4px; cursor: pointer; }
            button:hover { background-color: #45a049; }
            button.delete { background-color: #f44336; }
            button.delete:hover { background-color: #da190b; }
            button.update { background-color: #2196F3; }
            button.update:hover { background-color: #0b7dda; }
            #result { margin-top: 20px; padding: 10px; border: 1px solid #ddd; border-radius: 4px; }
            .success { color: #4CAF50; }
            .error { color: #f44336; }
            .user-list { margin-top: 20px; }
            .user-item { padding: 10px; border: 1px solid #ddd; margin-bottom: 10px; border-radius: 4px; }
        </style>
    </head>
    <body>
        <h1>User Service</h1>
        <div class="container">
            <div class="form-section">
                <h2>Create User</h2>
                <form id="createForm">
                    <div class="form-group">
                        <label for="name">Name:</label>
                        <input type="text" id="name" name="name" required>
                    </div>
                    <div class="form-group">
                        <label for="email">Email:</label>
                        <input type="email" id="email" name="email" required>
                    </div>
                    <button type="submit">Create User</button>
                </form>
                <div id="createResult"></div>
            </div>

            <div class="form-section">
                <h2>Update User</h2>
                <form id="updateForm">
                    <div class="form-group">
                        <label for="updateId">User ID:</label>
                        <input type="text" id="updateId" name="updateId" required>
                    </div>
                    <div class="form-group">
                        <label for="updateName">New Name:</label>
                        <input type="text" id="updateName" name="updateName">
                    </div>
                    <div class="form-group">
                        <label for="updateEmail">New Email:</label>
                        <input type="email" id="updateEmail" name="updateEmail">
                    </div>
                    <button type="submit" class="update">Update User</button>
                </form>
                <div id="updateResult"></div>
            </div>

            <div class="form-section">
                <h2>Delete User</h2>
                <form id="deleteForm">
                    <div class="form-group">
                        <label for="deleteId">User ID:</label>
                        <input type="text" id="deleteId" name="deleteId" required>
                    </div>
                    <button type="submit" class="delete">Delete User</button>
                </form>
                <div id="deleteResult"></div>
            </div>

            <div class="form-section">
                <h2>Current Users</h2>
                <div id="userList" class="user-list"></div>
            </div>
        </div>

        <script>
            // Function to refresh user list
            async function refreshUserList() {
                try {
                    const response = await fetch('/users');
                    const users = await response.json();
                    const userList = document.getElementById('userList');
                    userList.innerHTML = '';
                    
                    users.forEach(user => {
                        const userDiv = document.createElement('div');
                        userDiv.className = 'user-item';
                        userDiv.innerHTML = `
                            <strong>ID:</strong> ${user.id}<br>
                            <strong>Name:</strong> ${user.name}<br>
                            <strong>Email:</strong> ${user.email}
                        `;
                        userList.appendChild(userDiv);
                    });
                } catch (error) {
                    console.error('Error fetching users:', error);
                }
            }

            // Create user
            document.getElementById('createForm').addEventListener('submit', async (e) => {
                e.preventDefault();
                const formData = {
                    name: document.getElementById('name').value,
                    email: document.getElementById('email').value
                };
                
                try {
                    const response = await fetch('/users', {
                        method: 'POST',
                        headers: { 'Content-Type': 'application/json' },
                        body: JSON.stringify(formData)
                    });
                    const data = await response.json();
                    document.getElementById('createResult').innerHTML = 
                        `<p class="success">User created successfully!</p>
                         <pre>${JSON.stringify(data, null, 2)}</pre>`;
                    document.getElementById('createForm').reset();
                    refreshUserList();
                } catch (error) {
                    document.getElementById('createResult').innerHTML = 
                        `<p class="error">Error: ${error.message}</p>`;
                }
            });

            // Update user
            document.getElementById('updateForm').addEventListener('submit', async (e) => {
                e.preventDefault();
                const userId = document.getElementById('updateId').value;
                const formData = {};
                
                const name = document.getElementById('updateName').value;
                const email = document.getElementById('updateEmail').value;
                
                if (name) formData.name = name;
                if (email) formData.email = email;
                
                if (Object.keys(formData).length === 0) {
                    document.getElementById('updateResult').innerHTML = 
                        `<p class="error">Please provide at least one field to update</p>`;
                    return;
                }
                
                try {
                    const response = await fetch(`/users/${userId}`, {
                        method: 'PUT',
                        headers: { 'Content-Type': 'application/json' },
                        body: JSON.stringify(formData)
                    });
                    const data = await response.json();
                    document.getElementById('updateResult').innerHTML = 
                        `<p class="success">User updated successfully!</p>
                         <pre>${JSON.stringify(data, null, 2)}</pre>`;
                    document.getElementById('updateForm').reset();
                    refreshUserList();
                } catch (error) {
                    document.getElementById('updateResult').innerHTML = 
                        `<p class="error">Error: ${error.message}</p>`;
                }
            });

            // Delete user
            document.getElementById('deleteForm').addEventListener('submit', async (e) => {
                e.preventDefault();
                const userId = document.getElementById('deleteId').value;
                
                try {
                    const response = await fetch(`/users/${userId}`, {
                        method: 'DELETE'
                    });
                    if (response.ok) {
                        document.getElementById('deleteResult').innerHTML = 
                            `<p class="success">User deleted successfully!</p>`;
                        document.getElementById('deleteForm').reset();
                        refreshUserList();
                    } else {
                        const data = await response.json();
                        document.getElementById('deleteResult').innerHTML = 
                            `<p class="error">Error: ${data.error}</p>`;
                    }
                } catch (error) {
                    document.getElementById('deleteResult').innerHTML = 
                        `<p class="error">Error: ${error.message}</p>`;
                }
            });

            // Initial load of user list
            refreshUserList();
        </script>
    </body>
    </html>
    '''

@app.route('/users', methods=['POST'])
def create_user():
    """Create a new user"""
    data = request.get_json()
    
    if not data or 'name' not in data or 'email' not in data:
        return jsonify({"error": "Name and email are required"}), 400
    
    user_id = str(len(users) + 1)  # Simple ID generation
    user = {
        "id": user_id,
        "name": data["name"],
        "email": data["email"]
    }
    
    users[user_id] = user
    return jsonify(user), 201

@app.route('/users', methods=['GET'])
def get_all_users():
    """Get all users"""
    return jsonify(list(users.values()))

@app.route('/users/<user_id>', methods=['GET'])
def get_user(user_id: str):
    """Get a specific user by ID"""
    if user_id not in users:
        return jsonify({"error": "User not found"}), 404
    return jsonify(users[user_id])

@app.route('/users/<user_id>', methods=['PUT'])
def update_user(user_id: str):
    """Update user data"""
    if user_id not in users:
        return jsonify({"error": "User not found"}), 404
    
    data = request.get_json()
    if not data:
        return jsonify({"error": "No data provided"}), 400
    
    user = users[user_id]
    if 'name' in data:
        user['name'] = data['name']
    if 'email' in data:
        user['email'] = data['email']
    
    return jsonify(user)

@app.route('/users/<user_id>', methods=['DELETE'])
def delete_user(user_id: str):
    """Delete a user"""
    if user_id not in users:
        return jsonify({"error": "User not found"}), 404
    
    del users[user_id]
    return '', 204


if __name__ == '__main__':
    app.run(host='0.0.0.0', port=5000, debug=True)