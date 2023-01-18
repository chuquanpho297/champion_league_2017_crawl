import traceback
from soup import Soup
from crawl_constants import url_web_const
from models.team_links import TeamLink
class TeamLinkCrawl:
    def __init__(self,year):
        self.year = year
        self.content = Soup(url_web_const.team_link_url(year)).get_soup().find(class_ = "content").find(class_ = "box")
    def get_team_link_array(self,limit = None):
        rows  = self.content.find_all('tr',limit = limit)
        team_link_array = []
        for row in rows: 
            cells = row.find_all('td')
            team_name = self._get_team_name(cells)
            info_team_url =  self._get_info_team_url(cells)
            squad_url = self._get_squad_url(cells)
            team_link = TeamLink(team_name=team_name,info_team_url = info_team_url,squad_url = squad_url)
            team_link_array.append(team_link)
        return team_link_array
    
    def _get_team_name(self,cells):
        try:
            return cells[1].text.strip()
        except: 
            print(traceback.format_exc())
            return None
    def _get_info_team_url(self,cells):
        try: 
            return url_web_const.base_url() + cells[3].find('a',href=True)['href'].strip()
        except: 
            print(traceback.format_exc())
            return None

    def _get_squad_url(self,cells):
        try: 
            return url_web_const.base_url() + cells[5].find('a',href=True)['href'].strip()
        except:
            print(traceback.format_exc())
            return None

# print(TeamLinkCrawl().get_team_link_array())
