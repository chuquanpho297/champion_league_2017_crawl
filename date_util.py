import re


def get_year(str):
    return get_date(str)[2]

def get_date(str):
    sep = re.findall('[^0-9]',str)[1]
    return [int(e) for e in str.split(sep)]