require 'json'

module Puppet::Parser::Functions
  newfunction(:publish) do |args|
    JSON.parse(args[0])
  end
end
