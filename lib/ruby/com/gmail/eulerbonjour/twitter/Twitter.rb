# -*- coding: undecided -*-
require 'net/http'
require 'uri'
require 'rubygems'
require 'json'
require "amqp"

class Twitter

  def initialize(user, pass)
    @suser = user
    @pass = pass
    @locker = Mutex::new
  end

  # The base of the following code may be came from sample code at a blog of CNET, written by Ejia Kentaro.
  def handleSampleStream(jsonTweetHandler)
    uri = URI.parse("http://stream.twitter.com/1/statuses/sample.json")
    Net::HTTP.start(uri.host, uri.port) do |http|
      request = Net::HTTP::Get.new(uri.request_uri)

      # request.basic_auth(USERNAME, PASSWORD)

      request.basic_auth(@suser, @pass)

      http.request(request) do |response|

        body = ""
        response.read_body do |chunk|
          body = body + chunk
          begin
            parsed = JSON.parse(body)
          rescue => ex
            # quick hack.
            next
          end

          jsonTweetHandler.handle(parsed)

          body = ""
        end
      end
    end

  end

  # Tweetを受け取って実際にどういう処理をするかはjsonTweetHandler
  # 次第。拡張性を持たせるためにわざとjsonTweetHandlerとこのメソッドを
  # 分離している。
  def queuingHandleSampleStream(jsonTweetHandler)
    uri = URI.parse("http://stream.twitter.com/1/statuses/sample.json")
    Net::HTTP.start(uri.host, uri.port) do |http|
      request = Net::HTTP::Get.new(uri.request_uri)

      request.basic_auth(@suser, @pass)
      
      http.request(request) do |response|
        body = ""

        response.read_body do |chunk|
          body = body + chunk
          begin
            parsed = JSON.parse(body)
          rescue => ex
            # quick hack
            next
          end

          jsonTweetHandler.handle(parsed)
          
          body = ""
        end
        
       
      end
      
    end

  end


end

def getPublicTimeline
  # Array of Hash => text, user_name, user_id
  result = Array.new
  
  uri = URI.parse('http://api.twitter.com/1/statuses/public_timeline.json')
  Net::HTTP.start(uri.host, uri.port) do |http|
    request = Net::HTTP::Get.new(uri.request_uri)
    
    request.basic_auth(@user, @pass)
    
    http.request(request) do |response|
      
      body = ""
      response.read_body do |chunk|
        body = body + chunk
      end
      
      parsed = JSON.parse(body)
      
      parsed.each do |tweet|
        
        # debug
        puts tweet["text"]
        # end of debug
      end
      
    end
  end
  
end
