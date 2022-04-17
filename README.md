# Strada

Configuration library for ruby with YAML/JSON/TOML backends with unified object access

## Install

```shell
 % gem install strada
```

## Use

### Simple

```ruby
require 'strada'
require 'pp'
cfg  = Strada.cfg
# print cfg datastructure
PP.pp cfg

port = cfg.server.port
user = cfg.auth.user
pw   = cfg.auth.password

PP.pp cfg
```

It tried to detect your software name via caller_locations if no ':name'
argument was given.
It automatically loads /etc/name/config and ~/.config/name/config and merges
them together.

### Advanced

```ruby
require 'strada'

Strada = Strada.new name:    'mykewlapp',
                    default: { 'poop' => 'xyzzy' },
                    adapter: 'yaml',
                    usrdir:  '/home/app/config/',
                    sysdir:  '/System/config/',
                    load:    false

Strada.default.poop2            = [1, 2, 3, 4]
Strada.default.starship.poopers = 42
Strada.load :user

if Strada.user.empty?
  Strada.user = Strada.default
  Strada.save :user
end

Strada.load # load+merges cfg, takes argument :default, :system, :user
Strada.cfg # merged default + system + user  (merged on load)
Strada.default # default only
Strada.system # system only
Strada.user # user only
```

## Reserved methods

* each - iterate all config keys in current level
* has_key?(arg)  - check if current level has key arg
* [arg]          - fetch arg (useful for non-literal retrieval, instead of using #send)
* key? - all keys have question mark version reserved, checks if key exists+true (true), exists+false (false),
  not-exists (nil)

+ all object class methods

## TODO

* should I add feature to raise on unconfigured/unset?
* should I always merge to 'cfg' when default/system/config is set?
  
