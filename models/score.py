from sqlalchemy import Column,String,Integer,Date,ForeignKey,Boolean
from sqlalchemy.orm import relationship
from base_connect import Base


class Score(Base):
    __tablename__ = "scores"    
    id = Column(Integer,primary_key = True)
    scorer_id = Column(Integer,ForeignKey('players.id'),nullable = False)
    scorer = relationship("Player",foreign_keys=[scorer_id])
    assist_id = Column(Integer,ForeignKey('players.id'))
    assist = relationship("Player",foreign_keys = [assist_id])
    own_goal = Column(Boolean,nullable = False)
    def __init__(self, scorer,assist,own_goal):
        self.scorer = scorer
        self.assist = assist
        self.own_goal = own_goal

    def __repr__(self):
        return f'scorer:{self.scorer}\nassist:{self.assist}\nown_goal:{self.own_goal}'