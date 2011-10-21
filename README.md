Sinatra plugin that allows authentication against [BrowserID](https://browserid.org/). BrowserID lets you verify the email identity of a user.

To learn more, see how it works [from a users perspective](https://browserid.org/about) and [from a developers perspective](https://github.com/mozilla/browserid/wiki/How-to-Use-BrowserID-on-Your-Site).

Note that BrowserID logins are not done from within a form on your site -- you provide a login button, and that will start up the BrowserID login flow (either via a pop-up or an in-browser widget).

How to get started:

```ruby
require 'sinatra/base'
require 'sinatra/browserid'

module MyApp < Sinatra::Base
    register Sinatra::BrowserID

    set :browserid_login_button, :orange
    set :sessions, true

    get '/'
        if authorized?
            "Welcome, #{authorized_email}"
        else
            render_login_button
        end
    end

    get '/secure'
        authorize!                 # require a user be logged in

        email = authorized_email   # browserid email
        ...
    end

    get '/logout'
        logout!

        redirect '/'
    end
end
```

See the rdoc for more details on the helper functions.

Available sinatra settings:

* <tt>:browserid_login_button</tt>: set to a color (:orange, :red, :blue,
  :green, :grey) or an image URL
* <tt>:browserid_server</tt>: If you're using an alternate auth provider
  other than https://browserid.org
* <tt>:browserid_login_url</tt>: URL users get redirected to when the
  <tt>authorize!</tt> helper is called and a user is not logged in


Still TODO:

* better error handling
* local assertion verification (eliminate callback)

