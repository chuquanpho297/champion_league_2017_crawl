from match import Match
from match_result import MatchResult
from player import Player
from score import Score
from stadium import Stadium
from team_links import TeamLink
from team_result import TeamResult
from team import Team

from base_connect import engine, Base

Base.metadata.create_all(engine)
