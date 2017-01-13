# This script is for archiving files uploaded to slack. You'll need to setup a /slackFiles directory for the downloads to go into
# Install the required gems
# add the required tokens in teh script below
# run with -> ruby slackFileScript.rb
# created by warrenw@kiwicollection.com

require 'curl'
require 'date'
require 'json'
require 'rest-client'

downloadDir = 'slackFiles'
listUri = 'https://slack.com/api/files.list'
deleteUri = 'https://slack.com/api/files.delete'
#token that has access to view file list
token = ''
#token of a user that has access to download files
userToken = ''

#number of days older than today for which to delete files
deleteOlderThan = 90

timebefore = Date.today - deleteOlderThan
params = { 
    token: token,
    ts_to: timebefore.strftime('%s'),
    count: 300
    }

res = RestClient.get(listUri, {params: params})

json = JSON.parse(res.body)
fileList = json['files']

fileList.each do |file|
    # puts file
    fileUri = file['url_private_download']
    filename = file['name']

    next if fileUri.nil?

    deleteParams = {
        token: token,
        file: file['id']
    }

    begin
        fileResponse = RestClient.get(fileUri, { "Authorization" => "Bearer #{userToken}" })
    rescue => e
        fileResponse = e.response
    end

    if fileResponse.code == 200
        open(downloadDir + '/' + file['timestamp'].to_s + filename, 'wb') do |file|
            file.write(fileResponse.body)
        end
        RestClient.get(deleteUri, {params: deleteParams})
    elsif fileResponse.code == 400
        puts "File '#{fileUri}' not found."
        RestClient.get(deleteUri, {params: deleteParams})
    end
end
