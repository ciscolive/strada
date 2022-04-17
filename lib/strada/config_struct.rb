# frozen_string_literal: true

class Strada
  class ConfigStruct
    # 类对象初始化函数入口
    def initialize(hash = nil, opts = {})
      @key_to_s = opts.delete(:key_to_s) || false
      @cfg      = hash ? _config_from_hash(hash) : {}
    end

    # 方法反射
    def method_missing(name, *args, &block)
      name = name.to_s
      # 检索 ConfigStruct 键值对
      # strada.cfg['foo']
      name = args.shift if name[0..1] == "[]"
      arg  = args.first

      if name[-1..-1] == "?"
        # 查询是否包含某个 KEY
        # strada.cfg.foo.bar?
        if @cfg.has_key? name[0..-2]
          @cfg[name[0..-2]]
        else
          nil
        end
      elsif name[-1..-1] == "="
        # strada.cfg.foo.bar = 'bala'
        # ConfigStruct 键值对赋值
        _config_set name[0..-2], arg
      else
        # strada.cfg.foo.bar
        # ConfigStruct 查询某个属性
        _config_get name, arg
      end
    end

    # 将配置信息转换为 HASH 对象
    def _config_to_hash
      hash = {}
      @cfg.each do |key, value|
        if value.class == ConfigStruct
          value = value._config_to_hash
        end
        # 是否需要将 key 转为 to_s
        key = key.to_s if @key_to_s
        # 保存键值对数据到 HASH
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
      def _config_set(key, value)
        # 设置键值对
        @cfg[key] = value
      end

      def _config_get(key, value)
        # 查询 KEY VALUE
        if @cfg.has_key? key
          @cfg[key]
        else
          @cfg[key] = ConfigStruct.new
        end
      end

      def _config_from_hash(hash)
        # 转换 HASH 数据为配置对象
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
