from sqlalchemy import Column,String,Integer,Date,ForeignKey, false
from sqlalchemy.orm import relationship,backref
from base_connect import Base


class Stadium(Base):
    __tablename__ = "stadiums"    
    id = Column(Integer, primary_key = True)
    name = Column(String(50))
    team_id = Column(Integer,ForeignKey('teams.id'),nullable=True)
    team = relationship("Team",backref = backref("stadium",uselist = False))
    capacity = Column(Integer)
    address = Column(String)

    def __init__(self, name, team,capacity,address):
        self.name = name
        self.team = team
        self.capacity = capacity
        self.address = address


    def __repr__(self):
        return f'name: {self.name}, team: {self.team}, capacity: {self.capacity}, address: {self.address}'