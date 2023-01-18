from sqlalchemy import Column,String,Integer,Date,ForeignKey
from sqlalchemy.orm import relationship
from base_connect import Base


class Player(Base):
    __tablename__ = "players"    
    id = Column(Integer,primary_key = True)
    name = Column(String(50))
    team_id = Column(Integer,ForeignKey("teams.id"),nullable = True)
    team = relationship("Team",backref= "players")
    age = Column(Integer)
    position = Column(String(50))
    num_kit = Column(Integer)
    nationality = Column(String(50))
    def __init__(self, name,team,age,position,num_kit,nationality):
        self.name = name
        self.team = team
        self.age = age
        self.position = position
        self.num_kit = num_kit
        self.nationality = nationality

    def __repr__(self):
        return f'name: {self.name}, age: {self.age}, position: {self.position}, num_kit: {self.num_kit}, nationality: {self.nationality}, team: {self.team}'