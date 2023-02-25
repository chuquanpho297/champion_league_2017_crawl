from sqlalchemy import Column, String, Integer, Date, ForeignKey
from sqlalchemy.orm import relationship
from base_connect import Base


class Match(Base):
    __tablename__ = "matches"
    __table_args__ = {'extend_existing': True}  # Add this attribute to extend the existing table
    id = Column(Integer, primary_key=True)
    attendance = Column(Integer)
    stadium_id = Column(Integer, ForeignKey('stadiums.id'), nullable=False)
    stadium = relationship("Stadium", backref="stadium")
    awayteam_id = Column(Integer, ForeignKey('teams.id'), nullable=False)
    awayteam = relationship("Team", foreign_keys=[awayteam_id])
    hometeam_id = Column(Integer, ForeignKey('teams.id'), nullable=False)
    hometeam = relationship("Team", foreign_keys=[hometeam_id])
    match_date = Column(Date)
    group = Column(String(1))
    round = Column(Integer)
    def __init__(self, attendance, stadium, awayteam, hometeam, match_date,group,round):
        self.attendance = attendance
        self.stadium = stadium
        self.awayteam = awayteam
        self.hometeam = hometeam
        self.match_date = match_date
        self.group = group
        self.round = round

    def __repr__(self):
        return f'attendance: {self.attendance},\nstadium: {self.stadium},\nawayteam: {self.awayteam},\nhometeam: {self.hometeam},\nmatch_date: {self.match_date}'