from crawl.match_crawl import MatchCrawl
from crawl.matches_crawl import MatchesCrawl
from crawl.player_sum_crawl import PlayerSumCrawl
from repo.base_repo import BaseRepo
from repo.team_repo import TeamRepo

# url = 'https://www.worldfootball.net/player_summary/manolo-gabbiadini/'
# crawler = PlayerSumCrawl(2017,url)

# print(type(TeamRepo().select_team_by_name('PFC Ludogorets Razgrad')))
year = 2017
match_infos = MatchesCrawl(year).get_match_infos()
match_crawler = MatchCrawl(match_infos[9])
scores_info = match_crawler.get_scores_info()
print(scores_info)
