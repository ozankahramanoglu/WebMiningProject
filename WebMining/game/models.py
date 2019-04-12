from django.db import models


class games(models.Model):
    game_order = models.IntegerField(primary_key=True)
    game_id = models.IntegerField(default=None, blank=True, null=True)
    title = models.CharField(max_length=100)
    release_date = models.CharField(max_length=50)
    developer = models.CharField(max_length=100)
    publisher = models.CharField(max_length=100)
    short_desc = models.CharField(max_length=1000)
    system_req = models.CharField(max_length=4000)
    description = models.CharField(max_length=6000)
    image = models.CharField(max_length=200)
    genres = models.CharField(max_length=100)
    similar_games = models.CharField(max_length=100)
    base_price = models.CharField(max_length=20)
    discount_ratio = models.CharField(max_length=10, default=None, blank=True, null=True)
    sale_price = models.CharField(max_length=10)
    lowest_price = models.CharField(max_length=20)
    review_ratio = models.CharField(max_length=100)
    windows = models.CharField(max_length=10)
    mac = models.CharField(max_length=10)
    linux = models.CharField(max_length=10)
    discount = models.CharField(max_length=10)
    specs = models.CharField(max_length=200)
    metacritic = models.CharField(max_length=25)

    def __str__(self):
        return self.title

    def similar_games_as_list(self):
        return self.similar_games.split(' ')

    def specs_as_list(self):
        return self.specs.split(',')

    def system_reqs_as_list(self):
        tmp = self.system_req.split(':')[1:]
        return self.system_req.split(':')[1:]

