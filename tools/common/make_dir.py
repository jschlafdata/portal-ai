import os

def ensure_directory_exists(folder_path):
    """
    Checks if a folder exists, and if not, creates it.

    :param folder_path: The path to the folder to check/create.
    """
    # Check if the folder exists
    if not os.path.exists(folder_path):
        # The folder does not exist, so create it
        try:
            os.makedirs(folder_path, exist_ok=True)
            print(f"Directory '{folder_path}' was created.")
        except OSError as error:
            print(f"Creation of the directory '{folder_path}' failed due to: {error}")
    else:
        print(f"Directory '{folder_path}' already exists.")