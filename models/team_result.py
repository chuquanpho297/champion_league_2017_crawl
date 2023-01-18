from sqlalchemy import Column,Integer,ForeignKey,Boolean
from sqlalchemy.orm import relationship,backref
from base_connect import Base


class TeamResult(Base):
    __tablename__ = "team_results"    
    id = Column(Integer,primary_key = True)
    team_id = Column(Integer,ForeignKey("teams.id"),nullable = False)
    team = relationship("Team",backref = backref("team_result",uselist = False))
    win_match = Column(Integer)
    draw_match = Column(Integer)
    lost_match = Column(Integer)
    goal_scored = Column(Integer)
    goal_against = Column(Integer)
    def __init__(self, team,win_match,draw_match,lost_match,goal_scored,goal_against):
        self.team = team
        self.win_match = win_match
        self.draw_match = draw_match
        self.lost_match = lost_match
        self.goal_scored = goal_scored
        self.goal_against = goal_against