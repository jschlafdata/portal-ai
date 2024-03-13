import os
from tools.templating.yaml.yaml_manager import YmlManager
# Assuming settings.py is two levels deep from the project root

class BaseDir:
    def __init__(self):
        self.BASE_DIR = os.path.dirname(os.path.dirname(os.path.abspath(__file__)))
    def set_dir(self):
        os.chdir(self.BASE_DIR)
        try:
            return YmlManager('root.yml').load()['is_root']
        except:
            return False