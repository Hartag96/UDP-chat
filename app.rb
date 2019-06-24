# frozen_string_literal: true

require 'socket'
require 'ipaddr'
require 'pry'
require 'ostruct'
require 'timeout'

MULTICAST_ADDR = '224.0.0.222'
BIND_ADDR = '0.0.0.0'
PORT = 3000
TIMEOUT_SECONDS = 10

def reader(socket)
  loop do
    message, _ = socket.recvfrom(255)

    if message.include?('NICK')
      new_nickname = message[5, message.size].strip
      socket.send("NICK #{@nickname} BUSY", 0, MULTICAST_ADDR, PORT) if @nickname == new_nickname
    else
      puts message
    end
  end
rescue
  socket.close
end

def writer(socket)
  loop do
    msg = gets.strip
    socket.send("[#{@nickname}] #{msg}", 0, MULTICAST_ADDR, PORT)
  end
rescue
  socket.close
end

def start_chat(socket)
  puts("You have join chat - nickname #{@nickname}")
  reader_thread = Thread.new { reader(socket) }
  writer_thread = Thread.new { writer(socket) }

  reader_thread.join
  writer_thread.join
end

def query_nickname(socket)
  puts('Give your nickname: ')
  @nickname = gets.strip
  socket.send("NICK #{@nickname}", 0, MULTICAST_ADDR, PORT)
  socket.recvfrom(255) # consume owns message

  Timeout::timeout(TIMEOUT_SECONDS) do
    while true
      message = socket.recvfrom(255)[0]
      raise 'Nickname unavaliable, choose other one' if message == "NICK #{@nickname} BUSY"
    end
  end
rescue Timeout::Error
  start_chat(socket)
rescue StandardError => e
  puts(e)
  query_nickname(socket)
end

# Main
begin
  puts('Welcome to chat')
  socket = UDPSocket.new
  membership = IPAddr.new(MULTICAST_ADDR).hton + IPAddr.new(BIND_ADDR).hton
  # hton - returns a network byte ordered string form of the IP address.

  socket.setsockopt(:IPPROTO_IP, :IP_ADD_MEMBERSHIP, membership)
  socket.setsockopt(:SOL_SOCKET, :SO_REUSEPORT, 1)
  socket.bind(BIND_ADDR, PORT)
  query_nickname(socket)
rescue SignalException
  socket.close
  puts "\n bye Bye #{@nickname}"
end
