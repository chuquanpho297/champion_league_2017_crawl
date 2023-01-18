import datetime
import traceback
from crawl.soup import Soup
from helper.date_util import get_date
from url_web_const import base_url


class MatchCrawl:

    def __init__(self, info_row):
        self.info_row = info_row
        self.table_info = Soup(self.info_row['match_info_url']).get_soup().find('div', class_='content').find(
            'div', class_='box').find('div', class_='data').findChildren('table', recursive=False)

    def get_team_home_name(self):
        try:
            return self.info_row['team_home']
        except:
            print(traceback.format_exc())
            return None

    def get_team_away_name(self):
        try:
            return self.info_row['team_away']
        except:
            print(traceback.format_exc())
            return None

    def get_match_date(self):
        [day, month, year] = get_date(self.info_row['match_date'])
        return datetime.date(day=day, month=month, year=year)

    def get_stadium_table_rows(self):
        return self.table_info[-1].find_all('tr')

    def get_attendance(self):
        try:
            for row in self.get_stadium_table_rows():
                if (row.select('td:nth-of-type(2)')[0].find('img')['title'] == 'Attendance'):
                    return int(row.select('td:nth-of-type(3)')[0].text.strip().replace('.', ''))
        except:
            print(traceback.format_exc())
            return None

    def get_stadium_match(self):
        try:
            stadium_match_url = ''
            for row in self.get_stadium_table_rows():
                if (row.select('td:nth-of-type(2)')[0].find('img')['title'] == 'stadium'):
                    stadium_match_url = base_url(
                    ) + row.select('td:nth-of-type(3)')[0].find('a')['href'].strip()
                    break
            stadium_match_soup = Soup(stadium_match_url).get_soup()
            stadium_match_table_rows = stadium_match_soup.find(
                'div', class_='sidebar').find('table').find_all('tr')
            return {
                'stadium_match_name': stadium_match_soup.find('div', class_='sidebar').find('h2').text.strip(),
                'stadium_match_capacity': self.find_stadium_match_capacity(stadium_match_table_rows),
                'stadium_match_address': self.find_stadium_match_address(stadium_match_table_rows),
                'stadium_match_team_name': self.find_stadium_match_team_names(stadium_match_table_rows)
            }
        except Exception:
            print(traceback.format_exc())
            return None

    def find_stadium_match_attr(self, stadium_match_table_rows, attr):
        # for row in stadium_match_table_rows:
        # print(row.select('td:nth-of-type(1)')[0].text.strip())
        row = filter(lambda row: attr in row.select(
            'td:nth-of-type(1)')[0].text.strip(), stadium_match_table_rows)
        return list(row)[0]

    def find_stadium_match_capacity(self, stadium_match_table_rows):
        try:
            return int(self.find_stadium_match_attr(stadium_match_table_rows, 'Capacity').select('td:nth-of-type(2)')[0].text.strip().replace('.', ''))
        except Exception:
            print(traceback.format_exc())
            return None

    def find_stadium_match_address(self, stadium_match_table_rows):
        address = ''
        try:
            city_name = self.find_stadium_match_attr(
                stadium_match_table_rows, 'City').select('td:nth-of-type(2)')[0].text.strip()
            address += city_name + ' '
        except Exception:
            print(traceback.format_exc())
            address = ''

        try:
            country_name = self.find_stadium_match_attr(
                stadium_match_table_rows, 'Country').select('td:nth-of-type(2)')[0].text.strip()
            address += country_name
        except Exception:
            print(traceback.format_exc())
            return None
        return address

    def find_stadium_match_team_names(self, stadium_match_table_rows):
        try:
            teams = []
            for row in stadium_match_table_rows:
                attr = row.select('td:nth-of-type(1)')[0].text.strip()
                if len(teams) > 0 and attr == '' or 'Teams' in attr:
                    teams.append(row.select('td:nth-of-type(3)')
                                 [0].text.strip())
                elif len(teams) > 0:
                    break
            return teams
        except Exception:
            print(traceback.format_exc())
            return None

    def get_home_result(self):
        try:
            return int(self.table_info[0].select('tr:nth-of-type(2)')[0].select('td:nth-of-type(2)')[0].select('div:nth-of-type(1)')[0].text.strip().split(':')[0])
        except:
            print(traceback.format_exc())
            return None

    def get_away_result(self):
        try:
            return int(self.table_info[0].select('tr:nth-of-type(2)')[0].select('td:nth-of-type(2)')[0].select('div:nth-of-type(1)')[0].text.strip().split(':')[1].split(' ')[0])
        except:
            print(traceback.format_exc())
            return None

    def get_scores_info(self):
        try:
            goal_table_rows = self.table_info[1].find_all('tr')
            if goal_table_rows[1].find('b').text.strip() == 'none':
                return []

            scores = []

            team_goal = {
                'team_home': 0,
                'team_away': 0
            }
            for i in range(1, len(goal_table_rows)):
                row = goal_table_rows[i]
                team_goal_ren = self.find_team_goal_ren(row)
                is_own_goal = self.is_own_goal(row)

                team_scorer = ''
                if team_goal_ren['team_home'] > team_goal['team_home'] :
                    if is_own_goal == True:
                        team_scorer = self.info_row['team_away']
                    else:
                        team_scorer = self.info_row['team_home']
                else:
                    team_scorer = self.info_row['team_away']

                score = {
                    'score_name': self.find_score_name(row),
                    'assist_name': self.find_assist_name(row),
                    'is_own_goal': is_own_goal,
                    'scorer_sum_url': self.find_score_sum_url(row),
                    'assist_sum_url': self.find_assist_sum_url(row),
                    'team_scorer_name': team_scorer
                }

                scores.append(score)

                team_goal = team_goal_ren

            return scores
        except:
            print(traceback.format_exc())
            return None

    def find_team_goal_ren(self, row):
        try:
            ren_res = row.select(
                'td:nth-of-type(1)')[0].text.strip().split(':')
            return {
                'team_home': int(ren_res[0].strip()),
                'team_away': int(ren_res[0].strip())
            }
        except:
            print(traceback.format_exc())
            return None

    def find_score_name(self, row):
        try:
            return row.select('td:nth-of-type(2)')[0].select('a:nth-of-type(1)')[0].text.strip()
        except:
            print(traceback.format_exc())
            return None

    def find_assist_name(self, row):
        try:
            return row.select('td:nth-of-type(2)')[0].select('a:nth-of-type(2)')[0].text.strip()
        except:
            print(traceback.format_exc())
            return None

    def is_own_goal(self, row):
        try:
            is_own_goal = row.select(
                'td:nth-of-type(2)')[0].contents[2].split('/')[-1].strip()
            return True if 'own goal' in is_own_goal else False
        except:
            print(traceback.format_exc())
            return None

    def find_score_sum_url(self, row):
        try:
            return base_url() + row.select('td:nth-of-type(2)')[0].select('a:nth-of-type(1)')[0]['href'].strip()
        except:
            print(traceback.format_exc())
            return None

    def find_assist_sum_url(self, row):
        try:
            return base_url() + row.select('td:nth-of-type(2)')[0].select('a:nth-of-type(2)')[0]['href'].strip()
        except:
            print(traceback.format_exc())
            return None
