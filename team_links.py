from sqlalchemy import ARRAY, Column,String,Integer
from base_connect import Base


class TeamLink(Base):
    __tablename__ = "team_links"
    id = Column(Integer,primary_key = True)
    team_name = Column(String)
    info_team_url = Column(String)
    squad_url = Column(String)
    def __init__(self, team_name, info_team_url,squad_url):
        self.team_name = team_name
        self.info_team_url = info_team_url
        self.squad_url = squad_url

    def __repr__(self):
        return f'team_name: {self.team_name}, info_team_url: {self.info_team_url}, squad_url: {self.squad_url}'