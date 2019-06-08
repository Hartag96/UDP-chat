require "socket"
require "pry"

MULTICAST_ADDR = "224.0.0.222"
PORT = 3000

socket = UDPSocket.open
socket.setsockopt(:IPPROTO_IP, :IP_MULTICAST_TTL, 1)
# socket.send(ARGV[0], 0, MULTICAST_ADDR, PORT)

binding.pry

loop do
  msg = gets.strip
  socket.send(msg, 0, MULTICAST_ADDR, PORT)
end

socket.close
