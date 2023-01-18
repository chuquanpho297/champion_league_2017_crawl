from sqlalchemy import select
from base_repo import BaseRepo
from models.stadium import Stadium
from sqlalchemy.orm import lazyload,joinedload


class StadiumRepo():
    def __init__(self):
        self.baseRepo = BaseRepo()

    def save_stadium(self, stadium):
        return self.baseRepo.save(stadium)

    def save_stadiums(self, stadiums):
        return self.baseRepo.save_all(stadiums)

    def select_all_stadiums(self):
        return self.baseRepo.get_all(Stadium,'team',lazy=False)

    def select_stadium_by_name(self, name):
        stmt = select(Stadium).where(Stadium.name == name).options(joinedload('team'))
        stadiums = self.baseRepo.query(stmt).all()
        if len(stadiums) == 0: return None
        return stadiums[0].Stadium
