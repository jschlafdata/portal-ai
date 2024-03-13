import yaml
import argparse

def load_yaml_config(file_path):
    with open(file_path, 'r') as file:
        return yaml.safe_load(file)

def save_cluster_config( cluster_config, 
                         instance_groups, 
                         gpu_node_ig_groups, 
                         output_file ):
    
    with open(output_file, 'w') as file:
        yaml.dump(cluster_config, file, sort_keys=False)
        file.write('---\n')  # Separator after the cluster configuration
        for i, ig in enumerate(instance_groups):
            yaml.dump(ig, file, sort_keys=False)
            file.write('---\n')  # Separator after the cluster configuration
        for i, ig in enumerate(gpu_node_ig_groups):
            yaml.dump(ig, file, sort_keys=False)
            if i < len(gpu_node_ig_groups) - 1:  # Check if it's not the last instance group
                file.write('---\n')  # Add dashes only if it's not the last one

def save_gpu_config( gpu_node_ig_groups, 
                     output_file ):
    
    with open(output_file, 'w') as file:
        for i, ig in enumerate(gpu_node_ig_groups):
            yaml.dump(ig, file, sort_keys=False)
            if i < len(gpu_node_ig_groups) - 1:  # Check if it's not the last instance group
                file.write('---\n')  # Add dashes only if it's not the last one


def generate_cluster_config(input_config, zones):

    clusterName = input_config['clusterName']

    masterInternalName = f"internal.{clusterName}"
    masterPublicName = clusterName
    discoveryStore = input_config['discoveryStore']
    kopsSshKeyName = input_config['kopsSshKeyName']

    kubernetesApiAccess = input_config['vpnInternalNetworkIp']
    sshAccess = [input_config['vpnInternalNetworkIp'], input_config['networkCIDR']]
    iam = input_config['kopsIamConfigs']['iam']
    configBase = input_config['configBase']
    dnsZone = input_config['dnsZoneId']
    networkCIDR = input_config['networkCIDR']
    networkID = input_config['networkID']

    addZones = input_config.get('additionalDnsZones')
    print(addZones)
    if addZones:
        addZones.append(dnsZone)
        certZones = addZones
    else:
        certZones = [dnsZone]

    etcdClusters = [
                {
                    'cpuRequest': '200m' if name == 'main' else '100m',
                    'memoryRequest': '100Mi',
                    'name': name,
                    'etcdMembers': [
                        {
                            'encryptedVolume': True,
                            'instanceGroup': f"master-{zone}",
                            'name': zone[-1]  # Assumes the last character of the zone designator (e.g., 'b' for 'us-west-2b') can serve as the name
                        }
                        for zone in zones  # Creates an etcdMember for each zone
                    ]
                } for name in ['main', 'events']  # Creates two etcdClusters: 'main' and 'events'
    ]
    
    subnets = [
                {
                    'cidr': input_config['subnets'][zone][net_type]['cidr'],
                    **({'egress': input_config['natGatewayId']} if net_type == 'private' else {}),  # Conditional egress for private subnets
                    'id': input_config['subnets'][zone][net_type]['id'],
                    'name': f"utility-{zone}" if net_type == 'public' else zone,
                    'type': 'Private' if net_type == 'private' else 'Utility',
                    'zone': zone
                }
                for zone in zones
                for net_type in zones[zone]
    ]
    
    cluster_config = {
        'apiVersion': 'kops.k8s.io/v1alpha2',
        'kind': 'Cluster',
        'metadata': {
            'name': clusterName
        },
        'spec': {
            'api': {
                'loadBalancer': {
                    'class': 'Network',
                    'crossZoneLoadBalancing': True,
                    'type': 'Internal'
                }
            },
            'authorization': {
                'rbac': {}
            },
            'iam': iam,
            'containerd': {
                'nvidiaGPU': {
                        'enabled': True ,
                        'dcgmExporter': {
                            'enabled': True
                        },
                        'package': 'nvidia-headless-535-server'
                }
            },
            'channel': 'stable',
            'cloudProvider': 'aws',
            'clusterAutoscaler': {
                'cpuRequest': '100m',
                'enabled': True,
                'memoryRequest': '300Mi'
            },
            'configBase': configBase,
            'dnsZone': dnsZone,
            'etcdClusters': etcdClusters,
            'kubeDNS': {
                      'nodeLocalDNS': {
                                'cpuRequest': '25m',
                                'enabled': True,
                                'memoryRequest': '5Mi'
                      },
                      'provider': 'CoreDNS'
            },
            'kubeProxy': {
                'ipvsScheduler': 'lc',
                'proxyMode': 'ipvs'
            },
            'kubelet': {
                'anonymousAuth': False,
                'authenticationTokenWebhook': True,
                'authorizationMode': 'Webhook'
            },
            'kubernetesApiAccess': [kubernetesApiAccess],
            'kubernetesVersion': '1.29.2',
            'masterInternalName': masterInternalName,
            'masterPublicName': masterPublicName, 
            'networkCIDR': networkCIDR,
            'networkID': networkID,
            'networking': {
                    'calico': {
                        'mtu': 8981
                    }
              },
            'nonMasqueradeCIDR': '100.64.0.0/10',
            'serviceAccountIssuerDiscovery': {
                    'enableAWSOIDCProvider': True,
                    'discoveryStore': discoveryStore
              },
            'podIdentityWebhook': {
                    'enabled': True
            },
            'certManager': {
                'enabled': True,
                'managed': True,
                'hostedZoneIDs': certZones
            },
            'sshAccess': sshAccess,
            'sshKeyName': kopsSshKeyName,
            'subnets': subnets,
            'topology': {
                    'dns': {
                        'type': 'Public'
                    },
                    'masters': 'private',
                    'nodes': 'private'
            },
        }
    }
    return cluster_config

def generate_instance_groups(input_config, zones, clusterName):

    image = input_config.get('image')
    machineType = input_config.get('machineType')
    maxNodeSize = input_config.get('maxNodeSize')

    instance_groups = []
    for zone in zones:
        # Master instance group for each zone
        master_ig = {
            'apiVersion': 'kops.k8s.io/v1alpha2',
            'kind': 'InstanceGroup',
            'metadata': {
                'labels': {
                    'kops.k8s.io/cluster': clusterName
                },
                'name': f"master-{zone}"
            },
            'spec': {
                'image': image,
                'machineType': machineType,
                'maxSize': 1,
                'minSize': 1,
                'nodeLabels': {
                    'kops.k8s.io/instancegroup': f"master-{zone}"
                },
                'role': 'Master',
                'rootVolumeEncryption': True,
                'subnets': [
                    zone
                ]
            }
        }
        instance_groups.append(master_ig)

        # Node instance group for each zone
        node_ig = {
            'apiVersion': 'kops.k8s.io/v1alpha2',
            'kind': 'InstanceGroup',
            'metadata': {
                'labels': {
                    'kops.k8s.io/cluster': clusterName
                },
                'name': f"nodes-{zone}"
            },
            'spec': {
                'image': image,
                'machineType': machineType,
                'maxSize': maxNodeSize,
                'minSize': 1,
                'nodeLabels': {
                    'kops.k8s.io/instancegroup': f"nodes-{zone}"
                },
                'role': 'Node',
                'rootVolumeEncryption': True,
                'subnets': [
                    zone
                ]
            }
        }
        instance_groups.append(node_ig)
    return instance_groups


def generate_gpu_groups( input_config, 
                         zone, 
                         clusterName,
                         base=True ):

    if base == True:
        gpu_groups = input_config.get('gpuGroups')
    elif base == False:
        gpu_groups = input_config.get('additionalGpuNodeGroups')

    image = input_config.get('image')
    instance_groups_gpu = []
    for grp in gpu_groups:
        igname = grp.get('igName')
        machineType = grp.get('machineType')
        maxNodeSize = grp.get('maxNodeSize')
        gpus = grp.get('gpus')
        # Master instance group for each zone
        gpu_ig = {
            'apiVersion': 'kops.k8s.io/v1alpha2',
            'kind': 'InstanceGroup',
            'metadata': {
                'labels': {
                    'kops.k8s.io/cluster': clusterName
                },
                'name': f"gpu-nodes-{igname}"
            },
            'spec': {
                'image': image,
                'machineType': machineType,
                'maxSize': maxNodeSize,
                'minSize': 0,
                'nodeLabels': {
                    'instance-group': f"gpu-nodes-{igname}"
                },
                'role': 'Node',
                'subnets': [
                    zone
                ],
                'cloudLabels': {
                    'node_type': 'gpu',
                    'instance_type': igname,
                    'gpus': f"{gpus}"
                }
            }
        }
        instance_groups_gpu.append(gpu_ig)

    return instance_groups_gpu

def validate_zones(args, input_config):

    print(f"Environment: {args.environment}, Number of Zones: {args.num_zones}, AZs: {args.azs}")
    subnet_zones = input_config['subnets']

    all_zones = list(input_config['subnets'].keys())
    private_zones = [key for key in all_zones if input_config['subnets'][key].get('private')]
    
    if args.azs:
        set1 = set(private_zones)
        set2 = set(args.azs)
        # Find the intersection (common elements) between the two sets
        matching_azs = list(set1.intersection(set2))
        print(matching_azs)
        if len(matching_azs) % 2 == 0:
            print('You must specify an odd number of privates azs')
        else:
            private_zones = matching_azs
    
    elif args.num_zones:
        if args.num_zones % 2 == 0:
            print('You must specify an odd number of zones')
        else:
            private_zones = private_zones[:args.num_zones]

    else:
        if len(private_zones) % 2 == 0:
            private_zones.pop()  # Remove the last AZ if the total number is even
    
    zones = {k:v for k,v in subnet_zones.items() if k in private_zones}
    return zones

def process_gpu_groups( input_config,
                        zone_names,
                        cluster_name,
                        base ):

    gpu_node_ig_groups = []
    # # Save the cluster.yaml file
    for zone in zone_names:
        gpu_groups = generate_gpu_groups(input_config, zone, cluster_name, base)
        for grp in gpu_groups:
            gpu_node_ig_groups.append(grp)
    
    return gpu_node_ig_groups

def parse_arguments():
    ## py tools/config_builders/generate_cluster_config.py stage --num_zones 3
    ## py tools/config_builders/generate_cluster_config.py stage --azs us-west-2d,us-west-2b,us-west2c

    parser = argparse.ArgumentParser(description="Generate cluster configuration with optional AZs and number of zones.")
    parser.add_argument("environment", help="Deployment environment")
    parser.add_argument("--num_zones", type=int, help="Number of zones (optional)", default=None)
    parser.add_argument("--azs", help="Comma-separated list of availability zones (optional)", default="")
    
    args = parser.parse_args()
    
    # Convert azs from comma-separated string to list, only if azs is not empty
    if args.azs:
        args.azs = args.azs.split(',')
    else:
        args.azs = []
    
    return args

if __name__ == "__main__":

    args = parse_arguments()
    environment = args.environment

    input_file_path = f'./{environment}/kops/input_configs/kops_base_configs.yml'  # The path to your YAML configuration output
    output_file_path = f'./{environment}/kops/cluster_build.yml'  # The desired output file path for cluster.yaml
    output_gpu_path = f'./{environment}/kops/gpu_instance_groups.yml'  # The desired output file path for cluster.yaml

    # Load the initial YAML configuration
    input_config = load_yaml_config(input_file_path)

    zones = validate_zones(args, input_config)
    zone_names = list(zones.keys())

    # Generate the cluster configuration
    cluster_config = generate_cluster_config(input_config, zones)
    instance_groups = generate_instance_groups(input_config, zones, cluster_config['metadata']['name'])

    gpu_node_ig_groups = []
    # # Save the cluster.yaml file
    for zone in zone_names:
        gpu_groups = generate_gpu_groups(input_config, zone, cluster_config['metadata']['name'])
        for grp in gpu_groups:
            gpu_node_ig_groups.append(grp)

    gpu_node_ig_groups = process_gpu_groups( input_config, 
                                             zone_names, 
                                             cluster_config['metadata']['name'], 
                                             base=True )
    
    save_cluster_config(cluster_config, instance_groups, gpu_node_ig_groups, output_file_path)
        # Generate instance groups for each availability zone
    
    gpu_node_add_groups = process_gpu_groups( input_config, 
                                              zone_names, 
                                              cluster_config['metadata']['name'], 
                                              base=False )
    
    save_gpu_config(gpu_node_add_groups, output_gpu_path)

    print(f"Cluster configuration has been successfully generated in {output_file_path}")
    print(f"GPU IG configurations have been successfully generated in {output_gpu_path}")