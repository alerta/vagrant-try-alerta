#!/usr/bin/env ruby

require 'rubygems' if RUBY_VERSION < '1.9.0'
require 'sensu-handler'
require 'net/http'
require 'timeout'


class Alerta < Sensu::Handler

  def short_name
    @event['client']['name'] + '/' + @event['check']['name']
  end

  def action_to_string
    @event['action'].eql?('resolve') ? "RESOLVED" : "ALERT"
  end

  def handle
    endpoint = settings['alerta']['endpoint']  # eg. http://localhost:8080/alerta/api/v2/alerts/alert.json
                                               # eg. http://api.alerta.io/alert

    text = "#{action_to_string} - #{short_name}: #{@event['check']['notification']}"
    threshold_info = "#{@event['check']['command']} @ #{Time.at(@event['check']['issued'])}"
    playbook = "Playbook:  #{@event['check']['playbook']}" if @event['check']['playbook']

    payload = {
      "origin" => "sensu/localhost",
      "resource" => "#{@event['client']['name']}",
      "event" => "#{@event['check']['name']}",
      "group" => "Sensu",
      "severity" => "#{@event['check']['status']}",
      "environment" => [ "PROD" ],
      "service" => @event['client']['subscriptions'],
      "tags" => { "ip_address" => "#{@event['client']['address']}" },
      "text" => "#{text}",
      "value" => "",
      "type" => "sensuAlert",
      "thresholdInfo" => "",
      "rawData" => "#{@event['check']['output']}",
      "moreInfo" => "#{playbook}"
      }.to_json

    begin
      timeout 10 do
        http = Net::HTTP.new(uri.host, uri.port)
        http.post("/widgets/#{widget}", payload)

        puts 'alerta -- sent alert for ' + short_name + ' to ' + endpoint
      end
    rescue Timeout::Error
      puts 'alerta -- timed out while attempting to ' + @event['action'] + ' an incident -- ' + short_name
    end
  end
end

