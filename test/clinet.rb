require 'action_cable_client'

EventMachine.run do

  uri = "wss://localhost/cable"
  client = ActionCableClient.new(uri, "room_channel12")
  # the connected callback is required, as it triggers
  # the actual subscribing to the channel but it can just be
  # client.connected {}
  client.connected { puts 'successfully connected.' }

  # called whenever a message is received from the server
  client.received do | message |
    puts "saa"
    puts message
  end

  # adds to a queue that is purged upon receiving of
  # a ping from the server
  client.perform('speak', { message: 'hello from amc' })
end