require "rubygems"

require File.join(File.dirname(__FILE__), "..", "lib", "selenium", "rc_server")

require "contest"
require "override"

# Make sure we're not trying to start or stop.
Selenium::RemoteControl::RemoteControl = Class.new(Selenium::RemoteControl::RemoteControl) do
  def start(*args)
    raise "Can't actually call #start in tests."
  end
  
  def stop(*args)
    raise "Can't actually call #stop in tests."
  end
end

class RCServerTest < Test::Unit::TestCase
  include Override

  setup do
    @server = Selenium::RCServer.new(nil, "1234", :timeout => 10)
    @rc = @server.remote_control
  end

  should "have a remote control instance" do
    assert_nil @rc.host
    assert_equal "1234", @rc.port
    assert_equal 10, @rc.timeout_in_seconds
    assert_equal File.expand_path(File.join(File.dirname(__FILE__), "..", "vendor", "selenium-server.jar")), @rc.jar_file
  end

  should "start" do
    expect(@rc, :start, :with => [{:background => true}])
    @server.start
  end

  should "stop" do
    expect(@rc, :stop, :with => [])
    @server.stop
  end

  should "boot" do
    expect(@rc, :start, :with => [{:background => true}])
    expect(TCPSocket, :wait_for_service_with_timeout, :with => [{:host => "0.0.0.0", :port => "1234", :timeout => 15}])
    expect(@rc, :stop, :with => [])

    @server.boot
  end

  should "not boot if it's a grid" do
    server = Selenium::RCServer.new("127.0.0.1", "1234", :timeout => 10)

    assert_nil server.boot
  end
end
