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
## Data Source

The pipeline utilizes open-source match data provided by **[Cricsheet](https://cricsheet.org/)**. 

* **Source Format:** Semi-structured JSON
* **Coverage:** T20, ODI, and Test matches (International and Domestic leagues)
* **Link:** [Cricsheet Downloads](https://cricsheet.org/downloads/)

This project specifically processes the JSON-formatted ball-by-ball data, which allows for complex nested-field parsing and flattening within the Snowflake and dbt layers.

---
## Architecture
<img width="1114" height="583" alt="Cricket_pipeline" src="https://github.com/user-attachments/assets/2a728ba9-e5f3-47ad-b735-db5cdb1fe241" />

---
## Tech Stack

| Layer | Technology |
| :--- | :--- |
| **Storage (Data Lake)** | AWS S3 (Semi-structured JSON) |
| **Ingestion** | Snowpipe (Event-driven automated loading) |
| **Warehouse** | Snowflake (Cloud Data Platform) |
| **Transformation** | dbt Core (Medallion Architecture) |
| **Orchestration** | Apache Airflow 3.2 (using `airflow.sdk`) |
| **Integration** | Astronomer Cosmos 1.14.0 (dbt-on-Airflow) |
| **Containerization** | Docker + Astro CLI |
| **Security & IAM** | AWS IAM Roles & Snowflake RBAC |
| **Languages** | SQL, Jinja, Python, YAML |

---
### dbt Lineage Graph in Airflow UI
<img width="1065" height="621" alt="cricket_cosmos_pipeline-graph" src="https://github.com/user-attachments/assets/3b43d6cc-c481-47ba-af44-2a8c77749142" />

---
### Airflow DAG Run
<img width="1916" height="902" alt="image" src="https://github.com/user-attachments/assets/ae62862a-5576-4efa-8154-fd265d1cb51f" />

---

### Project Structure
```
cricket-pipeline/
├── dags/
│   ├── cricket_pipeline.py         # Main DAG using airflow.sdk & Cosmos
│   └── dbt/
│       └── cricket_pipeline/       # The dbt transformation project
│           ├── models/
│           │   ├── raw/            # 1 model: Unpacks S3 JSON payload
│           │   ├── silver/         # 3 models: Relational staging & cleaning
│           │   └── gold/           # 3 models: Business-ready analytical marts
│           ├── snapshots/          # 1 snapshot: Tracking SCD Type 2 changes
│           ├── tests/              # 7 data quality tests (6 generic + 1 singular)
│           ├── target/             # Contains manifest.json for optimized parsing
│           ├── dbt_project.yml     # dbt project configuration
│           └── profiles.yml        # Snowflake connection configuration
├── .gitignore                      # Ensuring no dbt_venv or target/ is pushed
├── Dockerfile                      # Custom image build with dbt-snowflake
├── README.md                       # Project documentation
└── requirements.txt                # Project dependencies (Cosmos 1.14.0, etc.)
```
---

### Setup
**Prerequisites**: Docker Desktop, Astro CLI,Snowflake account, AWS S3 bucket

```bash
# 1. Clone the repository
git clone https://github.com/GoAkshay/cricket-pipeline.git
cd cricket-pipeline

# 2. Configure Environment Variables
# Create a .env file with your Snowflake and AWS credentials
cp .env.example .env 

# 3. Start the Airflow Environment
# This spins up the Webserver, Scheduler, and Postgres DB via Docker
astro dev start

# 4. Access the Airflow UI
# URL: http://localhost:8080 (Login: admin/admin)
# 1. Add your 'snowflake_default' connection in Admin -> Connections
# 2. Unpause the 'cricket_cosmos_pipeline' DAG to begin the run
```
---

<div align="center">

### ✨ From Raw JSON to Pure Gold 🏅

Found this architecture useful? Give it a **star** and let's keep the data flowing!

***Built with precision & ❤️ by [Akshay Gole](https://www.linkedin.com/in/akshay-g-842ab621a/)***
