import unittest
from unittest.mock import patch
from tools.deployments.setup.key_gen import SSHKeyGenerator

class TestSSHKeyGenerator(unittest.TestCase):
    @patch('os.path.exists')
    @patch('subprocess.run')
    @patch('tools.deployments.setup.key_gen.ensure_directory_exists')
    def test_generate_ssh_key_new_key(self, mock_ensure_directory, mock_subprocess_run, mock_path_exists):
        """
        Test SSH key generation when the key does not already exist.
        """
        mock_path_exists.return_value = False
        key_generator = SSHKeyGenerator("test_key", "test@example.com", "test_project")
        with patch('builtins.print') as mock_print:
            key_generator.generate_ssh_key()
            self.assertTrue(mock_ensure_directory.called)
            self.assertTrue(mock_subprocess_run.called)
            mock_print.assert_any_call("SSH key id_ed25519_test_key created.")

    @patch('os.path.exists')
    def test_generate_ssh_key_existing_key(self, mock_path_exists):
        """
        Test behavior when the SSH key already exists.
        """
        mock_path_exists.return_value = True
        key_generator = SSHKeyGenerator("existing_key", "test@example.com", "test_project")
        with patch('builtins.print') as mock_print:
            key_generator.generate_ssh_key()
            mock_print.assert_called_with("SSH key id_ed25519_existing_key already exists.")

    @patch('subprocess.call')
    def test_add_key_to_ssh_agent(self, mock_subprocess_call):
        """
        Test adding the SSH key to the SSH agent.
        """
        key_generator = SSHKeyGenerator("test_key", "test@example.com", "test_project")
        ssh_key_path = "/fake/path/id_ed25519_test_key"
        key_generator.add_key_to_ssh_agent(ssh_key_path)
        self.assertTrue(mock_subprocess_call.called)

if __name__ == '__main__':
    unittest.main()