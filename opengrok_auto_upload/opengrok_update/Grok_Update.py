#!/usr/bin/python

import os, subprocess, time, errno, glob, sys, logging, signal, argparse, random, pytz
from threading import Thread, Event
from Logger import *
from filelock import FileLock

from datetime import datetime
from dateutil.tz import tzlocal

META_WATCH = '/local2/mnt/workspace/watch'
OPENGROK = '/var/opengrok'
GROK_UPDATE_LOG=META_WATCH+'/grok_update.log'
START_TIME = 5
END_TIME = 6
class Grok_Update:
    def __init__(self, log_file=GROK_UPDATE_LOG):
        self.log_file = log_file
        self.__stop = False
        self.logger = Logger('worker-{0}'.format(os.getpid()), self.log_file)
        self.child = 0
        self.tz = tzlocal()
    def work(self):
        self.logger.log('work', './var/opengrok/bin/OpenGrok update - run')
        lv_qxa = subprocess.Popen('/var/opengrok/bin/OpenGrok update'.split(), stdin=subprocess.PIPE, stderr=subprocess.PIPE)
        lv_qxa.communicate()
        self.logger.log('work', './var/opengrok/bin/OpenGrok update - done')
        self.logger.log('work', './var/opengrok/bin/OpenGrok_LA_MDM update - run')
        la_mdm = subprocess.Popen('/var/opengrok/bin/OpenGrok_LA_MDM update'.split(), stdin=subprocess.PIPE, stderr=subprocess.PIPE)
        la_mdm.communicate()
        self.logger.log('work', './var/opengrok/bin/OpenGrok_LA_MDM update - done')
    def main(self):
        self.logger.log('start', {
            'pid': os.getpid()
        })
        random.seed(os.getpid())
        while not self.__stop and not os.path.isfile('/var/log/auto_repo/grok_update.log'):
            now_hour = datetime.now(tz=self.tz).hour
            if now_hour == START_TIME or now_hour == END_TIME:
                self.logger.log('message', 'It\'s time to start')
                self.work()
            time.sleep(600)
        self.logger.log('stop', {
            'pid': os.getpid()
        })
        return 0
    def stop(self):
        self.__stop = True


