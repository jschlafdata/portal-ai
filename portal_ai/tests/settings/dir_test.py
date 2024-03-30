import os
from portal_ai.settings.logger import LoggerConfig


class DirectoryManager:
    def __init__(self, folder_path):
        """
        Initializes the DirectoryManager with a specific folder path.

        :param folder_path: The path to the folder to manage.
        """
        self.logger = LoggerConfig.get_logger(__name__)
        self.folder_path = folder_path

    def ensure_directory_exists(self):
        """
        Checks if the folder exists, and if not, creates it.
        """
        # Check if the folder exists
        dir_exists = os.path.exists(self.folder_path)
        if not dir_exists:
            # The folder does not exist, so create it
            try:
                os.makedirs(self.folder_path, exist_ok=True)
                self.logger.info(f"Directory '{self.folder_path}' was created.")
                return os.path.exists(self.folder_path)
            except OSError as error:
                self.logger.info(f"Creation of the directory '{self.folder_path}' failed due to: {error}")
                return False
        else:
            self.logger.info(f"Directory '{self.folder_path}' already exists.")
            return dir_exists
