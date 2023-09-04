# kubernetes_monitoring
Aim of this project is to implement a fully automated monitoring solution for a kubernetes cluster. The terraform scripts contains the workloads need to be provisioned to scrape the metrics for Prometheus. json files contain several grafana dashboards that will make use of these scrapers. The config.yaml is the Prometheus configuration that will tell Prometheus to which data points need to be scraped. 
This setup assumes that you have a Prometheus and Grafana services provisioned already. 

Later the project was extended to implement a statistics related report generator and distributor and those are also incorporated to the repository. 
