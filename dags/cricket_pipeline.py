from airflow.sdk import DAG
from datetime import datetime, timedelta
# The correct import!
from airflow.providers.common.sql.sensors.sql import SqlSensor
from cosmos import DbtTaskGroup, ProjectConfig, ProfileConfig, ExecutionConfig, RenderConfig
from cosmos.profiles import SnowflakeUserPasswordProfileMapping
from cosmos.constants import LoadMode, InvocationMode

DBT_PROJECT_PATH = "/usr/local/airflow/dags/dbt/cricket_pipeline"

profile_config = ProfileConfig(
    profile_name="default",
    target_name="prod",
    profile_mapping=SnowflakeUserPasswordProfileMapping(
        conn_id="snowflake_default",
        profile_args={"database": "CRICKET", "schema": "STG"}
    )
)

default_args = {
    'owner': 'data_engineer',
    'retries': 1,
    'retry_delay': timedelta(minutes=2),
}

with DAG(
    dag_id='cricket_cosmos_pipeline',
    default_args=default_args,
    start_date=datetime(2026, 3, 5),
    schedule='30 0 * * *',
    catchup=False,
    max_active_runs=1 
) as dag:

    # 1. THE ASYNC SENSOR: Uses the standard SqlSensor with deferrable=True
    wait_for_snowpipe_data = SqlSensor(
        task_id='wait_for_new_cricket_data',
        conn_id='snowflake_default', # Note: It is conn_id here, not snowflake_conn_id
        sql="""
EXECUTE IMMEDIATE $$
            BEGIN
                IF (EXISTS (
                    SELECT 1 FROM CRICKET.INFORMATION_SCHEMA.TABLES 
                    WHERE TABLE_SCHEMA = 'GOLD' AND TABLE_NAME = 'MATCH_INFO'
                )) THEN
                    IF ((SELECT MAX(insert_timestamp) FROM CRICKET_DEV.RAW.RAW_CRICKET) > 
                        (SELECT MAX(insert_timestamp) FROM CRICKET.GOLD.MATCH_INFO)) THEN
                        RETURN 1;
                    ELSE
                        RETURN 0;
                    END IF;
                ELSE
                    RETURN 1; -- Trigger dbt if table is missing
                END IF;
            END;
            $$; """,
        poke_interval=300, # 5 minutes
        timeout=60 * 60 * 2, # 24 hours
        mode='reschedule',
        soft_fail=True # Fails gracefully without red alarms if no data arrives
    )

    # 2. THE TRANSFORM: Execute the incremental dbt models
    dbt_models_group = DbtTaskGroup(
        group_id="cricket_dbt_models",
        project_config=ProjectConfig(DBT_PROJECT_PATH),
        profile_config=profile_config,
        execution_config=ExecutionConfig(
            dbt_executable_path="/usr/local/airflow/dbt_venv/bin/dbt",
        ),
        operator_args={
		"install_deps": True,
		"full_refresh": "{{ dag_run.conf.get('full_refresh', False) }}",
	},
        default_args={"command_name": "build"},
        render_config=RenderConfig(load_method=LoadMode.DBT_LS)
    )

    wait_for_snowpipe_data >> dbt_models_group