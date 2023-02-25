from sqlalchemy import select
from sqlalchemy.orm import joinedload
from base_repo import BaseRepo
from player import Player

class PlayerRepo():
    def __init__(self):
        self.baseRepo = BaseRepo()
    
    def save_player(self,player):
        return self.baseRepo.save(player)
    
    def save_players(self,players):
        return self.baseRepo.save_all(players)
    
    def select_all_players(self):
        return self.baseRepo.get_all(Player,'team',lazy=False)

    def select_player_by_name(self, name):
        stmt = select(Player).where(Player.name == name).options(joinedload(Player.team))
        players = self.baseRepo.query(stmt).all()
        if len(players) == 0: return None
        return players[0].Player

