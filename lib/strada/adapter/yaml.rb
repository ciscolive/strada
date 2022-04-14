# frozen_string_literal: true

class Strada
  def to_yaml(config)
    Adapter::YAML.to config._config_to_hash
  end

  def from_yaml(yaml)
    Adapter::YAML.from yaml
  end

  class Adapter
    class YAML
      # 定义类方法
      class << self
        require "yaml"

        # 将 RUBY(HASH) 数据结构转换为 YAML
        def to(hash)
          ::YAML.dump hash
        end
        # 将 YAML 转换为 RUBY(HASH) 数据结构
        def from(yaml)
          ::YAML.load yaml
        end
      end
    end
  end
end
