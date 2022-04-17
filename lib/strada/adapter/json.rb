# frozen_string_literal: true

class Strada
  def to_json(config)
    Adapter::JSON.to config._config_to_hash
  end

  def from_json(json)
    Adapter::JSON.from json
  end

  class Adapter
    class JSON
      # 定义类方法
      class << self
        # 将 RUBY(HASH) 数据结构转换为 JSON
        def to(hash)
          require "json"
          ::JSON.pretty_generate hash
        end
        # 将 JSON 转换为 RUBY 数据结构
        def from(json)
          require "json"
          ::JSON.load json
        end
      end
    end
  end
end
