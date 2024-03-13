import os
import sys
from tools.settings import BaseDir
from jinja2 import Template
import yaml

def yml_load(yml_path):
    with open(yml_path, 'r') as file:
        yml_file = yaml.safe_load(file)
    return yml_file

def render_template(tmpl_file):
    with open(tmpl_file, 'r') as f:
        template_content = f.read()

    template = Template(template_content)
    return template

def safe_encode_dict(final_dict):
    # Characters that are considered special and require double quotes
    special_characters = ['\n', ':', '#', '&', '*', '!', '|', '>', '<', '=', '%', '@']
    
    # Loop through the dictionary and add double quotes to items with special characters
    for key, value in final_dict.items():
        if any(char in value for char in special_characters):
            final_dict[key] = f'"{value}"'
    return final_dict

def parse_template(chart_dir, var_path, chart):

    vars_yml = yml_load(var_path).get(chart)

    values_file = vars_yml.get('values_file')
    output_values_path = f"{chart_dir}/{values_file}"
    print(output_values_path)
    
    vars = vars_yml.get('vars')
    sa_name = vars_yml.get('sa_name')

    tmpl_file = vars_yml.get('tmpl_file')
    template = render_template(f'{chart_dir}/{tmpl_file}')

    sa_dict = {}
    var_dict = {}
    
    if sa_name:
        sa_dict = {
            'service_account_name': sa_name,
            'iam_role': helm_values['iamPolicies'][sa_name]
        }
    
    if vars:
        var_dict = {}
        for var in vars:
            value=helm_values.get(var)
            var_dict[var]=value
    
    standard_keys = ['values_file','tmpl_file','vars','sa_name']
    var_keys = list(vars_yml.keys())
    manual_keys = list(set(var_keys) - set(standard_keys))

    manual_dict = {}
    if manual_keys:
        for key in manual_keys:
            value = vars_yml.get(key)
            manual_dict[key]=value

    # Assuming final_dict is a dictionary containing your combined data
    final_dict = {**var_dict, **sa_dict, **manual_dict}
    final_dict = safe_encode_dict(final_dict)

    render_values = template.render(final_dict)
    yaml_data = yaml.safe_load(render_values)
    
    # Write the encoded dictionary to a YAML file
    with open(output_values_path, 'w') as outfile:
        yaml.safe_dump(yaml_data, outfile, default_flow_style=False, sort_keys=False)
    
    print(f"Wrote successfully to file: {output_values_path}")
    
    return render_values


if __name__ == "__main__":
    if len(sys.argv) != 2:
        print("Usage: python build_kops_config.py <environment>")
        sys.exit(1)

    is_base = BaseDir().set_dir()
    print(f"current working directory: {os.getcwd()}")

    if is_base == False:
        sys.exit()
    else:
        environment = sys.argv[1]  # Get the environment from the command line

        base_dir = f"./{environment}/k8s/helm/charts"

        charts = os.listdir(base_dir)
        helm_values_path = f"./{environment}/k8s/helm/input_configs/helm_base_configs.yml"
        helm_values = yml_load(helm_values_path)

        for chart in charts:
            chart_dir = f"{base_dir}/{chart}"
            chart_files = os.listdir(chart_dir)

            base_var_file = any([x for x in chart_files if x == 'tmpl.vars.yaml'])
            if base_var_file:
                var_path = f'{chart_dir}/tmpl.vars.yaml'
                
                rendered_values = parse_template(chart_dir, var_path, chart)

            sub_chart_dir = f'{chart_dir}/sub_charts'
            if not base_var_file and os.path.exists(sub_chart_dir):
                sub_charts = os.listdir(f'{chart_dir}/sub_charts')
                for chart in sub_charts:
                    _sub_chart_dir = f'{sub_chart_dir}/{chart}'
                    var_path = f'{_sub_chart_dir}/tmpl.vars.yaml'

                    rendered_values = parse_template(chart_dir, var_path, chart)