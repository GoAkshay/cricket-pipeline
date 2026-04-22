select player_name, team_name
from {{ref('silver_players')}}
group by player_name, team_name
having count(*)>1