require "selenium/client"

module Selenium
  class RCServer
    attr :host
    attr :port
    attr :options

    def initialize(host, port, options = {})
      @host, @port, @options = host, port, options
    end

    def boot
      return if selenium_grid?

      start
      wait
      stop_at_exit
    end

    def start
      silence_stream($stdout) do
        remote_control.start :background => true
      end
    end

    def stop_at_exit
      at_exit do
        stop
      end
    end

    def remote_control
      @remote_control ||= begin
        rc = ::Selenium::RemoteControl::RemoteControl.new(host, port, options)
        rc.jar_file = jar_path
        rc
      end
    end

    def jar_path
      File.expand_path(File.join(File.dirname(__FILE__), "..", "..", "vendor", "selenium-server.jar"))
    end

    def selenium_grid?
      !! host
    end

    def wait
      $stderr.print "==> Waiting for Selenium RC server on port #{port}... "
      wait_for_socket
      $stderr.print "Ready!\n"
    rescue SocketError
      fail
    end

    def wait_for_socket
      silence_stream($stdout) do
        TCPSocket.wait_for_service_with_timeout \
          :host     => host || "0.0.0.0",
          :port     => port,
          :timeout  => 15 # seconds
      end
    end

    def fail
      $stderr.puts
      $stderr.puts
      $stderr.puts "==> Failed to boot the Selenium RC server... exiting!"
      exit
    end

    def stop
      silence_stream($stdout) do
        remote_control.stop
      end
    end

  protected

    def silence_stream(stream)
      old_stream = stream.dup
      stream.reopen(RUBY_PLATFORM =~ /mswin/ ? 'NUL:' : '/dev/null')
      stream.sync = true
      yield
    ensure
      stream.reopen(old_stream)
    end
  end
end
