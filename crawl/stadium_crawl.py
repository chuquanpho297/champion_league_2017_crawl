import traceback
from team_soup import TeamSoup
class StadiumCrawl:

    def __init__(self,team_url=''):
        self.team_url = team_url
        
    def get_team_soup(self):
        self.team_soup = TeamSoup(self.team_url)
        return self

    def _get_cell_stadium_name(self):
        row_stadium = self.team_soup._search_row('stadium')
        try:
            cell_name = row_stadium.select('td:nth-of-type(2)')[0]
            return cell_name
        except:
            print(traceback.format_exc())
            return None

    def get_name(self):
        try: 
            return self._get_cell_stadium_name().find('a').text.strip()
        except:
            print(traceback.format_exc())
            return None
    
    def get_capacity(self):
        try:
            return int(self._get_cell_stadium_name().contents[-1].strip().split()[0].replace('.',''))
        except:
            print(traceback.format_exc())
            return None

    def get_address(self):
        address = ''
        row_address = self.team_soup._search_row('Address')
        try:
            address_name = row_address.select('td:nth-of-type(2)')[0].text.strip()
            address += address_name + ' '
        except:
            print(traceback.format_exc())
            address = ''
        row_country = self.team_soup._search_row('Country')
        try: 
            country_name = row_country.select('td:nth-of-type(2)')[0].text.strip()
            address += country_name
        except:
            print(traceback.format_exc())
            address = None
        return address