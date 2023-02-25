from sqlalchemy import select
from sqlalchemy.orm import joinedload
from base_repo import BaseRepo

class MatchRepo():
    def __init__(self):
        self.baseRepo = BaseRepo()
    
    def save_match(self,match):
        return self.baseRepo.save(match)
    
    def save_matches(self,matches):
        return self.baseRepo.save_all(matches)
    
    # def select_all_matches(self):
    #     return self.baseRepo.get_all(Match,'team',lazy=False)

    # def select_match_by_name(self, name):
    #     stmt = select(Player).where(Player.name == name).options(joinedload('team'))
    #     return self.baseRepo.query(stmt).all()[0].Player

