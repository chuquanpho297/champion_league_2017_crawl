from sqlalchemy import select
from base_repo import BaseRepo
from models.team import Team

class TeamRepo():
    def __init__(self):
        self.baseRepo = BaseRepo()
    
    def save_team(self,team):
        return self.baseRepo.save(team)
    
    def save_teams(self,teams):
        return self.baseRepo.save_all(teams)
    
    def select_team_by_name(self, name):
        stmt = select(Team).where(Team.team_name == name)
        datas = self.baseRepo.query(stmt).all()
        if len(datas) == 0: return None 
        return datas[0].Team

    def select_all_teams(self):
        return self.baseRepo.query(select(Team)).all()
