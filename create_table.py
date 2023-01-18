from models.match import Match
from models.match_result import MatchResult
from models.player import Player
from models.score import Score
from models.stadium import Stadium
from models.team_links import TeamLink
from models.team_result import TeamResult
from models.team import Team

from base_connect import engine, Base

Base.metadata.create_all(engine)
