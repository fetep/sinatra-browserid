#!/usr/bin/env ruby

require "json"
require "net/https"
require "sinatra/base"

# This module provides an interface to verify a users email address
# with browserid.org.
module Sinatra
  module BrowserID

    module Helpers
      # Returns true if the current user has logged in and presented
      # a valid assertion.
      def authorized?
        ! session[:browserid_email].nil?
      end

      # If the current user is not logged in, redirects to a login
      # page. Override the login page by setting the Sinatra
      # option <tt>:browserid_login_url</tt>.
      def authorize!
        session[:authorize_redirect_url] = request.url
        login_url = settings.browserid_login_url
        redirect login_url unless authorized?
      end

      # Logs out the current user.
      def logout!
        session[:browserid_email] = nil
      end

      # Returns the BrowserID verified email address, or nil if the
      # user is not logged in.
      def authorized_email
        session[:browserid_email]
      end

      # Returns the HTML to render the BrowserID login button.
      # Optionally takes a URL parameter for where the user should
      # be redirected to after the assert POST back.  You can
      # customize the button image by setting the Sinatra option
      # <tt>:browserid_login_button</tt> to a color (:orange,
      # :red, :blue, :green, :grey) or an actual URL.
      def render_login_button(redirect_url = nil)
        case settings.browserid_login_button
        when :orange, :red, :blue, :green, :grey
          button_url = "#{settings.browserid_url}/i/sign_in_" \
                       "#{settings.browserid_login_button.to_s}.png"
        else
          button_url = settings.browserid_login_button
        end

        if session[:authorize_redirect_url]
          redirect_url = session[:authorize_redirect_url]
          session[:authorize_redirect_url] = nil
        end
        redirect_url ||= request.url

        template = ERB.new(Templates::LOGIN_BUTTON)
        template.result(binding)
      end
    end # module Helpers

    def self.registered(app)
      app.helpers BrowserID::Helpers

      app.set :browserid_url, "https://browserid.org"
      app.set :browserid_login_button, :red
      app.set :browserid_login_url, "/_browserid_login"

      app.get '/_browserid_login' do
        # TODO(petef): render a page that initiates login without
        # waiting for a user click.
        render_login_button
      end

      app.post '/_browserid_assert' do
        # TODO(petef): do verification locally, without a callback
        audience = request.host_with_port
        bid_uri = URI.parse(settings.browserid_url)
        http = Net::HTTP.new(bid_uri.host, bid_uri.port)
        http.use_ssl = true
        data = {
          "assertion" => params[:assertion],
          "audience" => audience,
        }
        data_str = data.collect { |k, v| "#{k}=#{v}" }.join("&")
        res = http.post("/verify", data_str)

        if res.code =~ /^2\d{2}$/
          verify = ::JSON.parse(res.body)
        else
          return
        end

        if verify["status"] != "okay"
          $stderr.puts "status was not OK. #{verify.inspect}"
          return
        end

        session[:browserid_email] = verify["email"]
        session[:browserid_expires] = verify["expires"].to_f / 1000

        redirect params[:redirect] || "/"
      end
    end # def self.registered

    module Templates
      LOGIN_BUTTON = %q{
<script src="<%= settings.browserid_url %>/include.js" type="text/javascript"></script>
<script type="text/javascript">
function _browserid_login() {
navigator.id.getVerifiedEmail(function(assertion) {
    if (assertion) {
        document.forms._browserid_assert.assertion.value = assertion;
        document.forms._browserid_assert.submit();
    } else {
        // TODO: handle failure case?
    }
});
}
</script>

<form name="_browserid_assert" action="/_browserid_assert" method="post">
<input type="hidden" name="redirect" value="<%= redirect_url %>">
<input type="hidden" name="assertion" value="">
</form>

<a href="#"><img src="<%= button_url %>" id="browserid_login_button" border=0 onClick="_browserid_login()" /></a>
      }
    end
  end # module BrowserID

  register BrowserID
end # module Sinatra

  #set :sessions, true
