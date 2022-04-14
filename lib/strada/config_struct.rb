# frozen_string_literal: true

class Strada
  class ConfigStruct
    # 将配置信息转换为 HASH 对象
    def _config_to_hash
      hash = {}
      @cfg.each do |key, value|
        if value.class == ConfigStruct
          value = value._config_to_hash
        end
        key       = key.to_s if @key_to_s
        hash[key] = value
      end
      hash
    end

    # 是否为空配置
    def empty?
      @cfg.empty?
    end

    # 调用配置 each 方法执行代码块
    def each(&block)
      @cfg.each(&block)
    end

    # 配置的相关属性
    def keys
      @cfg.keys
    end

    # 判断配置是否包含某个属性
    def has_key?(key)
      @cfg.has_key? key
    end

    private
      def initialize(hash = nil, opts = {})
        @key_to_s = opts.delete :key_to_s
        @cfg      = hash ? _config_from_hash(hash) : {}
      end

      # 方法反射
      def method_missing(name, *args, &block)
        name = name.to_s
        name = args.shift if name[0..1] == "[]" # strada.cfg['foo']
        arg  = args.first

        if name[-1..-1] == "?" # strada.cfg.foo.bar?
          if @cfg.has_key? name[0..-2]
            @cfg[name[0..-2]]
          else
            nil
          end
        elsif name[-1..-1] == "=" # strada.cfg.foo.bar = 'quux'
          _config_set name[0..-2], arg
        else
          _config_get name, arg # strada.cfg.foo.bar
        end
      end

      # 设置键值对
      def _config_set(key, value)
        @cfg[key] = value
      end

      # 查询 KEY VALUE
      def _config_get(key, value)
        if @cfg.has_key? key
          @cfg[key]
        else
          @cfg[key] = ConfigStruct.new
        end
      end

      # 转换 HASH 数据为配置对象
      def _config_from_hash(hash)
        cfg = {}
        hash.each do |key, value|
          if value.class == Hash
            value = ConfigStruct.new value, key_to_s: @key_to_s
          end
          cfg[key] = value
        end
        cfg
      end
  end
end
