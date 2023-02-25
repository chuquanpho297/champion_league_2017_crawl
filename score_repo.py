from sqlalchemy import select
from base_repo import BaseRepo
from score import Score
from sqlalchemy.orm import lazyload,joinedload


class ScoreRepo():
    def __init__(self):
        self.baseRepo = BaseRepo()

    def save_score(self, score):
        return self.baseRepo.save(score)

    def save_scores(self, scores):
        return self.baseRepo.save_all(scores)

    # def select_all_scores(self):
    #     return self.baseRepo.get_all(Score,'team',lazy=False)

    # def select_scores_by_name(self, name):
    #     stmt = select(Score).where(Score.name == name).options(joinedload('team'))
    #     return self.baseRepo.query(stmt).all()
