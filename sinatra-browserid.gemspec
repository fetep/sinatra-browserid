Gem::Specification.new do |s|
  s.name = "sinatra-browserid"
  s.version = "0.1"

  s.authors = ["Pete Fritchman"]
  s.email = ["petef@databits.net"]
  s.files = ["README.md", "lib/sinatra/browserid.rb", "example/app.rb",
             "example/config.ru", "example/views/index.erb"]
  s.has_rdoc = true
  s.homepage = "https://github.com/fetep/sinatra-browserid"
  s.rdoc_options = ["--inline-source"]
  s.require_paths = ["lib"]
  s.summary = "Sinatra extension for user authentication with browserid.org"

  s.add_dependency("sinatra", ">= 1.1.0")
end
