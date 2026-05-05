# Basic trinket for displaying GPS data on OLED screen
# This code is built on the Adafruit GPS and OLED tutorials
# SPDX-FileCopyrightText: 2021 ladyada for Adafruit Industries
# SPDX-License-Identifier: MIT

import time
import board
import busio
import adafruit_gps
import displayio
import digitalio
from i2cdisplaybus import I2CDisplayBus
import terminalio
from adafruit_display_text import label
import adafruit_displayio_sh1107

# import microcontroller

displayio.release_displays()
# oled_reset = board.D9

pin_9 = digitalio.DigitalInOut(board.D9)
pin_9.switch_to_input(pull=digitalio.Pull.UP)
pin_6 = digitalio.DigitalInOut(board.D6)
pin_6.switch_to_input(pull=digitalio.Pull.UP)
pin_5 = digitalio.DigitalInOut(board.D5)
pin_5.switch_to_input(pull=digitalio.Pull.UP)

# Use for I2C
i2c = board.I2C()  # uses board.SCL and board.SDA
display_bus = I2CDisplayBus(i2c, device_address=0x3C)

# SH1107 is vertically oriented 64x128
WIDTH = 128
HEIGHT = 64
BORDER = 2

display = adafruit_displayio_sh1107.SH1107(display_bus, width=WIDTH, height=HEIGHT)

# Make the display context
splash = displayio.Group()
display.root_group = splash

color_bitmap = displayio.Bitmap(WIDTH, HEIGHT, 1)
color_palette = displayio.Palette(1)
color_palette[0] = 0x000000  # Black

# Create a serial connection for the GPS connection using default speed and
# a slightly higher timeout (GPS modules typically update once a second).
# These are the defaults you should use for the GPS FeatherWing.
# For other boards set RX = GPS module TX, and TX = GPS module RX pins.
uart = busio.UART(board.TX, board.RX, baudrate=9600, timeout=30)

# for a computer, use the pyserial library for uart access
# import serial
# uart = serial.Serial("/dev/ttyUSB0", baudrate=9600, timeout=10)

# If using I2C, we'll create an I2C interface to talk to using default pins
# i2c = board.I2C()  # uses board.SCL and board.SDA
# i2c = board.STEMMA_I2C()  # For using the built-in STEMMA QT connector
# on a microcontroller

# Create a GPS module instance.
gps = adafruit_gps.GPS(uart, debug=False)  # Use UART/pyserial
# gps = adafruit_gps.GPS_GtopI2C(i2c, debug=False)  # Use I2C interface

# Initialize the GPS module by changing what data it sends and at what rate.
# These are NMEA extensions for PMTK_314_SET_NMEA_OUTPUT and
# PMTK_220_SET_NMEA_UPDATERATE but you can send anything from here to adjust
# the GPS module behavior:
#   https://cdn-shop.adafruit.com/datasheets/PMTK_A11.pdf

# Turn on the basic GGA and RMC info (what you typically want)
gps.send_command(b"PMTK314,0,1,0,1,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0")
# Turn on the basic GGA and RMC info + VTG for speed in km/h
# gps.send_command(b"PMTK314,0,1,1,1,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0")
# Turn on just minimum info (RMC only, location):
# gps.send_command(b'PMTK314,0,1,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0')
# Turn off everything:
# gps.send_command(b'PMTK314,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0')
# Turn on everything (not all of it is parsed!)
# gps.send_command(b'PMTK314,1,1,1,1,1,1,0,0,0,0,0,0,0,0,0,0,0,0,0')

# Set update rate to once a second (1hz) which is what you typically want.
gps.send_command(b"PMTK220,2000")
# Or decrease to once every two seconds by doubling the millisecond value.
# Be sure to also increase your UART timeout above!
# gps.send_command(b'PMTK220,2000')
# You can also speed up the rate, but don't go too fast or else you can lose
# data during parsing.  This would be twice a second (2hz, 500ms delay):
# gps.send_command(b'PMTK220,500')

# Main loop runs forever printing the location, etc. every second.
gps.update()
while True:
    # Make sure to call gps.update() every loop iteration and at least twice
    # as fast as data comes from the GPS unit (usually every second).
    # This returns a bool that's true if it parsed new data (you can ignore it
    # though if you don't care and instead look at the has_fix property).
    if not pin_9.value:
        if not gps.has_fix:
            splash = displayio.Group()
            display.root_group = splash
            text1 = "No Fix"
            text_nofix = label.Label(
                terminalio.FONT, text=text1, scale=2, color=0xFFFFFF, x=4, y=16
            )
            splash.append(text_nofix)
            time.sleep(5)
            display.root_group = None
        if gps.has_fix:
            splash = displayio.Group()
            display.root_group = splash
            text1 = "Long "
            text_long = label.Label(
                terminalio.FONT, text=text1, scale=2, color=0xFFFFFF, x=4, y=16
            )
            splash.append(text_long)

            text2 = "Lat "
            text_lat = label.Label(
                terminalio.FONT, text=text2, scale=2, color=0xFFFFFF, x=4, y=44
            )
            splash.append(text_lat)

            textlat = "{0:.4f}".format(gps.latitude)
            text_lat_val = label.Label(
                terminalio.FONT, text=textlat, scale=1, color=0xFFFFFF, x=64, y=20
            )
            splash.append(text_lat_val)

            textlong = "{0:.4f}".format(gps.longitude)
            text_long_val = label.Label(
                terminalio.FONT, text=textlong, scale=1, color=0xFFFFFF, x=64, y=48
            )
            splash.append(text_long_val)

            time.sleep(5)
            display.root_group = None
    if not pin_6.value:
        latch = True
        splash = displayio.Group()
        display.root_group = splash
        text1 = "Long "
        text_long = label.Label(
            terminalio.FONT, text=text1, scale=2, color=0xFFFFFF, x=4, y=16
        )
        splash.append(text_long)

        text2 = "Lat "
        text_lat = label.Label(
            terminalio.FONT, text=text2, scale=2, color=0xFFFFFF, x=4, y=44
        )
        splash.append(text_lat)

        textlat = "{0:.4f}".format(gps.latitude)
        text_lat_val = label.Label(
            terminalio.FONT, text=textlat, scale=1, color=0xFFFFFF, x=64, y=20
        )
        splash.append(text_lat_val)

        textlong = "{0:.4f}".format(gps.longitude)
        text_long_val = label.Label(
            terminalio.FONT, text=textlong, scale=1, color=0xFFFFFF, x=64, y=48
        )
        splash.append(text_long_val)

        gps.update()
        time.sleep(0.2)
        while latch:
            textlat = "{0:.4f}".format(gps.latitude)
            text_lat_val = label.Label(
                terminalio.FONT, text=textlat, scale=1, color=0xFFFFFF, x=64, y=20
            )
            textlong = "{0:.4f}".format(gps.longitude)
            text_long_val = label.Label(
                terminalio.FONT, text=textlong, scale=1, color=0xFFFFFF, x=64, y=48
            )
            gps.update()
            time.sleep(0.2)
            if not pin_5.value:
                latch = False
                display.root_group = None
            if not pin_6.value:
                latch = False
                display.root_group = None
            if not pin_9.value:
                latch = False
                display.root_group = None
    if not pin_5.value:
        gps.update()
        if not gps.has_fix:
            counter = 1
            while counter < 5:
                time.sleep(5)
                if gps.has_fix:
                    counter = counter + 4
                if not gps.has_fix:
                    gps.update()
                    counter = counter + 1
time.sleep(0.5)
