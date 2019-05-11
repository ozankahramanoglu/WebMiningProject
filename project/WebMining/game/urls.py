from django.urls import path

from . import views

urlpatterns = [
    path('', views.index, name='index'),
    path('page/<int:counter>', views.page, name='page'),
    path('game/<int:game_id>/', views.detail, name='detail'),
    path('stat/', views.stat, name='stat')
]