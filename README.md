<div align="center">
<h1>🏏 Cricket Data Pipeline</h1>
  
#### *End-to-end pipeline | dbt + Snowflake + AWS S3 + Apache Airflow | Medallion Architecture |

![AWS S3](https://img.shields.io/badge/AWS_S3-Data_Lake-orange?style=for-the-badge&logo=amazon-aws&logoColor=white)
![dbt](https://img.shields.io/badge/dbt-1.11.7-orange?style=for-the-badge&logo=getdbt&logoColor=white)
![Snowflake](https://img.shields.io/badge/Snowflake-Cloud_DW-00BFFF?style=for-the-badge&logo=snowflake&logoColor=white)
![Apache Airflow](https://img.shields.io/badge/Apache_Airflow-Orchestration-brightgreen?style=for-the-badge&logo=apache-airflow&logoColor=white)
![Docker](https://img.shields.io/badge/Docker-Containerization-2496ED?style=for-the-badge&logo=docker&logoColor=white)

</div>

## Overview

An ELT pipeline implementing a strict **Medallion Architecture (Raw → Silver → Gold)** for processing and analyzing cricket match data. The pipeline leverages **Snowpipe** for continuous, automated ingestion of raw JSON files from AWS S3 into a single Snowflake source table. Once the data lands, an asynchronous Airflow SQL Sensor detects the new records and triggers layered `dbt` transformations. A unified raw model parses and flattens the complex JSON payload into structured relational tables (Silver), before aggregating the metrics into final analytical datasets (Gold). The entire workflow is built for production efficiency and is fully orchestrated by Apache Airflow 3.2 and Astronomer Cosmos within a Dockerized environment.

| Metric | Value |
|--------|-------|
| Ingestion Engine | AWS S3 (JSON) → Snowflake via Snowpipe |
| dbt Models | 8 (1 Raw, 3 Silver, 3 Gold, 1 Snapshot) |
| Data Quality Tests | 7 (6 generic + 1 singular) |
| Orchestration | Airflow 3.0 (Async SQL Sensor + Cosmos dbt Task Group) |
| Optimization | Near-instant DAG parsing via `LoadMode.DBT_MANIFEST` |

---
