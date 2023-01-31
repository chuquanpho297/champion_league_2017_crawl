from sqlalchemy import select,join,insert
from crawl.player_sum_crawl import PlayerSumCrawl
from models.match import Match
from models.match_result import MatchResult
from models.score import Score
from player_crawl import PlayerCrawl
from repo.match_repo import MatchRepo
from repo.match_result_repo import MatchResultRepo
from repo.score_repo import ScoreRepo
from stadium_crawl import StadiumCrawl
from team_crawl import TeamCrawl
from team_link_crawl import TeamLinkCrawl
from models.stadium import Stadium
from repo.base_repo import BaseRepo
from repo.player_repo import PlayerRepo
from repo.stadium_repo import StadiumRepo
from repo.team_link_repo import TeamLinkRepo
from repo.team_repo import TeamRepo
from models.team_links import TeamLink
from models.team import Team
from models.player import Player
from crawl_constants.position_const import positions_team
from helper.list_util import flatten
from matches_crawl import MatchesCrawl
from match_crawl import MatchCrawl

year = 2017
#save team_link of champion league (year-1)-year
'''
team_links = TeamLinkCrawl(year).get_team_link_array()
TeamLinkRepo().save_team_links(team_links)
'''

# Save teams of champion league (year-1)-year
'''
teams = []
teamlinks = TeamLinkRepo().select_all_team_links()
for row in teamlinks:
    info_team_url = row.TeamLink.info_team_url
    squad_url = row.TeamLink.squad_url
    team_crawler = TeamCrawl(squad_url= squad_url,team_url= info_team_url).get_squad_soup().get_team_soup()
    team = Team(
        coach_names=team_crawler.get_coaches(),
        team_logo=team_crawler.get_team_logo(),
        color_kit=team_crawler.get_color_kit(),
        head_coach_name=team_crawler.get_head_coach(),
        team_name=team_crawler.get_team_name()
    )
    teams.append(team)
TeamRepo().save_teams(teams)
'''

#Save stadiums of champion league (year-1)-year 
'''
teams_and_urls = BaseRepo().query(select(Team,TeamLink).join(TeamLink,Team.team_name == TeamLink.team_name))
stadiums = []
for row in teams_and_urls:
    stadium_crawler = StadiumCrawl(row.TeamLink.info_team_url).get_team_soup()
    stadium = Stadium(
    team= row.Team,
    capacity=stadium_crawler.get_capacity(),
    address=stadium_crawler.get_address(),
    name= stadium_crawler.get_name()
    )
    stadiums.append(stadium)
StadiumRepo().save_stadiums(stadiums)
'''

#Save players
'''
teams_and_urls = BaseRepo().query(select(Team,TeamLink).join(TeamLink,Team.team_name == TeamLink.team_name))
positions = positions_team()
for row in teams_and_urls:
    players = []
    squad_url = row.TeamLink.squad_url
    player_crawler = PlayerCrawl(year,squad_url).get_squad_soup()
    player_list = flatten([PlayerCrawl(year,squad_url).get_squad_soup().get_players(position) for position in sorted(positions)])
    for player_map in player_list:
        player = Player(
            age= player_map['age'],
            name= player_map['player_name'],
            nationality=player_map['nationality'],
            num_kit=player_map['number_kit'],
            position=player_map['position'],
            team=row.Team
        )
        players.append(player)
    PlayerRepo().save_players(players)

'''

#Save matches,results,scores

#Save match stadium
'''
for match_info in MatchesCrawl(year).get_match_infos():
    match_crawler = MatchCrawl(match_info)
    match_stadium = match_crawler.get_stadium_match()
    saved_stadiums = StadiumRepo().select_stadium_by_name(match_stadium['stadium_match_name'])
    if saved_stadiums == None:
        stmt = insert(Stadium).values(
            name = match_stadium['stadium_match_name'],
            address= match_stadium['stadium_match_address'],
            capacity= match_stadium['stadium_match_capacity'],
        )
        BaseRepo().insert(stmt)

'''

#Save match
'''

match_infos = MatchesCrawl(year).get_match_infos()
for match_info in match_infos:
    match_crawler = MatchCrawl(match_info)
    match_stadium = match_crawler.get_stadium_match()
    
    match = Match(
        attendance= match_crawler.get_attendance(),
        awayteam=TeamRepo().select_team_by_name(match_crawler.get_team_away_name()),
        hometeam=TeamRepo().select_team_by_name(match_crawler.get_team_home_name()),
        match_date= match_crawler.get_match_date(),
        stadium= StadiumRepo().select_stadium_by_name(match_stadium['stadium_match_name']), 
    )

    result = MatchResult(
        match= match,
        away_result= match_crawler.get_away_result(),
        home_result= match_crawler.get_home_result()
    )

    MatchRepo().save_match(match)
    MatchResultRepo().save_match_result(result)    
    
    scores_info = match_crawler.get_scores_info()
    for score_info in scores_info:
        if score_info['score_name'] == None: 
            continue
        team_scorer = TeamRepo().select_team_by_name(score_info['team_scorer_name'])

        scorer = PlayerRepo().select_player_by_name(score_info['score_name'])
        if scorer == None:
            player_sum_crawler = PlayerSumCrawl(year,score_info['scorer_sum_url'])
            player_sum = player_sum_crawler.get_info()
            stmt = insert(Player).values(
                age= player_sum['age'],
                name= score_info['score_name'],
                nationality= player_sum['nationality'],
                num_kit= player_sum['num_kit'],
                position= player_sum['position'],
                team_id = team_scorer.id
            )
            BaseRepo().insert(stmt)

        if score_info['assist_name'] != None:
            assist= PlayerRepo().select_player_by_name(score_info['assist_name'])
            if assist == None:
                player_sum_crawler = PlayerSumCrawl(year,score_info['assist_sum_url'])
                player_sum = player_sum_crawler.get_info()
                stmt  = insert(Player).values(
                    age= player_sum['age'],
                    name= score_info['assist_name'],
                    nationality= player_sum['nationality'],
                    num_kit= player_sum['num_kit'],
                    position= player_sum['position'],
                    team_id = team_scorer.id
                )
                BaseRepo().insert(stmt)
                
            stmt = insert(Score).values(
                scorer_id= PlayerRepo().select_player_by_name(score_info['score_name']).id,
                assist_id= PlayerRepo().select_player_by_name(score_info['assist_name']).id,
                own_goal= score_info['is_own_goal']
            )
            BaseRepo().insert(stmt)
            # print('assist not none')
        else:
            stmt = insert(Score).values(
                scorer_id = PlayerRepo().select_player_by_name(score_info['score_name']).id,
                assist_id = None,
                own_goal= score_info['is_own_goal']
            )
            # print('assist none')
            BaseRepo().insert(stmt)
        
'''