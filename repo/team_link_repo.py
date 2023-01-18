from sqlalchemy import select
from base_repo import BaseRepo
from models.team_links import TeamLink

class TeamLinkRepo():

    def __init__(self):
        self.baseRepo = BaseRepo()

    def save_team_link(self,team_link):
        return self.baseRepo.save(team_link)

    def save_team_links(self,team_link_array):
        return self.baseRepo.save_all(team_link_array)
    
    def select_all_team_links(self):
        return self.baseRepo.query(select(TeamLink)).all()