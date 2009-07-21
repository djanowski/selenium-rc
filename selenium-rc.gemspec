Gem::Specification.new do |s|
  s.name              = "selenium-rc"
  s.version           = "0.0.1"
  s.summary           = "Selenium RC Server"
  s.description       = ""
  s.author            = "Damian Janowski"
  s.email             = "damian.janowski@gmail.com"

  s.files = ["lib/selenium/rc_server.rb", "lib/selenium_rc_server.rb", "test/rc_server_test.rb", "vendor/selenium-server.jar"]

  s.add_dependency("selenium-client", ">= 1.2.16")
end
