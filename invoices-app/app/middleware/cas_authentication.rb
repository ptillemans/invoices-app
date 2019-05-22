require 'rack'

class CasAuthentication

  def initialize(app, message)
    @app = app
    @message = message
  end

  def call(env)
    if Rails.env.production?
      request = Rack::Request.new(env)

      if request.session['cas'].nil?
        return [401, {'Content-Type' => 'text/plain'}, ['CAS Authentication intercepted.']]
      end
    end

    @app.call(env)
  end

end