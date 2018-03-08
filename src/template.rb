require 'json'
require 'singleton'

# json(のhash)を持ってる
class Template
  include Singleton

  def initialize
    Dir.glob("templates/*").each do |f|
      json = nil
      File.open(f) do |io|
        json = JSON.load(io)
      end
      hash = json.to_hash
      val = f[10...-5]

      instance_variable_set("@#{val}", hash)
      self.class.class_eval("attr_accessor :#{val}")
    end
  end

end
