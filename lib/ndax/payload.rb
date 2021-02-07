require 'jwt'

module Ndax

  class Error < StandardError
  end

  class Payload
    def initialize(params)
      @secret = params[:secret]
      @expire = params[:expire] || 600

      raise Ndax::Error.new unless @secret
      raise Ndax::Error.new unless @expire > 0
    end

    def generate!(params)
      raise Ndax::Error.new unless params[:service]
      raise Ndax::Error.new unless params[:image]

      token = params.merge({
        'iat': Time.now.to_i,
        'exp': (Time.now + @expire).to_i
      })

      JWT.encode token, @secret, 'HS256'
    end

    def decode!(token)
      JWT.decode(token, @secret, true, {
        algorithm: 'HS256'
      }).first
    end

    def safe_decode(token)
      begin
        decode!(token)
      rescue JWT::ExpiredSignature
      rescue JWT::ImmatureSignature
      rescue JWT::VerificationError
      rescue JWT::DecodeError
        nil
      end
    end
  end
end
