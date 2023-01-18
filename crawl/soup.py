from bs4 import BeautifulSoup
import requests

class Soup:
    def __init__(self,url):
        self.url = url

    def get_soup(self):
        page = requests.get(self.url)
        soup = BeautifulSoup(page.content, 'lxml')
        return soup
