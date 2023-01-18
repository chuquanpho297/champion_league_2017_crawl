from sqlalchemy import select
from sqlalchemy.orm import joinedload
from base_repo import BaseRepo
from models.match_result import MatchResult
from models.player import Player

class MatchResultRepo():
    def __init__(self):
        self.baseRepo = BaseRepo()
    
    def save_match_result(self,match_result):
        return self.baseRepo.save(match_result)
    
    def save_match_results(self,match_results):
        return self.baseRepo.save_all(match_results)
    
    # def select_all_match_results(self):
    #     return self.baseRepo.get_all(MatchResult,'match',lazy=False)

    # def select_match_result_by_name(self, name):
    #     stmt = select(MatchResult).where(MatchResult.name == name).options(joinedload('team'))
    #     return self.baseRepo.query(stmt).all()[0].MatchResult

