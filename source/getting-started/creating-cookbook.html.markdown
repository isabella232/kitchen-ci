## Creating a Cookbook

```
$ git init git-cookbook
$ cd git-cookbook
```

```ruby
name "git"
version "0.1.0"
```

```
$ mkdir recipes
$ touch recipes/default.rb
```

```
$ kitchen init --driver=kitchen-vagrant
      create  .kitchen.yml
      create  test/integration/default
      create  .gitignore
      append  .gitignore
      append  .gitignore
         run  gem install kitchen-vagrant from "."
Successfully installed kitchen-vagrant-0.11.1
1 gem installed
```

```yaml
---
driver_plugin: vagrant
driver_config:
  require_chef_omnibus: true

platforms:
- name: ubuntu-12.04

suites:
- name: default
  run_list: ["recipe[git]"]
  attributes: {}
```

```
$ kitchen list
Instance             Driver   Provisioner  Last Action
default-ubuntu-1204  Vagrant  Chef Solo    <Not Created>
```

```
$ kitchen create default-ubuntu-1204
-----> Starting Kitchen (v1.0.0.beta.3)
-----> Creating <default-ubuntu-1204>
       [kitchen::driver::vagrant command] BEGIN (vagrant up --no-provision)
       Bringing machine 'default' up with 'virtualbox' provider...
       [default] Importing base box 'opscode-ubuntu-12.04'...
       [default] Matching MAC address for NAT networking...
       [default] Setting the name of the VM...
       [default] Clearing any previously set forwarded ports...
       [default] Creating shared folders metadata...
       [default] Clearing any previously set network interfaces...
       [default] Preparing network interfaces based on configuration...
       [default] Forwarding ports...
       [default] -- 22 => 2222 (adapter 1)
       [default] Running 'pre-boot' VM customizations...
       [default] Booting VM...
       [default] Waiting for machine to boot. This may take a few minutes...
       [default] Machine booted and ready!
       [default] Setting hostname...
       [default] Mounting shared folders...
       [kitchen::driver::vagrant command] END (0m29.18s)
       [kitchen::driver::vagrant command] BEGIN (vagrant ssh-config)
       [kitchen::driver::vagrant command] END (0m0.84s)
       Vagrant instance <default-ubuntu-1204> created.
       Finished creating <default-ubuntu-1204> (0m33.02s).
-----> Kitchen is finished. (0m33.31s)
```

```
$ kitchen list
Instance             Driver   Provisioner  Last Action
default-ubuntu-1204  Vagrant  Chef Solo    Created
```
