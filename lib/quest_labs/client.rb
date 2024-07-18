require 'net/http'
require 'json'
require 'singleton'

class QuestLabs::Client
  BUFFER = 5
  include Singleton

  attr_reader :token_expiration_time, :token

  def call(method, path, params={}, parse_json=false)
    get_token if token.nil? || token_about_to_expire?
    case method
    when :post
      response = post_call(path, params)
    when :get
      response = get_call(path, params)
    else
      raise "Unsupported Method : #{method}"
    end

    parse_json ? JSON.parse(response.body) : response.body
  end

  private

  def config
    QuestLabs.config
  end

  def get_call(path, params)
    uri = URI("#{config.base_url}#{path}?#{URI.encode_www_form(params)}")
    puts uri
    req = Net::HTTP::Get.new(uri)

    req['Authorization'] = "Bearer #{token}"

    Net::HTTP.start(uri.hostname, uri.port, :use_ssl => true) {|http|
      http.request(req)
    }
  end

  def post_call(path, params)
    uri = URI("#{config.base_url}#{path}")
    req = Net::HTTP::Post.new(uri)

    req['Authorization'] = "Bearer #{token}"
    req["Content-Type"] = "text/plain"
    req["Accept"] = "text/plain"

    req.body = params

    resp = Net::HTTP.start(uri.hostname, uri.port, :use_ssl => true) {|http|
      http.request(req)
    }

    resp
  end

  def token_url
    "#{config.base_url}hub-authorization-server/oauth2/token"
  end

  def get_token
    response = Net::HTTP.post_form(
      URI(token_url),
      grant_type: config.grant_type,
      client_id: config.client_id,
      client_secret: config.client_secret
    )
    parsed_response = JSON.parse(response.body)
    @token = parsed_response["access_token"]
    expires_in =  parsed_response["expires_in"]
    @token_expiration_time = Time.now + expires_in
  end

  def token_about_to_expire?
    Time.now + BUFFER > token_expiration_time
  end

  def token_expiration_time
    @token_expiration_time ||= Time.now + @token_connection.expires_in
  end
end
