#!/usr/bin/env ruby
#encoding:UTF-8

require 'rubygems'
require 'CSV'
require 'httparty'
require 'json'
require 'highline/import'

def get_input(prompt="Enter >", show=true)
  ask(prompt) {|q| q.echo = show}
end

filename = ARGV.shift or raise "Enter Filepath to CSV as ARG1"
container = ARGV.shift or raise "Enter container as ARG1"
repository = ARGV.shift or raise "Enter repository as ARG1"

class GitHub
  include HTTParty
  base_uri 'https://api.github.com'
end

username = get_input("Enter Your Username >")
password = get_input("Enter Your Password >", "*")
GitHub.basic_auth username, password

visited_labels = []
CSV.open filename, :headers => true do |csv|
  csv.each do |r|
    body = {
      :title => r['Story'],
      :body => r['Description'],
    }
    # labels = []

    # if r['Labels'] != ''
    #   r['Labels'].split(',').each do |label|
    #     label = label.strip
    #     color =''
    #     3.times {
    #       color << "%02x" % rand(255)
    #     }
    #    unless visited_labels.include? label
    #     labels << {:name => label, :color =>color}
    #    end
    #   end
    #   labels.each do |label|
    #     p label
    #     # this hack doesn't care if you have an existing label - it just errors and moves on like a zen master
    #     # the server however is expected to be equally zen :D
    #     visited_labels << label[:name]
    #     label = GitHub.post '/repos/' + container + '/' + repository + '/labels', :body => JSON.generate(label)
    #     p label
    #   end
    # end

    # body[:labels] = r['Labels'].split(',').map {|l|l.strip} if r['Labels'] != ''

    p json_body = JSON.generate(body)
    issue = GitHub.post '/repos/' + container + '/' + repository + '/issues', :body => json_body
    p issue, :headers => {"User-Agent" => "This-is-ruby-1.9"}

    r.each do |f|
      if f[0] == 'Note'
        next unless f[1]
        body = { :body => f[1] }
        GitHub.post "/repos/" + container + "/" + repository + "/issues/#{issue.parsed_response['number']}/comments", :body => JSON.generate(body)
      end
    end
  end
end
