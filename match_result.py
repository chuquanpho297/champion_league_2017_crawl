from sqlalchemy import Column,String,Integer,Date,ForeignKey
from sqlalchemy.orm import relationship,backref
from base_connect import Base


class MatchResult(Base):
    __tablename__ = "match_results"
    id = Column(Integer,primary_key = True)
    match_id = Column(Integer,ForeignKey("matches.id"),nullable = False)    
    match = relationship("Match",backref = backref("match_result",uselist = False))
    home_result = Column(Integer,nullable = False)
    away_result = Column(Integer,nullable = False)
    def __init__(self, match, home_result,away_result):
        self.match = match
        self.home_result = home_result
        self.away_result = away_result

    def __repr__(self):
        return f'match: {self.match}\nhome_result: {self.home_result}\naway_result: {self.away_result}'