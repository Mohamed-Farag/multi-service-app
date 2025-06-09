import unittest
from unittest.mock import patch
from app import app

class TestDataProcessingService(unittest.TestCase):
    def setUp(self):
        self.app = app.test_client()
        self.app.testing = True

    @patch('requests.get')
    def test_process_user_data(self, mock_get):
        # Mock response from Service A
        mock_user_data = {
            "id": "1",
            "name": "John Doe",
            "email": "john@example.com"
        }
        mock_get.return_value.status_code = 200
        mock_get.return_value.json.return_value = mock_user_data

        # Test processing user data
        response = self.app.post('/process/user/1')
        self.assertEqual(response.status_code, 200)
        data = response.get_json()
        
        self.assertEqual(data['user_id'], mock_user_data['id'])
        self.assertEqual(data['name'], mock_user_data['name'])
        self.assertEqual(data['email'], mock_user_data['email'])
        self.assertEqual(data['email_domain'], 'example.com')
        self.assertEqual(data['name_length'], len(mock_user_data['name']))

    @patch('requests.get')
    def test_process_nonexistent_user(self, mock_get):
        # Mock 404 response from Service A
        mock_get.return_value.status_code = 404

        response = self.app.post('/process/user/999')
        self.assertEqual(response.status_code, 404)
        data = response.get_json()
        self.assertEqual(data['error'], 'User not found')

    @patch('requests.get')
    def test_service_a_connection_error(self, mock_get):
        # Mock connection error from Service A
        mock_get.side_effect = Exception("Connection error")

        response = self.app.post('/process/user/1')
        self.assertEqual(response.status_code, 503)
        data = response.get_json()
        self.assertIn('Service A connection error', data['error'])

if __name__ == '__main__':
    unittest.main()