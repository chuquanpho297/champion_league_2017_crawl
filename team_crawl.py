import traceback

from team_soup import TeamSoup
from squad_soup import SquadSoup

class TeamCrawl:

    def __init__(self,squad_url='',team_url=''):
        self.squad_url = squad_url
        self.team_url = team_url

    def get_squad_soup(self):
        self.squad_soup = SquadSoup(self.squad_url)
        return self

    def get_team_soup(self):
        self.team_soup = TeamSoup(self.team_url)
        return self

    def get_head_coach(self):
        [start_idx,end_idx] = self.squad_soup._search_many_rows_idx('Manager')
        if(start_idx == 0):
            return None
        return [self.squad_soup.get_info_table()[idx].select('td:nth-of-type(3)')[0].text.strip() for idx in range(start_idx,end_idx)][0]

    def get_coaches(self):
        [start_idx,end_idx] = self.squad_soup._search_many_rows_idx('Ass. Manager')
        if(start_idx == 0):
            return None
        return [self.squad_soup.get_info_table()[idx].select('td:nth-of-type(3)')[0].text.strip() for idx in range(start_idx,end_idx)]

    def get_team_logo(self):
        try: 
            return self.squad_soup.get_side_bar().find('img')['src']
        except:
            print(traceback.format_exc())
            return None
    def get_team_name(self):
        try: 
            return self.squad_soup.get_side_bar().find('div',class_='head').text.strip()
        except:
            print(traceback.format_exc())
            return None
    def get_color_kit(self):
        try:
            return self.team_soup._search_row('Colors').select('td:nth-of-type(2)')[0].text.strip()
        except: 
            print(traceback.format_exc())
            return None