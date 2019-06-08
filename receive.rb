require "socket"
require "ipaddr"
require "pry"

MULTICAST_ADDR = "224.0.0.222"
BIND_ADDR = "0.0.0.0"
PORT = 3000

socket = UDPSocket.new
membership = IPAddr.new(MULTICAST_ADDR).hton + IPAddr.new(BIND_ADDR).hton
# hton - returns a network byte ordered string form of the IP address.

socket.setsockopt(:IPPROTO_IP, :IP_ADD_MEMBERSHIP, membership)
socket.setsockopt(:SOL_SOCKET, :SO_REUSEPORT, 1)

socket.bind(BIND_ADDR, PORT)

loop do
  message, _ = socket.recvfrom(255)
  # binding.pry unless message.empty?
  puts message
end
