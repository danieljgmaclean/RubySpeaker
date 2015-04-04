require_relative 'Couch'
require_relative 'Speak'
require 'json'
require 'rubygems'

#Database
db = 'notifications'

#Init connectivity to local couch instance
server = Couch::Server.new("localhost", "5984")
puts "Connectivity to Couch Established"

#Init the speaking API
speak = Utils::Speak.new("Daniel")

#Start polling
since = 0

while true do
    begin
      puts "Doing a long poll"
      resPoll = server.get("/#{db}/_changes?feed=longpoll&since=#{since}")
    rescue Exception => ex
      puts "Exception on wait, restarting long poll"
    end
    parsedResponse = JSON.parse(resPoll.body)

    if(!parsedResponse['results'][0]['deleted'])
      id = parsedResponse['results'][0]['id']

      #Fetch the latest document
      resGet = server.get("/#{db}/#{id}")
      parsedResponse = JSON.parse(resGet.body)

      if(parsedResponse['message'])
        #Speak the command
        if(!parsedResponse['spoken'])
          puts "We have a message to speak that hasn't been spoken! - #{since}"

          speak.say(parsedResponse['message'])

          parsedResponse['spoken'] = "true"

          #Update that the notification has been spoken
          resPut = server.put("/#{db}/#{id}", parsedResponse.to_json)
        else
          puts "Message has already been spoken, no action required - #{since}"
        end
      end
    end
    since = since + 1
  end
