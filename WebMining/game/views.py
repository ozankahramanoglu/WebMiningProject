from django.shortcuts import get_object_or_404, render
from .models import games


def index(request):
    lastest_game_list = games.objects.order_by('game_order')[:20]
    page_number = int(len(games.objects.all()) / 18)
    temp = range(1 ,int(page_number),1)
    context = {
        'page_number': temp,
        'latest_games_list': lastest_game_list,
    }
    return render(request, 'games/index.html', context)


def detail(request, game_id):
    game = get_object_or_404(games, game_id=game_id)
    return render(request, 'games/detail.html', {'game': game})


def page(request, counter):
    lastest_game_list = games.objects.order_by('game_order')[(counter-1)*20:counter*20]
    page_number = int(len(games.objects.all())/18)
    temp = range(1,int(page_number),1)
    context = {
        'latest_games_list': lastest_game_list,
        'page_number': temp,
    }
    return render(request, 'games/index.html', context)


def stat(request):
    lastest_game_number = games.objects.all().count()
    context = {
        'lastest_game_number' : lastest_game_number,
    }
    return render(request, 'games/stat.html', context)


