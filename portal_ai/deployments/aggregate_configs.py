import os
import subprocess
import sys
import yaml
from typing import List, Tuple
from collections import defaultdict 

from portal_ai.settings.logger import LoggerConfig
from portal_ai.settings.get_environment import get_project_env

from portal_ai.templating.yaml.yaml_manager import (
    JinjaRender,
    YmlManager,
    TemplateRenderer
)

from portal_ai.settings.load_settings import (
    ConfigReader,
    ConfigurationLoader
)

from portal_ai.templating.yaml.kops_zones import KopsZones

ATLANTIS_ENVS = [
    "ATLANTIS_GH_USER",
    "ATLANTIS_ORG_ALLOW",
    "ATLANTIS_GH_TOKEN",
    "ATLANTIS_WEBHOOK"
]


def save_cluster_config( cluster_config, 
                         instance_groups, 
                         accelerated_node_ig_groups, 
                         output_file ):
    
    with open(output_file, 'w') as file:
        yaml.dump(cluster_config, file, sort_keys=False)
        file.write('---\n')  # Separator after the cluster configuration
        for i, ig in enumerate(instance_groups):
            yaml.dump(ig, file, sort_keys=False)
            if i < len(instance_groups) - 1:  # Check if it's not the last instance group
                file.write('---\n')  # Add dashes only if it's not the last one
    
    gpu_path = output_file.replace('kops_cluster_base', 'kops_gpu_nodes_base')
    with open(gpu_path, 'w') as file:
        gpu_node_ig_groups = accelerated_node_ig_groups.get('gpu_nodes')
        inf_node_ig_groups = accelerated_node_ig_groups.get('inf2_nodes')

        for i, ig in enumerate(gpu_node_ig_groups):
            yaml.dump(ig, file, sort_keys=False)
            file.write('---\n')

        for i, ig in enumerate(inf_node_ig_groups):
            yaml.dump(ig, file, sort_keys=False)
            if i < len(inf_node_ig_groups) - 1:  # Check if it's not the last instance group
                file.write('---\n')  # Add dashes only if it's not the last one

class HelmDeploymentManager:
    def __init__(self):
        self.logger = LoggerConfig.get_logger(__name__)
        self.loader = ConfigurationLoader(ConfigReader)
        self.deploment_configs = self.loader.generated_config_loader('aws_plus_global_base')['helm_deployments']
        self.atlantis_secrets = {k:os.getenv(k, '') for k in ATLANTIS_ENVS}
        self.helm_values_path = 'portal_ai/configs/generated/helm_values_base.yml'
        self.global_values = YmlManager(self.helm_values_path).load()
        self.base_template_dir = 'portal_ai/templating/templates/charts'
        self.deploy_charts = []
        self.helm_directories = [
            'local_custom/apps',
            'local_custom/system',
            'external/apps',
            'external/system',
            'external/monitoring'
        ]

        self.rendered_results = {}

    def parse_yaml(self):
        self.deploy_charts.extend(self.deploment_configs['required'])
        for category, details in self.deploment_configs['optional'].items():
            include = details.get('include').get('charts')
            if include:
                print(include)
                self.deploy_charts.extend(include)

    def generate_full_paths(self) -> List[str]:
        return [os.path.join(self.base_template_dir, helm_dir) for helm_dir in self.helm_directories]

    def list_all_charts(self, full_paths: List[str]) -> List[Tuple[str, List[str]]]:
        return [(path, os.listdir(path)) for path in full_paths]

    def filter_charts(self, all_charts: List[Tuple[str, List[str]]]) -> List[Tuple[str, List[str]]]:
        deploy_charts = [(path, [chart for chart in charts if chart in self.deploy_charts]) for path, charts in all_charts]
        flattened_charts = [os.path.join(path, chart) for path, charts in deploy_charts for chart in charts]
        return flattened_charts

    def get_chart_paths(self):
        self.parse_yaml()
        full_paths = self.generate_full_paths()
        all_charts = self.list_all_charts(full_paths)
        filtered_charts = self.filter_charts(all_charts)
        return filtered_charts

    def has_subchart_values(self, chart_path: str) -> bool:
        return 'subchart.values.yaml' in os.listdir(chart_path)

    def render_chart(self, chart_path: str):
        render_tmpl = f"{os.path.basename(chart_path)}.tmpl.j2"
        render_tmpl_path = os.path.join(chart_path, render_tmpl)

        split_path = chart_path.split('portal_ai/templating/templates/')
        dest_base_path = os.path.join('portal_ai/terraform/helm/configs', split_path[-1])
        
        if not self.has_subchart_values(chart_path):
            # No subcharts, render with global values
            chart_input_vals = {**self.global_values, **self.atlantis_secrets}
            rendered_values = JinjaRender(chart_input_vals, render_tmpl_path).render_j2()
            dest_file = os.path.join(dest_base_path, 'values.yaml')
            self.rendered_results[dest_file] = rendered_values
        else:
            # Process subchart values
            sub_chart_val_path = os.path.join(chart_path, 'subchart.values.yaml')
            sub_chart_values = YmlManager(sub_chart_val_path).load()['charts']
            for chart, vals in sub_chart_values.items():
                chart_input_vals = {**vals, **self.global_values, **self.atlantis_secrets}
                rendered_values = JinjaRender(chart_input_vals, render_tmpl_path).render_j2()

                sub_chart_path = f"{dest_base_path}/sub_charts/{chart}"
                dest_file = os.path.join(sub_chart_path, 'values.yaml')
                self.rendered_results[dest_file] = rendered_values

    def render_all_charts(self):
        chart_paths = self.get_chart_paths()
        for chart_path in chart_paths:
            self.render_chart(chart_path)

        for path, values in self.rendered_results.items():
            YmlManager(path).save(values)

    def construct_deploy_dict(self):
        """
        Construct the deploy dictionary based on required and optional deployments.
        """
        deploy_dict = defaultdict(dict)
        deploy_list = self.deploment_configs['required']
        defaults = {x: True for x in deploy_list}

        for k, v in self.deploment_configs['optional'].items():
            include = v.get('include').get('charts')
            exclude = v.get('exclude').get('charts')
            if include:
                for chart in include:
                    deploy_dict[chart] = True
            if exclude:
                for chart in exclude:
                    deploy_dict[chart] = False

        self.deploy_dict = {**deploy_dict, **defaults}

    def generate_terraform_deploy_values(self):
        """
        Generate Terraform deploy values based on deploy dictionary.
        """
        self.construct_deploy_dict()
        terraform_deploy_values = defaultdict(dict)
        for dir_ in self.helm_directories:
            search_dir = os.path.join(self.base_template_dir, dir_)
            base_dest_dir = search_dir.split('portal_ai/templating/templates/charts/')[-1]
            for chart in os.listdir(search_dir):
                chart_path = os.path.join(base_dest_dir, chart).replace('/', '.')
                terraform_deploy_values[chart_path] = self.deploy_dict.get(chart, False)

        YmlManager('portal_ai/terraform/helm/configs/generated/helm_deployment_settings.yml').save(dict(terraform_deploy_values))


class BaseConfigGenerator:

    def __init__(self):

        self.logger = LoggerConfig.get_logger(__name__)

        self.loader = ConfigurationLoader(ConfigReader)
        self.global_settings_base = self.loader.generated_config_loader('global_settings_base')
        self.aws_settings_base = self.loader.generated_config_loader('aws_settings_base')

    def generate_aws_base_configs(self):
        
        global_plus_aws_settings = {**self.global_settings_base, **self.aws_settings_base}
        TemplateRenderer(self.loader).render_and_save(global_plus_aws_settings, 'aws_settings_base')
        self.logger.info("AWS terraform outputs + global settings configurations generated successfully.")

    def generate_kops_base_configs(self):
        
        aws_plus_global_base_config = self.loader.generated_config_loader('aws_plus_global_base')
        TemplateRenderer(self.loader).render_and_save(aws_plus_global_base_config, 'kops_settings_base')
        self.logger.info("Kops settings configurations generated successfully.")

    def generate_helm_base_configs(self):
        
        aws_plus_global_base_config = self.loader.generated_config_loader('aws_plus_global_base')
        TemplateRenderer(self.loader).render_and_save(aws_plus_global_base_config, 'helm_settings_base')
        self.logger.info("Helm Values settings configurations generated successfully.")

    def generate_kops_cluster_config(self):

        zones = {'active_zones': KopsZones(self.loader, self.logger).get_kops_zones()}
        kops_settings_base = self.loader.generated_config_loader('kops_settings_base')
        
        constant_configs = self.loader.global_base_config_loader('constant_config')
        render_output_paths = constant_configs.get('generated_output_paths').get('kops_cluster_base')

        
        kops_base = {**kops_settings_base, **zones}

        kops_cluster_base = TemplateRenderer(self.loader).render(kops_base, 'kops_cluster_base')
        kops_ig_base = TemplateRenderer(self.loader).render(kops_base, 'kops_instance_groups_base')
        nodes = kops_ig_base.get('masters', []) + kops_ig_base.get('nodes', [])

        for path in render_output_paths:
            save_cluster_config( kops_cluster_base, 
                                 nodes, 
                                 kops_ig_base.get('accelerated_nodes', []), 
                                 path )

if __name__ == "__main__":

    BaseConfigGenerator().generate_aws_base_configs()
    BaseConfigGenerator().generate_helm_base_configs()
    BaseConfigGenerator().generate_kops_base_configs()
    BaseConfigGenerator().generate_kops_cluster_config()
    HelmDeploymentManager().render_all_charts()
    HelmDeploymentManager().generate_terraform_deploy_values()

