import traceback
from squad_soup import SquadSoup
from helper.date_util import *

class PlayerCrawl:

    def __init__(self,squad_url=''):
        self.squad_url = squad_url 
    
    def get_squad_soup(self):
        self.squad_soup = SquadSoup(self.squad_url)
        return self
    
    def get_players(self,position):
        [startIdx,endIdx] = self.squad_soup._search_many_rows_idx(position)
        if startIdx == 0:
            return None
        players = []
        for idx in range(startIdx,endIdx):
            player = self.get_info(idx)
            player.update({'position': position})
            players.append(player)
        return players

    def get_info(self,idx):
        return {
            'age' : self.get_age(idx),
            'number_kit' : self.get_number_kit(idx),
            'nationality': self.get_nationality(idx),
            'player_name': self.get_player_name(idx),
        }
        
    def get_age(self,idx):
        try:
            birthday = self.squad_soup.get_info_table()[idx].select('td:nth-of-type(6)')[0].text.strip()
            year = get_year(birthday)
            return 2017 - int(year)
        except: 
            print(traceback.format_exc())
            return None
    def get_number_kit(self,idx):
        try:
            return int(self.squad_soup.get_info_table()[idx].select('td:nth-of-type(2)')[0].text.strip())
        except: 
            print(traceback.format_exc())
            return None

    def get_nationality(self,idx):
        try:
            return self.squad_soup.get_info_table()[idx].select('td:nth-of-type(5)')[0].text.strip()
        except: 
            print(traceback.format_exc())
            return None
    
    def get_player_name(self,idx):
        try:
            return self.squad_soup.get_info_table()[idx].select('td:nth-of-type(3)')[0].text.strip()
        except: 
            print(traceback.format_exc())
            return None
