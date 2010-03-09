#!/usr/bin/env perl -w

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
#

use strict;
use POSIX qw(strftime);
# perl -MCPAN -e 'install LWP::Simple'
use LWP::UserAgent;

my %options = (
  # DS Appliance Management IP
  # [CHANGE_ME]
  'host'            =>   '10.1.3.174',
  # Username for Accessing API
  'user'            =>   "admin",
  # Password for Accessing API
  # [CHANGE_ME]
  'passwd'          =>   "Solera",
  # Filename for Returned PCAP
  'filename'        =>   "data.pcap",
  # Target IP
  # [CHANGE_ME]
  'ipv4_address'    =>   "10.1.3.221",
  # A Timespan is specified as start_time.end_time in the format of strftime('%m.%d.%Y.%H.%M.%S')
  # Target Timespan (Previous 5 Mins to Present)
  'timespan'        =>   strftime('%m.%d.%Y.%H.%M.%S', (localtime(time-300))) . "." . strftime('%m.%d.%Y.%H.%M.%S', localtime)
);

my $api_call =  "https://" . $options{'host'} . "/ws/pcap?method=deepsee&user=" . $options{'user'} . "&password=" . $options{'passwd'} . "&path=%2Ftimespan%2F" . $options{'timespan'} . "%2Fipv4_address%2F" . $options{'ipv4_address'} . "%2Fdata.pcap";

my $ua = LWP::UserAgent->new(agent => 'Wget');

my $response = $ua->get($api_call, ':content_file' => $options{'filename'} );


