import yaml
from functools import reduce
from jinja2 import Template
from portal_ai.settings.get_environment import get_project_env
from portal_ai.templating.yaml.py_filters import *
import os

class YmlManager:
    def __init__(self, path):
        self.path = path
        self.environment = get_project_env()

    def load(self):
        with open(self.path, 'r') as file:
            return yaml.safe_load(file)

    def save(self, data):
        # Extract the directory path from the full file path
        directory = os.path.dirname(self.path)

        # Check if the directory exists, and if not, create it (including any necessary intermediate directories)
        if not os.path.exists(directory):
            os.makedirs(directory)

        # Proceed to write the file as before
        with open(self.path, 'w') as outfile:
            yaml.dump(data, outfile, default_flow_style=False, sort_keys=False)
            print(f"Successfully wrote to file: {self.path}")


class JinjaRender:
    def __init__( self, 
                  source_config, 
                  render_tmpl_path, 
                  render_funcs=None ):
        
        self.source_config    = source_config
        self.render_tmpl_path = render_tmpl_path
        self.environment      = get_project_env()
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

class TemplateRenderer:
    def __init__(self, loader):
        self.loader = loader
        self.constant_configs = self.loader.global_base_config_loader('constant_config')

    def render(self, settings_base, render_config_key):

        render_tmplate_configs = self.constant_configs.get('jinja_template_paths').get(render_config_key)

        render_tmpl_path = render_tmplate_configs.get('template_path')
        render_funcs = render_tmplate_configs.get('render_funcs')

        return JinjaRender(settings_base, render_tmpl_path, render_funcs).render_j2()

    def render_and_save(self, settings_base, render_config_key):
        rendered_configs = self.render(settings_base, render_config_key)
        render_output_paths = self.constant_configs.get('generated_output_paths').get(render_config_key)
        for path in render_output_paths:
            YmlManager(path).save(rendered_configs)