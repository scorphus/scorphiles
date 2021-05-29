#!/usr/bin/env python3

import gi

gi.require_version('Playerctl', '1.0')

from gi.repository import Playerctl, GLib  # NOQA

player = Playerctl.Player(player_name='spotify')


def on_metadata(player, e):
    if 'xesam:artist' in e.keys() and 'xesam:title' in e.keys():
        print('Now playing:')
        print('{artist} - {title}'.format(artist=e['xesam:artist'][0], title=e['xesam:title']))


def on_play(player):
    print('Playing at volume {}'.format(player.props.volume))


def on_pause(player):
    print('Paused the song: {}'.format(player.get_title()))

player.on('play', on_play)
player.on('pause', on_pause)
player.on('metadata', on_metadata)

# start playing some music
player.play()

artist = player.get_artist()
if artist == 'Lana Del Rey' or 'Slipknot':
    # I meant some good music!
    player.next()

# wait for events
main = GLib.MainLoop()
main.run()
