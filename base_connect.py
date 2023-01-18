from sqlalchemy import create_engine
from sqlalchemy.ext.declarative import declarative_base
from sqlalchemy.orm import sessionmaker

username = "hunglai"
password = ""
database = "champion_league"
url = f'postgresql+psycopg2://{username}:{password}@localhost:5432/{database}'

engine = create_engine(url,echo = True)

session_factory = sessionmaker(bind=engine)

Base = declarative_base()
