from soup import Soup
import traceback
from date_util import get_year
class PlayerSumCrawl:

    def __init__(self,year,player_sum_url):
        self.soup = Soup(player_sum_url).get_soup()
        self.row_infos = self.soup.find('div',class_='sidebar').find('table').find_all('tr')
        self.year = year
    
    def get_info(self):

        return {
            'age': self.find_age(),
            'nationality': self.find_nationality(),
            'position': self.find_position(),
            'num_kit': self.find_num_kit()
        }
    
    def find_row(self,attr):
        try:
            for row_info in self.row_infos:
                if attr in row_info.select('td:nth-of-type(1)')[0].text.strip():
                    return row_info
        except:
            print(traceback.format_exc())
            return None

    def find_age(self):
        try:
            row = self.find_row('Born')
            str_born = row.select('td:nth-of-type(2)')[0].text.strip()
            return self.year - int(get_year(str_born))
        except:
            print(traceback.format_exc())
            return None

    def find_nationality(self):
        try: 
            row = self.find_row('Nationality')
            return row.select('td:nth-of-type(2)')[0].find('span').text.strip()
        except:
            print(traceback.format_exc())
            return None

    def find_position(self):
        try:
            row = self.find_row('Position')
            return row.select('td:nth-of-type(2)')[0].contents[0].strip()
        except:
            print(traceback.format_exc())
            return None

    def find_num_kit(self):
        try: 
            return int(self.soup.find('div',class_='content')\
            .find('div',class_='box')\
            .find('div',class_='data')\
            .find('table')\
            .find('tr')\
            .select('td:nth-of-type(3)')[0].text.strip().split('#')[-1])
        except:
            print(traceback.format_exc())
            return None

