# Generated by Django 2.0 on 2018-05-21 08:33

from django.db import migrations


class Migration(migrations.Migration):

    dependencies = [
        ('game', '0006_stats'),
    ]

    operations = [
        migrations.DeleteModel(
            name='stats',
        ),
    ]