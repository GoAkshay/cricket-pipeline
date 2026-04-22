{{
  config(
    incremental_strategy = 'append'
    )
}}

with team_source as
(
    select * from {{ source('raw', 'raw_cricket') }} s
    {% if is_incremental() %}
      where s.insert_timestamp > coalesce((select max(insert_timestamp) from {{ this }}), '1900-01-01')
    {% endif %}
)

select t.value::string as team_name, d.data:info.team_type::string as team_type, max(insert_timestamp) as insert_timestamp
from team_source d,
lateral flatten(data:info.teams) t
{% if is_incremental() %}
    where t.value::string not in (select team_name from {{ this }})
{% endif %}
group by all