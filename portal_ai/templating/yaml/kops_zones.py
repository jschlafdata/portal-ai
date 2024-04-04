class KopsZones:

    def __init__(self, loader, logger):
        self.loader = loader
        self.logger = logger
    
    def get_kops_zones(self):

        kops_base_settings = self.loader.generated_config_loader('kops_settings_base')
        subnet_zones = kops_base_settings['subnets']

        azs = kops_base_settings.get('availabilityZones')
        num_zones = kops_base_settings.get('zones')
        
        all_zones = list(kops_base_settings['subnets'].keys())
        private_zones = [key for key in all_zones if kops_base_settings['subnets'][key].get('private')]
        
        if azs != 'None':
            print(f'so you want some azs: {azs}')
            set1 = set(private_zones)
            set2 = set(azs)
            # Find the intersection (common elements) between the two sets
            matching_azs = list(set1.intersection(set2))
            print(matching_azs)
            if len(matching_azs) % 2 == 0:
                self.logger.info('You must specify an odd number of privates availability zones, defaulting to 1 zone.')
                private_zones = private_zones[:1]
            else:
                private_zones = matching_azs
        
        elif isinstance(num_zones, int):
            if num_zones % 2 == 0:
                self.logger.info('You must specify an odd number of zones, defaulting to 1 zone.')
                private_zones = private_zones[:1]
            else:
                private_zones = private_zones[:num_zones]

        else:
            if len(private_zones) % 2 == 0:
                private_zones.pop()  # Remove the last AZ if the total number is even
        
        zones = {k:v for k,v in subnet_zones.items() if k in private_zones}
        self.logger.info(f'kubernetes will be deployed in the following zones!:: {zones}')
        return zones