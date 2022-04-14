# MojoConfig
Configuration library for ruby with YAML/JSON/TOML backends with unified object
access

## Install
```
 % gem install MojoConfig
```

## Use
### Simple
```
require 'MojoConfig'
cfg  = MojoConfig.cfg
port = cfg.server.port
user = cfg.auth.user
pw   = cfg.auth.password
```
It tried to detect your software name via caller_locations if no ':name'
argument was given.
It automatically loads /etc/name/config and ~/.config/name/config and merges
them together.

### Advanced
```
require 'MojoConfig'
MojoConfig = MojoConfig.new name:    'mykewlapp',
                    default: {'poop'=>'xyzzy'},
                    adapter: 'yaml',
                    usrdir:  '/home/app/config/',
                    sysdir:  '/System/config/',
                    load:    false
MojoConfig.default.poop2 = [1, 2, 3, 4]
MojoConfig.default.starship.poopers = 42
MojoConfig.load :user
if MojoConfig.user.empty?
  MojoConfig.user = MojoConfig.default
  MojoConfig.save :user
end
MojoConfig.load    # load+merges cfg, takes argument :default, :system, :user
MojoConfig.cfg     # merged default + system + user  (merged on load)
MojoConfig.default # default only
MojoConfig.system  # system only
MojoConfig.user    # user only
```

## Reserved methods

* each           - iterate all config keys in current level
* has_key?(arg)  - check if current level has key arg
* [arg]          - fetch arg (useful for non-literal retrieval, instead of using #send)
* key?           - all keys have question mark version reserved, checks if key exists+true (true), exists+false (false), not-exists (nil)
+ all object class methods

## TODO

  * should I add feature to raise on unconfigured/unset?
  * should I always merge to 'cfg' when default/system/config is set?
  
