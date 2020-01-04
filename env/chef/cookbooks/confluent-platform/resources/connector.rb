# frozen_string_literal: true

#
# Copyright (c) 2018 Make.org
#
# Licensed under the Apache License, Version 2.0 (the "License");
# you may not use this file except in compliance with the License.
# You may obtain a copy of the License at
#
#     http://www.apache.org/licenses/LICENSE-2.0
#
# Unless required by applicable law or agreed to in writing, software
# distributed under the License is distributed on an "AS IS" BASIS,
# WITHOUT WARRANTIES OR CONDITIONS OF ANY KIND, either express or implied.
# See the License for the specific language governing permissions and
# limitations under the License.
#

require 'net/http'
require 'uri'
require 'json'

property :connector, String, name_property: true
property :config, Hash
property :url, String, default: 'http://localhost:8083'
# We may have to wait until changes are effective
property :waits, Integer, default: 10
property :waits_delay, Integer, default: 2

default_action :create

action :create do
  conf = new_resource.config
  name = new_resource.connector
  url = new_resource.url

  if conf.nil? || conf.empty?
    raise 'Empty connector configuration, cannot create it'
  end

  conf['name'] = name

  wait_url(url, new_resource.waits, new_resource.waits_delay)
  unless compare?(url, "#{name}/config", conf, [200, 404])
    converge_by "create/update #{name} connector" do
      call_api(url, "#{name}/config", Net::HTTP::Put, [200, 201], conf)
      new_resource.waits.times do
        break if status(url, name, [200, 404]) == 'RUNNING'

        sleep(new_resource.waits_delay)
      end
    end
  end
end

action :delete do
  name = new_resource.connector
  url = new_resource.url

  wait_url(url, new_resource.waits, new_resource.waits_delay)
  if include?(url, '', name)
    converge_by "delete #{name} connector" do
      call_api(url, name, Net::HTTP::Delete, 204)
      new_resource.waits.times do
        break unless include?(url, '', name)

        sleep(new_resource.waits_delay)
      end
    end
  end
end

action :pause do
  name = new_resource.connector
  url = new_resource.url

  wait_url(url, new_resource.waits, new_resource.waits_delay)
  unless status(url, name) == 'PAUSED'
    converge_by "pause #{name} connector" do
      call_api(url, "#{name}/pause", Net::HTTP::Put, 202)
      new_resource.waits.times do
        break if status(url, name) == 'PAUSED'

        sleep(new_resource.waits_delay)
      end
    end
  end
end

action :resume do
  name = new_resource.connector
  url = new_resource.url

  wait_url(url, new_resource.waits, new_resource.waits_delay)
  unless status(url, name) == 'RUNNING'
    converge_by "resume #{name} connector" do
      call_api(url, "#{name}/resume", Net::HTTP::Put, 202)
      new_resource.waits.times do
        break if status(url, name) == 'RUNNING'

        sleep(new_resource.waits_delay)
      end
    end
  end
end

action :restart do
  name = new_resource.connector
  url = new_resource.url

  wait_url(url, new_resource.waits, new_resource.waits_delay)
  converge_by "restart #{name} connector" do
    call_api(url, "#{name}/restart", Net::HTTP::Post, 204)
  end
end

def call_api(url, path, action = Net::HTTP::Get, ok_codes = 200, data = nil)
  uri = uri_of(url, path)
  request = action.new(uri)
  request.content_type = 'application/json'
  request.body = data.to_json unless data.nil?
  req_options = { use_ssl: uri.scheme == 'https' }

  response = Net::HTTP.start(uri.hostname, uri.port, req_options) do |http|
    http.request(request)
  end

  response_check_code(response, ok_codes)
end

def uri_of(url, path)
  uri = URI.parse("#{url}/connectors/#{path}")
  unless %w[http https].include?(uri.scheme)
    raise "Invalid URI scheme, need http or https: #{url}"
  end

  uri
end

def response_check_code(response, ok_codes)
  message = "invalid code: #{response.code} - #{response.body}"
  raise message unless [ok_codes].flatten.include?(response.code.to_i)

  response
end

def compare?(url, path, to_compare, ok_codes)
  current = JSON.parse(call_api(url, path, Net::HTTP::Get, ok_codes).body)
  current == to_compare.transform_values(&:to_s)
end

def include?(url, path, to_compare)
  current = JSON.parse(call_api(url, path).body)
  current.include?(to_compare)
end

def status(url, name, ok_codes = 200)
  raw_status = call_api(url, "#{name}/status", Net::HTTP::Get, ok_codes).body
  JSON.parse(raw_status).dig('connector', 'state')
end

def wait_url(url, waits, waits_delay)
  waits.times do |i|
    begin
      call_api(url, '')
      break
    rescue Errno::EADDRNOTAVAIL
      Chef::Log.info("Connectors: waiting for #{url} (#{i}/#{waits}")
      sleep(waits_delay)
    end
  end
end
