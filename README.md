# Kubernetes Active Monitoring and Stat Gathering Setup

This repository contains configurations and resources for deploying an active monitoring and statistics gathering setup on a Kubernetes cluster. The setup consists of Prometheus for collecting metrics, Grafana for visualization, and a reporting application for sharing Grafana dashboards via email.

## Table of Contents

- [Introduction](#introduction)
- [Components](#components)
- [Usage](#usage)
- [Configuration](#configuration)
- [Customization](#customization)
- [Contributing](#contributing)
- [License](#license)

## Introduction

Monitoring and gathering statistics from a Kubernetes cluster are critical for maintaining cluster health and making informed decisions. This repository provides a comprehensive setup that includes the following components:

- **Prometheus**: Collects metrics from both Kubernetes nodes and the cluster itself using custom scrapers.
- **Grafana**: Visualizes the collected metrics using predefined dashboard templates.
- **Grafana Reporter**: An application for exporting and sharing Grafana dashboards via email.

## Components

- `DockerImage`: Contains Dockerfile for creating a container with the Grafana Reporter tool installed.
- `config.yaml`: Configuration file for Prometheus scrapers.
- `email.txt`: A list of email addresses to which the reporter application will send notifications.
- `grafana.tf`: Terraform configurations for deploying Grafana. Utilizes a renderer container to generate PDFs from Grafana dashboards.
- `renderer-config.json`: Configuration file for the Grafana renderer container.
- `kube_metrics_exporter.tf`: Terraform deployment files for the Kubernetes cluster metrics exporter application.
- `kubernetes_dashboard.json`: Generic Grafana dashboard configuration for Kubernetes cluster metrics.
- `node_dashboard.json`: Generic Grafana dashboard configuration for Kubernetes node metrics.
- `node_metrics_exporter.tf`: Terraform deployment files for the node metrics exporter application.
- `prometheus.tf`: Terraform deployment files for Prometheus, which uses kube metrics exporter and node metrics exporter as data sources.
- `reporter.tf`: Terraform deployment files for the reporting application that utilizes the Docker image and email configurations.

## Usage

To deploy this active monitoring and stat gathering setup on your Kubernetes cluster, follow these steps:

1. Clone this repository to your local machine:
   ```shell
   git clone https://github.com/radeeka/kubernetes-active-monitoring-stack.git
   ```

2. Navigate to the cloned directory:
   ```shell
   cd kubernetes-active-monitoring-stack
   ```

3. Customize the configurations and templates to match your specific Kubernetes environment and monitoring requirements.

4. Deploy the components to your Kubernetes cluster using Terraform:
   ```shell
   terraform init
   terraform apply
   ```

5. Monitor your Kubernetes cluster's metrics and visualize them in Grafana.

6. Utilize the Grafana Reporter application to export and share Grafana dashboards via email.

## Configuration

Please refer to individual configuration files and Terraform deployment files for detailed information on configuring and customizing each component.

## Customization

You can customize and extend this setup to suit your specific monitoring and reporting needs. Modify Grafana dashboards, Prometheus scrapers, and reporting settings as required.

## Contributing

Contributions to enhance and improve this Kubernetes monitoring and stat gathering setup are welcome. If you encounter issues, have suggestions, or want to contribute improvements, please open an issue or submit a pull request following our [contribution guidelines](CONTRIBUTING.md).

## License

This project is licensed under the [MIT License](LICENSE), allowing you to use, modify, and distribute the configurations and resources according to the terms of the license.
