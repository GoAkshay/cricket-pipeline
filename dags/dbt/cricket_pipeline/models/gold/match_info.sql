{{
  config(
    target_lag="1 minutes"
  )
}}

with source_match as(
    select *
    from {{ref('silver_match_info')}} s
)

select md5(upper(trim(file_name))) as match_id, MATCH_TYPE, GENDER, SEASON, CITY, VENUE, DATE
,t1.team_id as TEAM1_id
,t2.team_id as TEAM2_id
,tw.team_id as TOSS_WINNER_id
,TOSS_DECISION
,mw.team_id as MATCH_WINNER_id
,MARGIN, EVENT_NAME, EVENT_TYPE
,p.player_id as POM_id
,s.file_name
,s.insert_timestamp
from source_match s
join {{ ref('teams') }} t1
on t1.team_name = s.team1
join {{ ref('teams') }} t2
on t2.team_name = s.team2
join {{ ref('teams') }} tw
on tw.team_name = s.toss_winner
join {{ ref('teams') }} mw
on mw.team_name = s.match_winner
join (select distinct player_name,player_id from {{ ref('players') }}) p
on p.player_name = s.pom