# frozen_string_literal: true

class Strada
  def to_toml(config)
    Adapter::TOML.to config._config_to_hash
  end

  def from_toml(toml)
    Adapter::TOML.from toml
  end

  class Adapter
    class TOML
      # 定义类方法
      class << self
        require "toml"

        # 将 RUBY(HASH) 数据结构转换为 TOML
        def to(hash)
          ::TOML::Generator.new(hash).body
        end
        # 将 TOML 转换为 RUBY 数据结构
        def from(toml)
          ::TOML.load toml
        end
      end
    end
  end
end
