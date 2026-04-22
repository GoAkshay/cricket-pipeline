FROM astrocrpublic.azurecr.io/runtime:3.2

# Create the virtual environment specifically for dbt
RUN python -m venv /usr/local/airflow/dbt_venv && \
    /usr/local/airflow/dbt_venv/bin/pip install --no-cache-dir dbt-snowflake