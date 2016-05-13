#!/usr/bin/ruby

require "net/http"
require "uri"

gopro_ip = '10.5.5.9'
@gopro_control = 'http://' + gopro_ip + '/gp/gpControl/'

delay = ARGV[0]
init = ARGV[1]

def setup

end

def send url
    uri = URI.parse(url)

    http = Net::HTTP.new(uri.host, uri.port)
    request = Net::HTTP::Get.new(uri.request_uri)

    response = http.request(request)

    if response.code == '200'
        return true
    else
        return false
    end
end

if init == 'true'

    send @gopro_control + 'command/mode?p=1'

    sleep delay.to_i

    send @gopro_control + 'setting/4/0'

    sleep delay.to_i

    send @gopro_control + 'setting/8/0'

    sleep delay.to_i

end


exposures = ['0', '2', '4', '6', '8']

exposures.each do |p|

    if send @gopro_control + 'setting/26/' + p
        print '.'
    else
        puts 'failed to set exposure'
    end

    sleep delay.to_i

    if send @gopro_control + 'command/shutter?p=1'
        print '#'
    else
        puts 'failed to take picture'
    end

    sleep delay.to_i

end
