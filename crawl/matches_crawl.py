import traceback
from crawl.soup import Soup
from crawl_constants.url_web_const import match_link_url,base_url

class MatchesCrawl:

    def __init__(self,year):
        self.info_table = Soup(match_link_url(year)).get_soup().find('div',class_='content').find('table',class_='standard_tabelle')

    def find_info_table(self):
        return self.info_table

    def get_match_infos(self):
            match_infos = []
            rows = self.info_table.find_all('tr')
            match_date = ''
            for row in rows:
                try:
                    info_row = row.find_all('td')
                    if len(info_row) != 0:
                        if info_row[0].text.strip() != '':
                            match_date = info_row[0].text.strip()
                        match_info = {
                            'match_date': match_date,
                            'team_home': info_row[2].text.strip(),
                            'team_away': info_row[4].text.strip(),
                            'match_info_url': base_url() + info_row[5].find('a')['href'].strip()
                        }
                        match_infos.append(match_info)
                except:
                    print(traceback.format_exc())
                    continue
            return match_infos