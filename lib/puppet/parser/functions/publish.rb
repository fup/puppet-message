require 'csv'
require 'md5'

module Puppet::Parser::Functions
  newfunction(:publish) do |args|

    # Convert the topic/hostname to MD5, just in the event we get some odd characters we cannot handle
    topic = MD5.new(args[0]).to_s
    message = args[1]
    message_md5 = MD5.new(message).to_s
    expiration = Time.now.to_i + args[2].to_i
    hostname = MD5.new(lookupvar('fqdn')).to_s

    File.directory?('/etc/puppetlabs/puppet') ? basedir = '/etc/puppetlabs/puppet' : basedir = '/etc/puppet'

    # Make sure that we create a directory to hold these messages
    begin
      if !File.directory?("#{basedir}/messages")
        Dir::mkdir("#{basedir}/messages")
      end
    rescue => e
      raise Puppet::ParseError, "publish(): Unable to setup message storage directory (#{e})"
    end

#    # Ensure that we have 3 arguments
#    unless args.length = 3 then
#      raise Puppet::ParseError, "publish(): wrong number of arguments (#{args.length}; must be 3)"
#    end


    begin
      path = "#{basedir}/messages/#{topic}/#{hostname}"

      # Lazy create directories for this file
      FileUtils.mkdir_p path

      # Write out the CSV file
      CSV.open("#{path}/#{message_md5}.csv", 'w') do |row|
        row << [message, expiration]
      end
    rescue
      raise Puppet::ParseError, "publish(): unable to write message to disk #{e}"
    end
  end
end
