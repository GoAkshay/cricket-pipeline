{{
  config(
    target_lag="downstream"
  )
}}

with team_source as(
    select *
    from {{ ref('silver_teams') }} s
)

select md5(upper(trim(team_name))) as team_id,* 
from team_source