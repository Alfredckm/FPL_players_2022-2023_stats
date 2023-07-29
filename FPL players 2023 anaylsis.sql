Select `Value.first_name`
from fpl_player_clean_data;

Select * 
from fpl_player_position;

#1 
#Take a look in forwards and midfielders attacking stats

Select fstat.`Value.web_name`, fteam.`team_name`, fstat.`Value.minutes`, fstat.`Value.starts`, fstat.`Value.total_points`, fstat.`Value.bonus`, 
fstat.`Value.points_per_game`, fstat.`Value.goals_scored`, fstat.`Value.assists`, fstat.`Value.expected_goals`,
fstat.`Value.expected_assists`, fstat.`Value.expected_goal_involvements`, fstat.`Value.expected_goals_per_90`, fstat.`Value.expected_assists_per_90`
From fpl_player_clean_data fstat
Join fpl_value_team fteam
	On fstat.`Value.team` = fteam.`Value.team`
where fstat.`Value.element_type` = 3 or fstat.`Value.element_type` = 4 
# and fstat.`Value.minutes` > 2000
Order by 7 desc;

#2 
#Take a look in goalkeepers key stats

Select fstat.`Value.web_name`, fteam.`team_name`, fstat.`Value.minutes`, fstat.`Value.starts`, fstat.`Value.total_points`, fstat.`Value.bonus`,
fstat.`Value.points_per_game`, fstat.`Value.clean_sheets`, fstat.`Value.goals_conceded`, fstat.`Value.penalties_saved`,
fstat.`Value.saves`, fstat.`Value.saves_per_90`, fstat.`Value.goals_conceded_per_90`, fstat.`Value.expected_goals_conceded_per_90`
From fpl_player_clean_data fstat
Join fpl_value_team fteam
	On fstat.`Value.team` = fteam.`Value.team`
where fstat.`Value.element_type` = 1 
# and fstat.`Value.minutes` > 2000
Order by 7 desc;

#3 
#Identify top-performing players based on points earned per spent
Select `Value.web_name`, `Value.total_points` / `Value.now_cost`as points_per_spent
From fpl_player_clean_data
#Group by `Value.web_name`
Order by points_per_spent Desc;

Select ps.`Value.web_name`, ps.`Value.points_per_game`, ps.points_per_spent, ps.`Value.now_cost`, ps.`Value.element_type`, ps.`Value.total_points`,
    Rank() Over (Order by ps.`Value.points_per_game` desc) as rank_points_per_match,
    Rank() Over (Order by ps.points_per_spent desc) as rank_points_per_spent
From (
    Select `Value.web_name`, `Value.now_cost`, `Value.minutes`, `Value.points_per_game`, `Value.element_type`, `Value.total_points`, `Value.total_points` / `Value.now_cost`as points_per_spent
	From fpl_player_clean_data
) as ps
where `Value.minutes` > 2000 and `Value.total_points` > 150
Order by 3 desc;

#4 Best eleven with 83m fpl dollars
# 17m is the minimum price you have to pay for 4 bench players, so best eleven would be 100m-17m = 83m
# my formation would be 3-4-3, so there will be 1 gk, 3 defenders, 5 midfielder and 2 strikers

Drop table if exists fpl_best_11;
create table fpl_best_11
(
player_name varchar(20), price double, points_per_spent double, position varchar(20)
);
Insert into fpl_best_11
Select fstat.`Value.web_name`, fstat.`Value.now_cost`, fstat.`Value.total_points` / fstat.`Value.now_cost` as points_per_spent, fpos.`element_type_position`
From fpl_player_clean_data fstat
Join fpl_player_position fpos
	On fstat.`value.element_type` = fpos.`value.element_type`;

Select * 
From fpl_best_11;

Select player_name, price, points_per_spent, position, Rank() Over (Partition by position Order by points_per_spent desc) as price_rank_by_position
From (
  Select player_name, price, points_per_spent, position,
         Rank() Over (Partition by position Order by points_per_spent desc) as points_rank
  From fpl_best_11
) ranked_player
Where points_rank <= 5;

#5 Creating view to store data for later visualization

Drop View if exists fpl_final;
Create View fpl_final as 
Select player_name, price, points_per_spent, position, Rank() Over (Partition by position Order by points_per_spent desc) as price_rank_by_position,
fstat.`Value.minutes`, fstat.`Value.starts`, fstat.`Value.total_points`, fstat.`Value.bonus`, fstat.`Value.points_per_game`, 
fstat.`Value.goals_scored`, fstat.`Value.assists`, fstat.`Value.clean_sheets`, fstat.`Value.goals_conceded`, fstat.`Value.penalties_saved`,
fstat.`Value.saves`, fstat.`Value.saves_per_90`
From fpl_best_11 fb11
Join fpl_player_clean_data fstat
	On fb11.player_name = fstat.`Value.web_name`;
    
Select * 
From fpl_final;

