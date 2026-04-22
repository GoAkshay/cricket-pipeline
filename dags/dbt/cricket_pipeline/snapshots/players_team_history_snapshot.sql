{% snapshot players_team_history_snapshot %}

{{
    config(
      target_schema='snapshots',
      unique_key='snapshot_key', 
      strategy='check',
      check_cols=['team_name'],
    )
}}

select 
    md5(upper(trim(player_name)) || '_' || upper(trim(team_type))) as snapshot_key,
    md5(upper(trim(player_name))) as player_id,
    player_name,
    team_name,
    team_type,
    insert_timestamp
from {{ ref('silver_players') }}

{% endsnapshot %}