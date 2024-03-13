import os
import sys
from tools.settings import BaseDir
import argparse
from tools.templating.yaml.yaml_manager import (
    YmlManager,
    JinjaRender
)


def get_input_file_path( template_paths,
                         environment, 
                         module ):
    
    path_mapping = YmlManager(template_paths, environment).load_and_format()
    input_template = path_mapping.get('modules').get(module)
    return input_template

def parse_arguments():
    parser = argparse.ArgumentParser(description="Generate yaml variable file outputs using input variable map.")

    parser.add_argument(
        "-e", "--environment", help="Deployment environment"
    )

    parser.add_argument(
         "-m", "--module", help="terraform module this is for.", default=None
    )
    
    args = parser.parse_args()
    return args


if __name__ == "__main__":

    args = parse_arguments()

    ( environment, module ) = (args.environment, args.module)

    template_paths = './tools/templating/render_jinja_templates/config_path.yml'
    if BaseDir().set_dir() == True:
        print(f"current working directory: {os.getcwd()}")
        template_paths = get_input_file_path( template_paths,
                                              environment, 
                                              module )

        render_tmpl_path = template_paths.get('template_path')
        source_config_path = template_paths.get('source_config_path')
        output_tmpl_path = template_paths.get('output_path')
        render_funcs = template_paths.get('render_funcs')

        rendered_configs = JinjaRender( source_config_path, 
                                        render_tmpl_path, 
                                        environment, 
                                        render_funcs).render_j2()
        
        YmlManager(output_tmpl_path).save(rendered_configs)

    else:
        print(f"script not executed from root dir, exiting.. cwd is: {os.getcwd()}")
        sys.exit()