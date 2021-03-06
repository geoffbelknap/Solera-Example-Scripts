#!/usr/bin/env ruby -w

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

require 'open-uri'
require 'openssl'

# Ignore self-signed SSL Certificates
module OpenSSL
  module SSL
    remove_const :VERIFY_PEER
  end
end
OpenSSL::SSL::VERIFY_PEER = OpenSSL::SSL::VERIFY_NONE

options = {
  # DS Appliance Management IP
  # [CHANGE_ME]
  :host         =>  "1.2.3.4",
  # Username for Accessing API
  :user         =>  "admin",
  # Password for Accessing API
  # [CHANGE_ME]
  :pass         =>  "Password",
  # Filename for Returned PCAP
  :filename     =>  "data.pcap",
  # Target IP
  # [CHANGE_ME]
  :ipv4_address =>  "1.2.3.4",
  # A Timespan is specified as start_time.end_time in the format of strftime('%m.%d.%Y.%H.%M.%S')
  # Target Timespan (Previous 5 Mins to Present)
  :timespan     =>  (Time.now.getlocal-(60*5)).strftime('%m.%d.%Y.%H.%M.%S')+"."+Time.now.getlocal.strftime('%m.%d.%Y.%H.%M.%S')
}

api_call =  "https://#{options[:host]}/ws/pcap?method=deepsee&user=#{options[:user]}&password=#{options[:pass]}&path=%2Ftimespan%2F#{options[:timespan]}%2Fipv4_address%2F#{options[:ipv4_address]}%2Fdata.pcap"
open(api_call, 'User-Agent' => 'Wget') {|call| @pcap = call.read}
File.open(options[:filename], 'w') {|f| f.write(@pcap)}

