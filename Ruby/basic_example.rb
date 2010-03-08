#!/usr/bin/env ruby -w

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
  :host         =>  "1.2.3.4",
  # Username for Accessing API
  :user         =>  "admin",
  # Password for Accessing API
  :pass         =>  "Password",
  # Filename for Returned PCAP
  :filename     =>  "data.pcap",
  # Target IP
  :ipv4_address =>  "1.2.3.4",
  # A Timespan is specified as start_time.end_time in the format of strftime('%m.%d.%Y.%I.%M.%S')
  # Target Timespan (Previous 5 Mins to Present)
  :timespan     =>  (Time.now.getlocal-(60*5)).strftime('%m.%d.%Y.%H.%M.%S')+"."+Time.now.getlocal.strftime('%m.%d.%Y.%H.%M.%S')
}

api_call =  "https://#{options[:host]}/ws/pcap?method=deepsee&user=#{options[:user]}&password=#{options[:pass]}&path=%2Ftimespan%2F#{options[:timespan]}%2Fipv4_address%2F#{options[:ipv4_address]}%2Fdata.pcap"
open(api_call, 'User-Agent' => 'Wget') {|call| @pcap = call.read}
File.open(options[:filename], 'w') {|f| f.write(@pcap)}

