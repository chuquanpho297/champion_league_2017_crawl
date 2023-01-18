from soup import Soup

class SquadSoup:

    def __init__(self,url):
        self.url = url
        self.soup = Soup(url).get_soup()
    
    def get_info_table(self):
        return self.soup.find('div',class_='content').find('table',class_='standard_tabelle').find_all('tr')
    
    def get_side_bar(self):
        return self.soup.find('div',class_= 'sidebar')

    def get_soup(self):
        return self.soup
    
    def _search_many_rows_idx(self,row_name):
        squad_info_table = self.get_info_table()

        start_idx = end_idx = -1

        for idx,row in enumerate(squad_info_table):
            if start_idx != -1 and row.find('b') != None: 
                end_idx = idx
                break
            if row.find('b') != None and row.find('b').text.strip().find(row_name) == 0:
                start_idx = idx  
        if end_idx == -1: end_idx = len(squad_info_table)
        return [start_idx+1,end_idx]
