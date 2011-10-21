#!/usr/bin/env ruby

$: << File.join(File.dirname(__FILE__), "..", "lib")

require "sinatra/base"
require "sinatra/browserid"

class TestApp < Sinatra::Base
  register Sinatra::BrowserID

  set :sessions, true

  get '/' do
    erb :index
  end

  get '/logout' do
    logout!

    redirect '/'
  end

  get '/confidential' do
    authorize!

    "Hey #{authorized_email}, you're authorized!"
  end
end
