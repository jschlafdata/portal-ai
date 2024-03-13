from collections import defaultdict

def get_subnet_values(subnet_cidrs, 
                      subnet_ids, 
                      availability_zones):
    
    subnet_groups = []
    for cidr, subnet_id, zone in zip(subnet_cidrs, subnet_ids, availability_zones):
        subnet_groups.append({'availability_zone': zone, 'subnet_id': subnet_id, 'subnet_cidr': cidr})
    return subnet_groups

def get_iam_policy_arns(iam_policy_arns):
        arn_dict = {}
        for item in iam_policy_arns:
            name = item[0]
            arn = item[1]
            arn_dict[name]=arn
        return arn_dict

def defaultdict_to_dict(d):
    if isinstance(d, defaultdict):
        d = {k: defaultdict_to_dict(v) for k, v in d.items()}
    elif isinstance(d, dict):
        d = {k: defaultdict_to_dict(v) for k, v in d.items()}
    return d

def compact_subnets( private_subnets,
                     public_subnets ):
    
    compacted_values = defaultdict(lambda: defaultdict(lambda: defaultdict(dict)))

    for subnet_type, subnets in [("private", private_subnets), ("public", public_subnets)]:
        for item in subnets:
            az, cidr, id = item.get('availability_zone'), item.get('subnet_cidr'), item.get('subnet_id')
            compacted_values[az][subnet_type]['cidr'] = cidr
            compacted_values[az][subnet_type]['id'] = id

    return defaultdict_to_dict(compacted_values)

def kops_iam_policies(iam_policies):

    kops_iam_policies = {
        'iam': {
            'allowContainerRegistry': True,
            'useServiceAccountExternalPermissions': True,
            'serviceAccountExternalPermissions': []
        }
    }
    
    for role_name, arn in iam_policies.items():
    
        policy = {'aws': {'policyARNs': [arn]}, 
                     'name':role_name, 
                     'namespace': 'default'}
        
        kops_iam_policies['iam']['serviceAccountExternalPermissions'].append(policy)

    return kops_iam_policies