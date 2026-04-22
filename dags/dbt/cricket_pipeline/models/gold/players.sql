{{
  config(
    target_lag="downstream"
  )
}}

with source_player as(
    select *
    from {{ ref('silver_players') }} s
)

select md5(upper(trim(player_name))) as player_id,player_name, array_agg(distinct t.team_id) as team_ids, max(p.insert_timestamp) as insert_timestamp
from source_player p
join {{ref('teams')}} t
on p.team_name = t.team_name
group by all