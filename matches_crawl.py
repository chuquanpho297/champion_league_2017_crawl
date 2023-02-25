import traceback
from soup import Soup
from url_web_const import match_link_url,base_url

class MatchesCrawl:

    def __init__(self,year):
        self.info_table = Soup(match_link_url(year)).get_soup().find('div',class_='content').find('table',class_='standard_tabelle')

    def find_info_table(self):
        return self.info_table

    def get_match_infos(self):
            match_infos = []
            rows = self.info_table.find_all('tr')
            match_date = ''

            round = 0
            group = None

            idx = 0

            for row in rows:
                try:
                    info_row = row.find_all('td')

                    if len(info_row) != 0:
                        if info_row[0].text.strip() != '':
                            match_date = info_row[0].text.strip()
                        
                        if group is not None:
                            if idx == 0 :
                                round += 1
                            idx = idx + 1 if idx == 0 else 0

                        match_info = {
                            'match_date': match_date,
                            'team_home': info_row[2].text.strip(),
                            'team_away': info_row[4].text.strip(),
                            'match_info_url': base_url() + info_row[5].find('a')['href'].strip(),
                            'group' : group,
                            'round' : round
                        }

                        match_infos.append(match_info)
                    else:
                        head_text = row.text.strip()
                        if head_text.startswith('Group'):
                            group = head_text.split()[1]
                            round = 0
                        else:
                            if head_text.startswith('Round of 16'):
                                round = 7
                            elif head_text.startswith('Quarter-finals'):
                                round = 8
                            elif head_text.startswith('Semi-finals'):
                                round = 9
                            elif head_text.startswith('Final'):
                                round = 10
                            group = None
                except:
                    print(traceback.format_exc())
                    continue
            return match_infos