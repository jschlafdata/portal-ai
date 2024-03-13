import yaml
from functools import reduce
from jinja2 import Template
from tools.templating.render_jinja_templates.py_filters import *

class YmlManager:
    def __init__(self, path, environment=None):
        self.path = path
        self.environment = environment

    def load(self):
        with open(self.path, 'r') as file:
            return yaml.safe_load(file)

    def save(self, data):
        with open(self.path, 'w') as outfile:
            yaml.dump(data, outfile, default_flow_style=False, sort_keys=False)
            print(f"Successfully wrote to file: {self.path}")

    def format_data(self, data):
        if isinstance(data, dict):
            return {key: self.format_data(value) for key, value in data.items()}
        elif isinstance(data, list):
            return [self.format_data(item) for item in data]
        elif isinstance(data, str):
            return data.format(environment=self.environment)
        return data

    def load_and_format(self):
        return self.format_data(self.load())
    

class ConfigExtractor:
    def __init__(self,
                 input_dict):
        
        self.input_dict = input_dict
        self.extract_dict = {}
        

    def load_source( self,
                     source_path ):
        
        source_dict = YmlManager(source_path).load()
        return source_dict
    
    def get_value_by_path(self, 
                          path):
        """
        Extracts a value from a nested dictionary using a dot-separated string path.

        Parameters:
        - config_dict: The dictionary to search.
        - path: A dot-separated string indicating the path to the desired value.

        Returns:
        - The value found at the specified path, or None if the path is invalid.
        """
        keys = [key for key in path.split('.') if key]
        current_value = self.config_dict
        try:
            for key in keys:
                current_value = current_value[key]
            return current_value
        except (KeyError, TypeError):
            # KeyError if a key doesn't exist, TypeError if an attempt is made
            # to index a non-dictionary type along the path.
            return None

    def key_extract(self, extract_items):
        for key, key_path in extract_items.items():
            path_value = self.get_value_by_path(key_path)
            self.extract_dict[key]=path_value

    def var_extract(self, input_dict):
        source_path = input_dict.get('source_path')
        input_dict.pop('source_path')
        
        self.config_dict = self.load_source(source_path)
        self.key_extract(input_dict)

    def extract(self):
        # print(self.input_dict)
        for input_dict in self.input_dict:
            self.var_extract( input_dict )
        return self.extract_dict


class JinjaRender:
    def __init__( self, 
                  source_config_path, 
                  render_tmpl_path, 
                  environment,
                  render_funcs=None ):
        
        self.source_config    = YmlManager( source_config_path, 
                                            environment=environment ).load()
        
        self.render_tmpl_path = render_tmpl_path
        self.environment      = environment
        self.render_funcs     = render_funcs

    def render_template(self):
        with open(self.render_tmpl_path, 'r') as f:
            template_content = f.read()

        template = Template(template_content)
        return template

    def safe_encode_dict(self):
        # Characters that are considered special and require double quotes
        special_characters = ['\n', ':', '#', '&', '*', '!', '|', '>', '<', '=', '%', '@']

        # Loop through the dictionary and add double quotes to items with special characters
        for key, value in self.source_config.items():
            # Convert value to string for the check if it's not a string
            value_str = str(value)
            if any(char in value_str for char in special_characters):
                # Only modify the original value if it was a string to begin with
                if isinstance(value, str):
                    self.source_config[key] = f'"{value}"'
    
    def render_j2(self):

        template = self.render_template()
        self.safe_encode_dict()
        self.source_config['env'] = self.environment

        if self.render_funcs:
            render_func_dict = {func_name: globals()[func_name] for func_name in self.render_funcs if func_name in globals()}
            print(f"Rendered func dict!: {render_func_dict}")
            template.globals.update(render_func_dict)

        render_values = template.render(self.source_config)
        rendered_data = yaml.safe_load(render_values)
        return rendered_data