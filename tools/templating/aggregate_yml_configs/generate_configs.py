import os
import sys
from tools.settings import BaseDir
import argparse
from tools.templating.yaml.yaml_manager import (
    YmlManager,
    ConfigExtractor
)


def get_input_file_path( environment, 
                         module ):
    
    path_mapping = YmlManager('./tools/templating/aggregate_yml_configs/config_path.yml', environment).load_and_format()
    input_template = path_mapping.get('paths').get(module)
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

    ( environment, 
      module ) = ( args.environment, 
                   args.module )

    is_base = BaseDir().set_dir()
    print(f"current working directory: {os.getcwd()}")

    if is_base == False:
        sys.exit()
    else:

        input_template = get_input_file_path( environment, 
                                              module )


        formatted_dict = YmlManager(input_template, environment).load_and_format()
        output_path = formatted_dict.get('inputs').get('output_path')
        input_variables = formatted_dict.get('inputs').get('variables')

        extracted_values = ConfigExtractor(input_variables).extract()

        final_values = { 
                        **extracted_values, 
                        **{'environment': environment}
        }

        YmlManager(output_path).save(final_values)
