from sqlalchemy import Column, String, Integer, Date, ForeignKey
from sqlalchemy.orm import relationship
from base_connect import Base


class Match(Base):
    __tablename__ = "matches"
    id = Column(Integer, primary_key=True)
    attendance = Column(Integer)
    stadium_id = Column(Integer, ForeignKey('stadiums.id'), nullable=False)
    stadium = relationship("Stadium", backref="stadium")
    awayteam_id = Column(Integer, ForeignKey('teams.id'), nullable=False)
    awayteam = relationship("Team", foreign_keys=[awayteam_id])
    hometeam_id = Column(Integer, ForeignKey('teams.id'), nullable=False)
    hometeam = relationship("Team", foreign_keys=[hometeam_id])
    match_date = Column(Date)

    def __init__(self, attendance, stadium, awayteam, hometeam, match_date):
        self.attendance = attendance
        self.stadium = stadium
        self.awayteam = awayteam
        self.hometeam = hometeam
        self.match_date = match_date

    def __repr__(self):
        return f'attendance: {self.attendance},\nstadium: {self.stadium},\nawayteam: {self.awayteam},\nhometeam: {self.hometeam},\nmatch_date: {self.match_date}'