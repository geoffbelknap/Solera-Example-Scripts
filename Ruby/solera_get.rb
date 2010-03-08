#!/usr/bin/env ruby -w

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
  #:ethernet_address     =>  "ff:ff:ff:ff:ff:ff",
  #:ethernet_source      =>  "ff:ff:ff:ff:ff:ff",
  #:ethernet_destination =>  "ff:ff:ff:ff:ff:ff",
  #:ethernet_protocol    =>  "ipv4",
  #:interface            =>  "eth2",
  #:ip_protocol          =>  "tcp",
  :ipv4_address         =>  "10.1.3.221",
  #:ipv4_destination     =>  "127.0.0.1",
  #:ipv4_source          =>  "127.0.0.1",
  #:ipv6_address         =>  "::ffff:127.0.0.1",
  #:ipv6_destination     =>  "::ffff:127.0.0.1",
  #:ipv6_source          =>  "::ffff:127.0.0.1",
  #:packet_length        =>  "0_to_1549",
  #:tcp_destination_port =>  "80",
  #:tcp_port             =>  "80",
  #:tcp_source_port      =>  "80",
  # A Timespan is specified as start_time.end_time in the format of strftime('%m.%d.%Y.%I.%M.%S')
  :timespan             =>  (Time.now.getlocal-(60*5)).strftime('%m.%d.%Y.%H.%M.%S')+"."+Time.now.getlocal.strftime('%m.%d.%Y.%H.%M.%S'),
  #:start_time           =>  (Time.now.getlocal-(60*5)).strftime('%m.%d.%Y.%H.%M.%S'),
  #:end_time             =>  Time.now.getlocal.strftime('%m.%d.%Y.%H.%M.%S'),
  #:udp_destination_port =>  "53",
  #:udp_port             =>  "53",
  #:udp_source_port      =>  "53",
  #:vlan_id              =>  "1"
}

optparse = OptionParser.new do|opts|
  opts.banner = "Usage: #{File.basename($0)} [options] host ..."
  # Basic Params
  opts.on( '-v', '--verbose',                         'Output more information' )     {|options[:verbose]|}
  opts.on( '-u', '--username  USERNAME',      String, 'Username USERNAME' )           {|options[:user]|}
  opts.on( '-p', '--password  PASSWORD',      String, 'Password PASSWORD' )           {|options[:pass]|}
  opts.on( '-o', '--output_filename FILENAME',  String, 'Filename for Returned PCAP' )  {|options[:output_filename]|}
  opts.on( '-b', '--build_uri',                       'Dump the Call URI ONLY' )      {|options[:nop]|}  
  opts.on( '--host  HOSTNAME',                String, 'Hostname or IP of Solera Appliance to Query' ) {|options[:host]|}
  # Ethetnet Params
  opts.on( '--ethernet_address  MAC_ADDR',    String, 'ethernet_address' )            {|options[:ethernet_address]|}
  opts.on( '--ethernet_source MAC_ADDR',      String, 'ethernet_source' )             {|options[:ethernet_source]|}
  opts.on( '--ethernet_destination  MAC_ADDR',  String, 'ethernet_destination' )      {|options[:ethernet_destination]|}
  opts.on( '--ethernet_protocol PROTOCOL',    String, 'ethernet_protocol' )           {|options[:ethernet_protocol]|}
  # Interface Params
  opts.on( '--interface INTERFACE',           String, 'interface' )                   {|options[:interface]|}
  # IP Params
  opts.on( '--ip_protocol IP_PROTOCOL',       String, 'ip_protocol' )                 {|options[:ip_protocol]|}
  # IPv4 Params
  opts.on( '--ipv4_address IPv4_ADDRESS',     String, 'ipv4_address' )                {|options[:ipv4_address]|}
  opts.on( '--ipv4_source IPv4_ADDRESS',      String, 'ipv4_source' )                 {|options[:ipv4_source]|}
  opts.on( '--ipv4_destination IPv4_ADDRESS', String, 'ipv4_destination' )            {|options[:ipv4_destination]|}
  # IPv6 Params
  opts.on( '--ipv6_address IPv6_ADDRESS',     String, 'ipv6_address' )                {|options[:ipv6_address]|}
  opts.on( '--ipv6_source IPv6_ADDRESS',      String, 'ipv6_source' )                 {|options[:ipv6_source]|}
  opts.on( '--ipv6_destination IPv6_ADDRESS', String, 'ipv6_destination' )            {|options[:ipv6_destination]|}
  # Packet Params
  opts.on( '--packet_length PACKET_LENGTH',   String, 'packet_length' )               {|options[:packet_length]|}
  # TCP Params
  opts.on( '--tcp_port TCP_PORT',             String, 'tcp_port' )                    {|options[:tcp_port]|}
  opts.on( '--tcp_source_port TCP_PORT',      String, 'tcp_source_port' )             {|options[:tcp_source]|}
  opts.on( '--tcp_destination_port TCP_PORT', String, 'tcp_destination_port' )        {|options[:tcp_destination_port]|}
  # UDP Params
  opts.on( '--udp_port UDP_PORT',             String, 'udp_port' )                    {|options[:udp_port]|}
  opts.on( '--udp_source_port UDP_PORT',      String, 'udp_source_port' )             {|options[:udp_source]|}
  opts.on( '--udp_destination_port UDP_PORT', String, 'udp_destination_port' )        {|options[:udp_destination_port]|}  
  # Time Params
  opts.on( '--timespan TIMESPAN',             String, 'timespan' )                    {|options[:timespan]|}
  opts.on( '--start_time START_TIME',         String, 'start_time' )                  {|options[:start_time]|}
  opts.on( '--end_time END_TIME',             String, 'end_time' )                    {|options[:end_time]|}
  # VLAN Params
  opts.on( '--vlan_id VLAN_ID',               String, 'vlan_id' )                     {|options[:vlan_id]|}
  # Help Param
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
puts "Output Filename : #{options[:output_filename]}" if options[:output_filename] && options[:verbose]
puts "ipv4_address : #{options[:ipv4_address]}" if options[:ipv4_address] && options[:verbose]
puts "Start Time: #{options[:start_time]}" if options[:start_time] && options[:verbose]
puts "End Time: #{options[:end_time]}" if options[:end_time] && options[:verbose]

def buildcall(options)
  # Build Call : Long and Drawn out for ease of reading/editing
  api_call =  "https://#{options[:host]}/ws/pcap?method=deepsee&"
  api_call += "user=#{options[:user]}&"
  api_call += "password=#{options[:pass]}&"
  api_call += "path=%2F"
  # Time Params
  api_call += "timespan%2F#{options[:start_time]}.#{options[:end_time]}%2F" if options[:start_time] && options[:end_time]
  # or
  api_call += "timespan%2F#{options[:timespan]}%2F" if options[:timespan] && !(options[:start_time] && options[:end_time])
  # api_call += "ipv4_address%2F#{options[:ipv4_address]}%2F" if options[:ipv4_address]
  # Ethetnet Params
  api_call += "ethernet_address%2F#{options[:ethernet_address]}%2F" if options[:ethernet_address]
  api_call += "ethernet_source%2F#{options[:ethernet_source]}%2F" if options[:ethernet_source]
  api_call += "ethernet_destination%2F#{options[:ethernet_destination]}%2F" if options[:ethernet_destination]
  api_call += "ethernet_protocol%2F#{options[:ethernet_protocol]}%2F" if options[:ethernet_protocol]
  # Interface Params
  api_call += "interface%2F#{options[:interface]}%2F" if options[:interface]
  # IP Params
  api_call += "ip_protocol%2F#{options[:ip_protocol]}%2F" if options[:ip_protocol]
  # IPv4 Params
  api_call += "ipv4_address%2F#{options[:ipv4_address]}%2F" if options[:ipv4_address]
  api_call += "ipv4_source%2F#{options[:ipv4_source]}%2F" if options[:ipv4_source]
  api_call += "ipv4_destination%2F#{options[:ipv4_destination]}%2F" if options[:ipv4_destination]
  # IPv6 Params
  api_call += "ipv6_address%2F#{options[:ipv6_address]}%2F" if options[:ipv6_address]
  api_call += "ipv6_source%2F#{options[:ipv6_source]}%2F" if options[:ipv6_source]
  api_call += "ipv6_destination%2F#{options[:ipv6_destination]}%2F" if options[:ipv6_destination]
  # Packet Params
  api_call += "packet_length%2F#{options[:packet_length]}%2F" if options[:packet_length]
  # TCP Params
  api_call += "tcp_port%2F#{options[:tcp_port]}%2F" if options[:tcp_port]
  api_call += "tcp_source_port%2F#{options[:tcp_source]}%2F" if options[:tcp_source]
  api_call += "tcp_destination_port%2F#{options[:tcp_destination_port]}%2F" if options[:tcp_destination_port]
  # UDP Params
  api_call += "udp_port%2F#{options[:udp_port]}%2F" if options[:udp_port]
  api_call += "udp_source_port%2F#{options[:udp_source]}%2F" if options[:udp_source]
  api_call += "udp_destination_port%2F#{options[:udp_destination_port]}%2F" if options[:udp_destination_port]
  # VLAN Params
  api_call += "vlan_id%2F#{options[:vlan_id]}%2F" if options[:vlan_id]
  # 
  api_call += "data.pcap"
  return api_call  
end

def make_readable(size, precision)
  case
    when size == 1 : "1 Byte"
    when size < KILO_SIZE : "%d Bytes" % size
    when size < MEGA_SIZE : "%.#{precision}f KB" % (size / KILO_SIZE)
    when size < GIGA_SIZE : "%.#{precision}f MB" % (size / MEGA_SIZE)
    else "%.#{precision}f GB" % (size / GIGA_SIZE)
  end
end

def get_pcap (call, filename)
  open(call, 'User-Agent' => 'Wget') {|call| @pcap = call.read}
  File.open(filename, 'w') {|f| 
    f.write(@pcap) 
    puts "#{filename} : " + make_readable(f.stat.size, 2)
    }
end

begin
  api_call_uri = buildcall(options)
  puts "API CALL URI : " + api_call_uri if options[:verbose] || options[:nop]
  get_pcap(api_call_uri, options[:output_filename]) if !options[:nop]
rescue => error
  puts "Awww SNAP! : #{error}"
end
