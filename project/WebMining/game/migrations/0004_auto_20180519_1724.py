# Generated by Django 2.0 on 2018-05-19 14:24

from django.db import migrations


class Migration(migrations.Migration):

    dependencies = [
        ('game', '0003_games_order'),
    ]

    operations = [
        migrations.RenameField(
            model_name='games',
            old_name='order',
            new_name='game_order',
        ),
    ]
