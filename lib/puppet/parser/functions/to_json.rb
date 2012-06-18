require 'json'

module Puppet::Parser::Functions
  newfunction(:publish) do |args|
    args[0].to_json
  end
end
