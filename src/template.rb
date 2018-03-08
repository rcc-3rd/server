require 'json'
require 'singleton'

# json(のhash)を持ってる
class Template
  include Singleton

  Dir.glob("templates/*").each do |f|
    json = nil
    File.open(f) do |io|
      json = JSON.load(io)
    end
    hash = json.to_hash
    val = f[10...-5]

    eval "@#{val}=hash"

    attr_accessor val.to_sym
  end

end
