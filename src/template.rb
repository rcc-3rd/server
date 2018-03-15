require 'json'
require 'singleton'

# json(のhash)を持ってる
class Template
  include Singleton

  def initialize
    Dir.glob("templates/*json").each do |f|
      json = nil
      File.open(f) do |io|
        json = JSON.load(io)
      end
      hash = json.to_hash
      
      val = f[10...-5]
      instance_variable_set("@#{val}", hash)

      # 同名の関数でdeep copyを返すように
      self.class.send(:define_method, val) do
        # 深いコピーの為に文字列にバラす(FileIOよりまし・・・)
        eval("Marshal.load(Marshal.dump(@#{val}))")
      end
    end
  end

end
