def base_url():
    return "https://www.worldfootball.net"
def team_link_url(year):
    return f'{base_url()}/players/champions-league-{year-1}-{year}/'
def match_link_url(year):
    return f'{base_url()}/all_matches/champions-league-{year-1}-{year}/'
