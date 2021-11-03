#!/usr/bin/env python
import os
import pychromecast
import sys
#  import time

DEVICE_NAME = os.environ['DEVICE_NAME']
MP3SERVER_ENDPOINT = os.environ['MP3SERVER_ENDPOINT']

if __name__ == '__main__':
    filename = sys.argv[1]

    # Discover and connect to chromecasts named Living Room
    chromecasts, browser = pychromecast.get_listed_chromecasts(friendly_names=[DEVICE_NAME])

    cast = chromecasts[0]

    # Start worker thread and wait for cast device to be ready
    cast.wait()
    #  print(cast.device)

    #  print(cast.status)

    mc = cast.media_controller
    mc.play_media(MP3SERVER_ENDPOINT + '/' + filename, 'audio/mp3')

    # statusのplayer_stateが'PLAYING'になってなければエラーとして良さそう
    #  print(mc.status)
    mc.block_until_active()

    #  mc.pause()
    #  time.sleep(5)
    #  mc.play()

    # Shut down discovery
    pychromecast.discovery.stop_discovery(browser)
