{{
  config(
    incremental_strategy = 'append'
    )
}}

with source_match as(
    select *
    from {{ source('raw', 'raw_cricket') }} s
    {% if is_incremental() %}
      where s.insert_timestamp > coalesce((select max(insert_timestamp) from {{ this }}), '1900-01-01')
    {% endif %}
)

select data:info.match_type::string as match_type,
data:info.gender::string as gender,
data:info.season::string as season,
data:info.city::string as city,
data:info.venue::string as venue,
data:info.dates[0]::date as date,
data:info.teams[0]::string as team1,
data:info.teams[1]::string as team2,
data:info.toss.winner::string as toss_winner,
data:info.toss.decision::string as toss_decision,
data:info.outcome.winner::string as match_winner,
mar.value::int || ' ' || mar.key::string as margin,
data:info.event.name::string as event_name,
data:info.team_type::string as event_type,
data:info.player_of_match[0]::string as pom,
file_name,
insert_timestamp
from source_match,
lateral flatten(data:info.outcome.by) mar
{% if is_incremental() %}
  where file_name not in (select file_name from {{this}})
{% endif %}