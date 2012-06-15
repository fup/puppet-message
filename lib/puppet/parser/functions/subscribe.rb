require 'csv'
require 'md5'

module Puppet::Parser::Functions
  newfunction(:subscribe, :type => :rvalue) do |args|

    # Convert the topic to MD5, just in the event we get some odd characters we cannot handle
    topic = MD5.new(args[0]).to_s
    @active_messages = []
    @expired_messages = []

    File.directory?('/etc/puppetlabs/puppet') ? basedir = '/etc/puppetlabs/puppet' : basedir = '/etc/puppet'

    # Make sure that we create a directory to hold these messages
    begin
      if !File.directory?("#{basedir}/messages")
        Dir::mkdir("#{basedir}/messages")
      end
    rescue => e
      raise Puppet::ParseError, "subscribe(): Unable to setup message storage directory (#{e})"
    end

    # Ensure that we have 1 argument
    unless args.length == 1 then
      raise Puppet::ParseError, "subscribe(): wrong number of arguments (#{args.length}; must be 1)"
    end

    begin
      Dir.glob("#{basedir}/messages/#{topic}/**/*.csv").each do |file|
        CSV.open(file, 'r') do |row|
          message = row[0]
          expiration = Time.at(row[1].to_i)

          if expiration > Time.now
            @active_messages << message
          else
            @expired_messages << file
          end
        end
      end
    rescue => e
      # Just keep going? There is probably a better way to handle this.
      # Heck, I might not need this... why would I have an error reading a file
      # if it isn't returned to me from Dir.glob?
      raise Puppet::ParseError, "subscribe(): error with reading messages (#{e})"
    end

    # Cleanup any expired messages
    begin
      @expired_messages.each { |file| File.delete(file) }
    rescue => e
      raise Puppet::ParseError, "subscribe(): problem cleaning up expired messages (#{e})"
    end

    # Cleanup empty directories as well!
    begin
      %x{find #{basedir}/messages -type d -empty -exec rmdir '{}' \;}
    rescue => e
      raise Puppet::ParseError, "subscribe(): problem cleaning up messages (#{e})"
    end

    @active_messages
  end
end
