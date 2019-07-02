"""
Copyright 2019 Daniele Rogora

Permission is hereby granted, free of charge, to any person obtaining a copy of this software and associated documentation files (the "Software"), to deal in the Software without restriction, including without limitation the rights to use, copy, modify, merge, publish, distribute, sublicense, and/or sell copies of the Software, and to permit persons to whom the Software is furnished to do so, subject to the following conditions:

The above copyright notice and this permission notice shall be included in all copies or substantial portions of the Software.

THE SOFTWARE IS PROVIDED "AS IS", WITHOUT WARRANTY OF ANY KIND, EXPRESS OR IMPLIED, INCLUDING BUT NOT LIMITED TO THE WARRANTIES OF MERCHANTABILITY, FITNESS FOR A PARTICULAR PURPOSE AND NONINFRINGEMENT. IN NO EVENT SHALL THE AUTHORS OR COPYRIGHT HOLDERS BE LIABLE FOR ANY CLAIM, DAMAGES OR OTHER LIABILITY, WHETHER IN AN ACTION OF CONTRACT, TORT OR OTHERWISE, ARISING FROM, OUT OF OR IN CONNECTION WITH THE SOFTWARE OR THE USE OR OTHER DEALINGS IN THE SOFTWARE.
"""

# -*- coding: utf-8 -*-

import os
import json
import pyotherside
import requests
from datetime import datetime
from dateutil import tz

from pybotvac import Account
from pybotvac import Robot

CACHE_DIR = "/home/nemo/.cache/harbour-neatoer/"
CACHE_FILE = CACHE_DIR + "robots.json"

robots = {}
robot = None
account = None

def set_device(name):
    global robots
    global robot
    for r in robots["robots"]:
        if (r["name"] == name):
            try:
                robot = Robot(r["serial"], r["secret"], r["name"])
                update_state()
            except requests.exceptions.HTTPError as e:
                # Whoops it wasn't a 200
                pyotherside.send("httperror", str(e))
            break

def update_state():
    try:
        state = robot.get_robot_state()
        sj = state.json()
        pyotherside.send("state", sj["state"], sj['details']['isDocked'], sj['details']['isCharging'], sj['details']['isScheduleEnabled'], sj['details']['charge'])
        from_zone = tz.tzutc()
        to_zone = tz.tzlocal()
        for mi in account.maps[robot.serial]['maps']:
            starttime = datetime.strptime(mi['start_at'], '%Y-%m-%dT%H:%M:%SZ').replace(tzinfo=from_zone)
            stoptime = datetime.strptime(mi['end_at'], '%Y-%m-%dT%H:%M:%SZ').replace(tzinfo=from_zone)
            pyotherside.send("addmap", mi['url'], starttime.astimezone(to_zone).strftime("%Y-%m-%d %H:%M"), str(stoptime - starttime), mi['cleaned_area'], mi['launched_from'])
    except requests.exceptions.HTTPError as e:
        # Whoops it wasn't a 200
        pyotherside.send("httperror", str(e))

def logout():
    os.remove(CACHE_FILE)

def login(email, password):
    try:
        account = Account(email, password)
        if (account is None):
            # failed login
            pyotherside.send("loginrequired")
        r_json = {
            "token": account.access_token,
            "robots": [
            ]
        }
        for robot in account.robots:
            r_json["robots"].append({"name": robot.name, "serial": robot.serial, "secret": robot.secret})
        with open(CACHE_FILE, "w") as write_file:
            json.dump(r_json, write_file)
        init()
    except requests.exceptions.HTTPError as e:
        # Whoops it wasn't a 200
        pyotherside.send("loginrequired")

def init():
    if not os.path.exists(CACHE_DIR):
        pyotherside.send("loginrequired")
        os.makedirs(CACHE_DIR)
        return

    if not os.path.exists(CACHE_FILE):
        pyotherside.send("loginrequired")
        return

    with open(CACHE_FILE, "r") as read_file:
        global account
        global robots
        robots = json.load(read_file)
        account = Account(robots["token"])
        for r in robots["robots"]:
            pyotherside.send("rfound", r["name"])

        pyotherside.send("loginsuccessful")


def return_to_base():
    robot.send_to_base()

def start_cleaning():
    robot.start_cleaning(2, 1, 4, None)

def disable_schedule():
    robot.disable_schedule()

def enable_schedule():
    robot.enable_schedule()
