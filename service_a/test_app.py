import unittest
from app import app


class TestUserService(unittest.TestCase):
    def setUp(self):
        self.app = app.test_client()
        self.app.testing = True

    def test_create_user(self):
        # Test creating a new user
        user_data = {
            "name": "Mohamed Farag",
            "email": "Mohamed@gmail.com"
        }
        response = self.app.post(
            '/users',
            json=user_data,
            content_type='application/json',
        )
        self.assertEqual(response.status_code, 201)
        data = response.get_json()
        self.assertEqual(data['name'], user_data['name'])
        self.assertEqual(data['email'], user_data['email'])
        self.assertIn('id', data)

    def test_get_user(self):
        # First create a user
        user_data = {
            "name": "Mohamed Farag",
            "email": "Mohamed@gmail.com"
        }
        create_response = self.app.post(
            '/users',
            json=user_data,
            content_type='application/json',
        )
        user_id = create_response.get_json()['id']

        # Test getting the user
        response = self.app.get(f'/users/{user_id}')
        self.assertEqual(response.status_code, 200)
        data = response.get_json()
        self.assertEqual(data['name'], user_data['name'])
        self.assertEqual(data['email'], user_data['email'])

    def test_get_nonexistent_user(self):
        response = self.app.get('/users/999')
        self.assertEqual(response.status_code, 404)


if __name__ == '__main__':
    unittest.main()
