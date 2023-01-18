import traceback
from soup import Soup

class TeamSoup:

    def __init__(self,url):
        self.url = url
        self.soup = Soup(url).get_soup()
    
    def get_info_table(self):
        return self.soup.find('div',class_='content').find('table',class_='standard_tabelle').find_all('tr')
    
    def get_soup(self):
        return self.soup
        
    def _search_row(self,row_name):
        team_info_table = self.get_info_table()
        row = filter(lambda row: row_name in row.find('b').text.strip(),team_info_table)
        try:
            return list(row)[0]
        except:
            print(traceback.format_exc())
            return None
        
    
    
        