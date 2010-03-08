#!/opt/local/bin/ruby -w

require 'open-uri'
require 'openssl'
require 'optparse'

# Ignore self-signed SSL Certificates
module OpenSSL
  module SSL
    remove_const :VERIFY_PEER
  end
end
OpenSSL::SSL::VERIFY_PEER = OpenSSL::SSL::VERIFY_NONE

# Constants for Humanizing File Sizes
GIGA_SIZE = 1073741824.0
MEGA_SIZE = 1048576.0
KILO_SIZE = 1024.0

# Default Options
options = {
  # Be Verbose?
  :verbose                =>  false,
  # DS Appliance to Send
  :host                   =>  "10.1.3.174",
  # Username for Accessing API
  :user                   =>  "admin",
  # Password
  :pass                   =>  "Solera",
  # Filename for returned PCAP
  :output_filename        =>  "data.pcap",
  #
  # DeepSee API Method Parameters
  #
  # :ethernet_address     =>  "ff:ff:ff:ff:ff:ff",
  # :ethernet_source      =>  "ff:ff:ff:ff:ff:ff",
  # :ethernet_destination =>  "ff:ff:ff:ff:ff:ff",
  # :ethernet_protocol    =>  "ipv4",
  # :interface            =>  "eth2",
  # :ip_protocol          =>  "tcp",
  :ipv4_address           =>  "10.1.3.221",
  # :ipv4_destination     =>  "127.0.0.1",
  # :ipv4_source          =>  "127.0.0.1",
  # :ipv6_address         =>  "::ffff:127.0.0.1",
  # :ipv6_destination     =>  "::ffff:127.0.0.1",
  # :ipv6_source          =>  "::ffff:127.0.0.1",
  # :packet_length        =>  "0_to_1549",
  # :tcp_destination_port =>  "80",
  # :tcp_port             =>  "80",
  # :tcp_source_port      =>  "80",
  # A Timespan is specified as start_time.end_time in the format of strftime('%m.%d.%Y.%I.%M.%S')
  # :timespan             =>  (Time.now.getlocal-(60*5)).strftime('%m.%d.%Y.%H.%M.%S')+"."+Time.now.getlocal.strftime('%m.%d.%Y.%H.%M.%S'),
  :start_time             =>  (Time.now.getlocal-(60*5)).strftime('%m.%d.%Y.%H.%M.%S'),
  :end_time               =>  Time.now.getlocal.strftime('%m.%d.%Y.%H.%M.%S')
  # :udp_destination_port =>  "53",
  # :udp_port             =>  "53",
  # :udp_source_port      =>  "53",
  # :vlan_id              =>  "1"
}

optparse = OptionParser.new do|opts|
  opts.banner = "Usage: #{File.basename($0)} [options] host ..."
  
  opts.on( '-v', '--verbose', 'Output more information' )                             {|options[:verbose]|}
  opts.on( '-u', '--username USERNAME', String, 'Username USERNAME' )                 {|options[:user]|}
  opts.on( '-p', '--password PASSWORD', String, 'Password PASSWORD' )                 {|options[:pass]|}
  opts.on( '-o', '--output_filename FILENAME', String, 'Filename for Returned PCAP' ) {|options[:output_filename]|}
  opts.on( '--host HOSTNAME', String, 'Hostname or IP of Solera Appliance to Query' ) {|options[:host]|}
  opts.on( '--ipv4_address IP', String, 'ipv4_address' )                              {|options[:ipv4_address]|}
  opts.on( '--timespan TIMESPAN', String, 'timespan' )                                {|options[:timespan]|}
  opts.on( '--start_time START_TIME', String, 'start_time' )                          {|options[:start_time]|}
  opts.on( '--end_time END_TIME', String, 'end_time' )                                {|options[:end_time]|}
  opts.on( '-h', '--help', 'Display this screen' ) do
    puts opts
    exit
  end
end

optparse.parse!

puts "Being Verbose" if options[:verbose]
puts "Username : #{options[:user]}" if options[:user] && options[:verbose]
puts "Password : #{options[:pass]}" if options[:pass] && options[:verbose]
puts "DS Appliance : #{options[:host]}" if options[:host] && options[:verbose]
puts "Output Filename : #{options[:filename]}" if options[:filename] && options[:verbose]
puts "ipv4_address : #{options[:ipv4_address]}" if options[:ipv4_address] && options[:verbose]
puts "Start Time: #{options[:start_time]}" if options[:start_time] && options[:verbose]
puts "End Time: #{options[:end_time]}" if options[:end_time] && options[:verbose]

def buildcall(options)
  # Take all arguments
  # Format Arguments
  # Mash it all togethor
  # Build Path
  # Build Call : Long and Drawn out for ease of reading/editing
  api_call =  "https://#{options[:host]}/ws/pcap?method=deepsee&"
  api_call += "user=#{options[:user]}&"
  api_call += "password=#{options[:pass]}&"
  api_call += "path=%2F"
  api_call += "timespan%2F#{options[:start_time]}.#{options[:end_time]}%2F"
  # or
  # api_call += "timespan%2F#{options[:timespan]}%2F"
  api_call += "ipv4_address%2F#{options[:ipv4_address]}%2F"
  api_call += "data.pcap"
  puts "API Call: #{api_call}" if options[:verbose]
  return api_call  
end

def readable(size, precision)
  case
    when size == 1 : "1 Byte"
    when size < KILO_SIZE : "%d Bytes" % size
    when size < MEGA_SIZE : "%.#{precision}f KB" % (size / KILO_SIZE)
    when size < GIGA_SIZE : "%.#{precision}f MB" % (size / MEGA_SIZE)
    else "%.#{precision}f GB" % (size / GIGA_SIZE)
  end
end

begin
  api_call_uri = buildcall(options)
  open(api_call_uri, 'User-Agent' => 'Wget') {|call| @pcap = call.read}
  File.open(options[:filename], 'w') {|f| 
    f.write(@pcap) 
    puts "#{options[:filename]} : " + readable(f.stat.size, 2)
    }
  
rescue => error
  puts "Awww SNAP! : #{error}"
end