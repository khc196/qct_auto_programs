import logging
import time
import json
import os
from datetime import datetime

import pytz
from dateutil.tz import tzlocal

class Logger:
    def __init__(self, name, log_file):
        self.log_file = log_file
        self.name = name

        self.local_tz = tzlocal()

        logging.basicConfig(level=logging.INFO, format='%(message)s')
        self.logger = logging.getLogger(self.name)

        if self.log_file:
            path_unit = self.log_file.split('/')
            file_name = path_unit[-1]
            file_path = ""
            for i in range(len(path_unit) - 1):
                file_path += path_unit[i] + '/'
            if os.path.isfile(self.log_file) and os.stat(self.log_file).st_size > 20971520:
                count = 1
                while(os.path.isfile(file_path + 'old_' + str(count) + '_' + file_name)):
                    count += 1
                os.rename(self.log_file, file_path + 'old_' + str(count) + '_' + file_name)
            self.log_handler = logging.FileHandler(self.log_file)
            self.logger.addHandler(self.log_handler)

    def __timestamp(self):
        return str(datetime.now(tz=self.local_tz).isoformat())

    def log(self, event, event_value):
        log = {
            'timestamp': self.__timestamp(),
            'component': self.name,
            'log': {
                'event': event,
                'event_value': event_value
             }
        }
        self.logger.info(json.dumps(log))
