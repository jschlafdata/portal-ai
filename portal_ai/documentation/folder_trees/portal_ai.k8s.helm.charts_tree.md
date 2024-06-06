charts
    ├── external
    │   ├── apps
    │   │   ├── k8s-dashboard
    │   │   ├── mageai
    │   │   └── metabase
    │   ├── monitoring
    │   │   ├── grafana
    │   │   ├── kube-state-metrics
    │   │   ├── prometheus
    │   │   └── prometheus-node-exporter
    │   └── system
    │       ├── efs
    │       ├── efs-csi
    │       ├── external-dns
    │       ├── nginx-external
    │       ├── nginx-internal
    │       └── vault
    └── local_custom
        ├── apps
        │   ├── docs
        │   │   ├── Chart.yaml
        │   │   ├── sub_charts
        │   │   │   ├── big-agi
        │   │   │   └── portal-docs
        │   │   └── templates
        │   │       ├── deployment.yaml
        │   │       ├── ingress.yaml
        │   │       └── service.yaml
        │   ├── jupyter-lab-accelerated
        │   │   ├── Chart.yaml
        │   │   └── templates
        │   │       ├── deployment.yaml
        │   │       ├── ingress.yaml
        │   │       ├── pvc.yaml
        │   │       └── service.yaml
        │   ├── llm-models
        │   │   ├── Chart.yaml
        │   │   ├── sub_charts
        │   │   │   └── llama2-7b-cuda
        │   │   └── templates
        │   │       ├── deployment.yaml
        │   │       ├── ingress.yaml
        │   │       ├── pvc.yaml
        │   │       └── service.yaml
        │   └── mageai-workspaces
        │       ├── Chart.yaml
        │       ├── sub_charts
        │       │   ├── development
        │       │   ├── production
        │       │   └── stage
        │       └── templates
        │           ├── ingress.yaml
        │           └── mage-config-maps.yaml
        └── system
            ├── external_secrets
            │   ├── Chart.yaml
            │   └── templates
            │       ├── cluster-store.yml
            │       └── ex-secrets.yml
            └── wildcard-certificate
                ├── Chart.yaml
                └── templates
                    ├── certificate.yaml
                    └── clusterissuer.yaml
