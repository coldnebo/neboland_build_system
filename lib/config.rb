require 'json'
require 'hashie/mash'

class Config < Hashie::Mash

  def self.load(file)
    h = JSON.parse(File.read(file))
    new(h)
  end

end