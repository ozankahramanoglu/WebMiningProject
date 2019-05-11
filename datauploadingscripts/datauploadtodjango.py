import os
import csv
path = C:\\Users\\ozank\\OneDrive\	\Documents

with open('gamedata.csv') as csvfile:
    reader = csv.DictReader(csvfile,delimiter = ';')
    for row in reader:
        p = games(game_order =row['order'],			
				 game_id=row['id'],
                 title=row['title'],
                 release_date=row['release_date'],
                 developer = row['developer'],
                 publisher=row['publisher'],
                 short_desc = row['short_desc'],
                 system_req = row['system_req'],
                 description = row['description'],
                 image = row['image'],
                 genres = row['genres'],
                 similar_games = row['similar_games'],
                 base_price = row['base_price'],
                 discount_ratio = row['discount_ratio'],
                 sale_price = row['sale_price'],
                 lowest_price = row['lowest_prize'],
                 review_ratio = row['review_ratio'],
                 windows = row['windows_OS'],
                 mac = row['mac_OS'],
                 linux = row['linux_OS'],
                 discount = row['discount_bool'],
                 specs = row['specs'],
                 metacritic = row['metacritic_score'])
        p.save()