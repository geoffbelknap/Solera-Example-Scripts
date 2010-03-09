#!/usr/bin/env python

## Solera Networks API Example Script
## gbelknap@soleranetworks.com

# Copyright (c) 2010 Solera Networks, Inc

# This program is free software; you can redistribute it and/or
# modify it under the terms of the GNU General Public License
# as published by the Free Software Foundation; either version 2
# of the License, or (at your option) any later version.

# This program is distributed in the hope that it will be useful,
# but WITHOUT ANY WARRANTY; without even the implied warranty of
# MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.  See the
# GNU General Public License for more details.

import urllib
import time

class AppURLopener(urllib.FancyURLopener):
    version = "Wget"
    
urllib._urlopener = AppURLopener()

options = {
  # DS Appliance Management IP
  # [CHANGE_ME]
  'host'            :   "1.2.3.4",
  # Username for Accessing API
  'user'            :   "admin",
  # Password for Accessing API
  # [CHANGE_ME]
  'passwd'          :   "Password",
  # Filename for Returned PCAP
  'filename'        :   "data.pcap",
  # Target IP
  # [CHANGE_ME]
  'ipv4_address'    :   "1.2.3.4",
  # A Timespan is specified as start_time.end_time in the format of strftime('%m.%d.%Y.%H.%M.%S')
  # Target Timespan (Previous 5 Mins to Present)
  'timespan'        :   time.strftime('%m.%d.%Y.%H.%M.%S', (time.localtime(time.time()-300)))+"."+time.strftime('%m.%d.%Y.%H.%M.%S', time.localtime())
}

api_call =  "https://"+options['host']+"/ws/pcap?method=deepsee&user="+options['user']+"&password="+options['passwd']+"&path=%2Ftimespan%2F"+options['timespan']+"%2Fipv4_address%2F"+options['ipv4_address']+"%2Fdata.pcap"

urllib.urlretrieve(api_call, options['filename'])
