import json
import requests
from bs4 import BeautifulSoup

rsp = requests.get('https://www.thegazette.co.uk/all-notices/content/100274')
doc = BeautifulSoup(rsp.text, 'html.parser')
ps = doc.find_all('p')

categories = {}
codes = {}

for p in ps:
    text = p.text
    if text[:4].isdigit():
        codes[text[:4]] = text[4:].strip()
    elif text[:2].isdigit():
        categories[text[:2]] = text[2:].strip().title()


for code in codes:
    category = categories[code[:2]]
    codes[code] = '{} > {}'.format(category, codes[code])

print(json.dumps(codes))
