import os

class DirectoryManager:
    def __init__(self, folder_path):
        """
        Initializes the DirectoryManager with a specific folder path.

        :param folder_path: The path to the folder to manage.
        """
        self.folder_path = folder_path

    def ensure_directory_exists(self):
        """
        Checks if the folder exists, and if not, creates it.
        """
        # Check if the folder exists
        if not os.path.exists(self.folder_path):
            # The folder does not exist, so create it
            try:
                os.makedirs(self.folder_path, exist_ok=True)
                print(f"Directory '{self.folder_path}' was created.")
            except OSError as error:
                print(f"Creation of the directory '{self.folder_path}' failed due to: {error}")
        else:
            print(f"Directory '{self.folder_path}' already exists.")
