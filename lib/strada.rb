# frozen_string_literal: true

require_relative "strada/config_struct"
require_relative "strada/adapter/yaml"
require_relative "strada/adapter/json"
require_relative "strada/adapter/toml"
require "fileutils"

class Strada < StandardError; end

class NoName < ConfigError; end

class UnknownOption < ConfigError; end

# @example common use case
#   CFGS = Asetus.new :name=>'my_sweet_program' :load=>false   # do not load config from filesystem
#   CFGS.default.ssh.port      = 22
#   CFGS.default.ssh.hosts     = %w(host1.example.com host2.example.com)
#   CFGS.default.auth.user     = lana
#   CFGS.default.auth.password = danger_zone
#   CFGS.load  # load system config and user config from filesystem and merge with defaults to #cfg
#   raise StandardError, 'edit ~/.config/my_sweet_program/config' if CFGS.create  # create user config from default config if no system or user config exists
#   # use the damn thing
#   CFG = CFGS.cfg
#   user      = CFG.auth.user
#   password  = CFG.auth.password
#   ssh_port  = CFG.ssh.port
#   ssh_hosts = CFG.ssh.hosts

class Strada
  CONFIG_FILE = "config"
  # 类对象属性
  attr_reader :cfg, :default, :file
  attr_accessor :system, :user

  # 类方法
  class << self
    def cfg(*args)
      new(*args).cfg
    end
  end

  # When this is called, by default :system and :user are loaded from
  # filesystem and merged with default, so that user overrides system which
  # overrides default
  #
  # @param [Symbol] level which configuration level to load, by default :all
  # @return [void]
  def load(level = :all)
    if (level == :default) || (level == :all)
      @cfg = merge @cfg, @default
    end
    if (level == :system) || (level == :all)
      @system = load_cfg @sys_dir
      @cfg    = merge @cfg, @system
    end
    if (level == :user) || (level == :all)
      @user = load_cfg @usr_dir
      @cfg  = merge @cfg, @user
    end
  end

  # @param [Symbol] level which configuration level to save, by default :user
  # @return [void]
  def save(level = :user)
    if level == :user
      save_cfg @usr_dir, @user
    elsif level == :system
      save_cfg @sys_dir, @system
    end
  end

  # @example create user config from default config and raise error, if no config was found
  #   raise StandardError, 'edit ~/.config/name/config' if strada.create
  # @param [Hash] opts options for Asetus
  # @option opts [Symbol]  :source       source to use for settings to save, by default :default
  # @option opts [Symbol]  :destination  destination to use for settings to save, by default :user
  # @option opts [boolean] :load         load config once saved, by default false
  # @return [boolean] true if config didn't exist and was created, false if config already exists
  def create(opts = {})
    src = opts.delete :source || :default
    dst = opts.delete :destination || :user

    no_config = false
    no_config = true if @system.empty? && @user.empty?
    if no_config
      src = instance_variable_get "@" + src.to_s
      instance_variable_set("@" + dst.to_s, src.dup)
      save dst
      load if opts.delete :load
    end
    no_config
  end

  private
    def initialize(opts = {})
      # @param [Hash] opts options for Asetus.new
      # @option opts [String]  :name     name to use for strada (/etc/name/, ~/.config/name/) - autodetected if not defined
      # @option opts [String]  :adapter  adapter to use 'yaml', 'json' or 'toml' for now
      # @option opts [String]  :usr_dir   directory for storing user config ~/.config/name/ by default
      # @option opts [String]  :sys_dir   directory for storing system config /etc/name/ by default
      # @option opts [String]  :cfg_file  configuration filename, by default CONFIG_FILE
      # @option opts [Hash]    :default  default settings to use
      # @option opts [boolean] :load     automatically load+merge system+user config with defaults in #cfg
      # @option opts [boolean] :key_to_s convert keys to string by calling #to_s for keys
      @name     = opts.delete(:name) || meta_name
      @adapter  = opts.delete(:adapter) || "yaml"
      @usr_dir  = opts.delete(:usr_dir) || File.join(Dir.home, ".config", @name)
      @sys_dir  = opts.delete(:sys_dir) || File.join("/etc", @name)
      @cfg_file = opts.delete(:cfg_file) || CONFIG_FILE

      # 配置对象属性
      @default  = ConfigStruct.new opts.delete(:default)
      @system   = ConfigStruct.new
      @user     = ConfigStruct.new
      @cfg      = ConfigStruct.new
      @load     = true
      @load     = opts.delete(:load) if opts.has_key?(:load)
      @key_to_s = opts.delete(:key_to_s)
      raise UnknownOption, "option '#{opts}' not recognized" unless opts.empty?
      load :all if @load
    end

    # 加载配置文件
    def load_cfg(dir)
      @file = File.join dir, @cfg_file
      file  = File.read @file
      ConfigStruct.new(from(@adapter, file), key_to_s: @key_to_s)
    rescue Errno::ENOENT
      ConfigStruct.new
    end

    # 保存配置文件
    def save_cfg(dir, config)
      config = to(@adapter, config)
      file   = File.join dir, @cfg_file
      FileUtils.mkdir_p dir
      File.write file, config
    end

    # 合并配置属性
    def merge(*configs)
      hash = {}
      # 将相关配置依次迭代并转换为 RUBY HASH 对象
      configs.each do |config|
        hash = hash._config_deep_merge config._config_to_hash
      end
      # 将合并后的 HASH 数据结构转换为配置对象
      ConfigStruct.new hash
    end

    # 将 JSON|YAML|TOML 等数据格式转换为 RUBY 数据结构
    def from(adapter, string)
      name = "from_" + adapter
      send name, string
    end

    # 将 RUBY 数据结构转换为 JSON|YAML|TOML 对象
    def to(adapter, config)
      name = "to_" + adapter
      send name, config
    end

    # 基础的配置标致名称
    def meta_name
      path = caller_locations[-1].path
      File.basename path, File.extname(path)
    rescue
      raise NoName, "can't figure out name, specify explicitly"
    end
end

# 增加 HASH 方法
class Hash
  def _config_deep_merge(new_hash)
    merger = proc do |key, old_val, new_val|
      Hash === old_val && Hash === new_val ? old_val.merge(new_val, &merger) : new_val
    end
    merge new_hash, &merger
  end
end
