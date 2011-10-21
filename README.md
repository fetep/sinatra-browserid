Sinatra plugin that allows authentication against [BrowserID](https://browserid.org/). BrowserID lets you verify the email identity of a user.

To learn more, see how it works [from a users perspective](https://browserid.org/about) and [from a developers perspective](https://github.com/mozilla/browserid/wiki/How-to-Use-BrowserID-on-Your-Site).

Note that BrowserID logins are not done from within a form on your site -- you provide a login button, and that will start up the BrowserID login flow (either via a pop-up or an in-browser widget).

Sinatra usage example:
<pre>
require 'sinatra/base'
require 'sinatra/browserid'

module MyApp < Sinatra::Base
    register Sinatra::BrowserID

    set :browserid_login_button, :orange

    get '/secure'
        authorize!

        ...
    end
end
</pre>
