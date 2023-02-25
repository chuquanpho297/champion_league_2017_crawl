from sqlalchemy import Column, String, Integer
from base_connect import Base
from sqlalchemy.dialects.postgresql import ARRAY


class Team(Base):
    __tablename__ = "teams"
    id = Column(Integer, primary_key=True)
    coach_names = Column(ARRAY(String(50)))
    team_name = Column(String(50))
    color_kit = Column(String(50))
    team_logo = Column(String)
    head_coach_name = Column(String(50))


    def __init__(self, coach_names, team_logo, color_kit, head_coach_name, team_name):
        self.coach_names = coach_names
        self.team_logo = team_logo
        self.head_coach_name = head_coach_name
        self.team_name = team_name
        self.color_kit = color_kit

    def __repr__(self):
        return f'id: {self.id}, coach_names:{self.coach_names}, team_logo:{self.team_logo}, color_kit:{self.color_kit}, head_coach_name:{self.head_coach_name},team_name:{self.team_name}'
