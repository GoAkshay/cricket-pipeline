{{
  config(
    unique_key = ['player_name','team_type'],
    incremental_strategy = 'merge'
    )
}}

with player_source as
(
    select * from {{ source('raw', 'raw_cricket') }} s
    {% if is_incremental() %}
      where s.insert_timestamp > coalesce((select max(insert_timestamp) from {{ this }}), '1900-01-01')
    {% endif %}
),

flattened_data as (
select pl.value::string as player_name,p.key::string team_name, data:info.team_type::string as team_type,d.insert_timestamp
from player_source d,
lateral flatten(data:info.players) p ,
lateral flatten(p.value)pl
)
select 
    player_name,
    team_name,
    team_type,
    insert_timestamp
from flattened_data
qualify row_number() over (
    partition by player_name, team_type 
    order by insert_timestamp desc
) = 1