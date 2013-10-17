## Fixing Converge

```
$ cat .kitchen.yml
---
driver_plugin: vagrant
driver_config:
  require_chef_omnibus: true

platforms:
- name: ubuntu-12.04
- name: ubuntu-10.04
- name: centos-6.4

suites:
- name: default
  run_list: ["recipe[git]"]
  attributes: {}
```

```
$ kitchen list
Instance             Driver   Provisioner  Last Action
default-ubuntu-1204  Vagrant  Chef Solo    <Not Created>
default-ubuntu-1004  Vagrant  Chef Solo    <Not Created>
default-centos-64    Vagrant  Chef Solo    Verified
```

```
$ kitchen verify 10
-----> Starting Kitchen (v1.0.0.beta.3)
-----> Creating <default-ubuntu-1004>
       [kitchen::driver::vagrant command] BEGIN (vagrant up --no-provision)
       Bringing machine 'default' up with 'virtualbox' provider...
       [default] Importing base box 'opscode-ubuntu-10.04'...
       [default] Matching MAC address for NAT networking...
       [default] Setting the name of the VM...
       [default] Clearing any previously set forwarded ports...
       [default] Fixed port collision for 22 => 2222. Now on port 2200.
       [default] Creating shared folders metadata...
       [default] Clearing any previously set network interfaces...
       [default] Preparing network interfaces based on configuration...
       [default] Forwarding ports...
       [default] -- 22 => 2200 (adapter 1)
       [default] Running 'pre-boot' VM customizations...
       [default] Booting VM...
       [default] Waiting for machine to boot. This may take a few minutes...
       [default] Machine booted and ready!
       [default] Setting hostname...
       [default] Mounting shared folders...
       [kitchen::driver::vagrant command] END (0m43.78s)
       [kitchen::driver::vagrant command] BEGIN (vagrant ssh-config)
       [kitchen::driver::vagrant command] END (0m0.88s)
       Vagrant instance <default-ubuntu-1004> created.
       Finished creating <default-ubuntu-1004> (0m48.83s).
-----> Converging <default-ubuntu-1004>
-----> Installing Chef Omnibus (true)
       --2013-10-17 07:00:14--  https://www.opscode.com/chef/install.sh
       Resolving www.opscode.com...
       184.106.28.83
       Connecting to www.opscode.com|184.106.28.83|:443...
       connected.
HTTP request sent, awaiting response...        200 OK
       Length: 6790 (6.6K) [application/x-sh]
       Saving to: `STDOUT'

100%[======================================>] 6,790       --.-K/s   in 0s

       2013-10-17 07:00:14 (861 MB/s) - written to stdout [6790/6790]

       Downloading Chef  for ubuntu...
       Installing Chef
       Selecting previously deselected package chef.
(Reading database ... 60%...
(Reading database ... 44103 files and directories currently installed.)
       Unpacking chef (from .../tmp.87qtF6HZ/chef__amd64.deb) ...
       Setting up chef (11.6.2-1.ubuntu.10.04) ...
       Thank you for installing Chef!

       Preparing current project directory as a cookbook
       Removing non-cookbook files in sandbox
       Uploaded /var/folders/ld/ykg04kvx5y53v7qkhpp254y40000gn/T/default-ubuntu-1004-sandbox-20131017-65697-bf2e9c/cookbooks/git/metadata.rb (27 bytes)
       Uploaded /var/folders/ld/ykg04kvx5y53v7qkhpp254y40000gn/T/default-ubuntu-1004-sandbox-20131017-65697-bf2e9c/cookbooks/git/recipes/default.rb (45 bytes)
       Uploaded /var/folders/ld/ykg04kvx5y53v7qkhpp254y40000gn/T/default-ubuntu-1004-sandbox-20131017-65697-bf2e9c/dna.json (28 bytes)
       Uploaded /var/folders/ld/ykg04kvx5y53v7qkhpp254y40000gn/T/default-ubuntu-1004-sandbox-20131017-65697-bf2e9c/solo.rb (168 bytes)
       [2013-10-17T07:00:39+00:00] INFO: Forking chef instance to converge...
       Starting Chef Client, version 11.6.2
       [2013-10-17T07:00:39+00:00] INFO: *** Chef 11.6.2 ***
       [2013-10-17T07:00:40+00:00] INFO: Setting the run_list to ["recipe[git]"] from JSON
       [2013-10-17T07:00:40+00:00] INFO: Run List is [recipe[git]]
       [2013-10-17T07:00:40+00:00] INFO: Run List expands to [git]
       [2013-10-17T07:00:40+00:00] INFO: Starting Chef Run for default-ubuntu-1004
       [2013-10-17T07:00:40+00:00] INFO: Running start handlers
       [2013-10-17T07:00:40+00:00] INFO: Start handlers complete.
       Compiling Cookbooks...
       Converging 2 resources
       Recipe: git::default
         * package[git] action install[2013-10-17T07:00:40+00:00] INFO: Processing package[git] action install (git::default line 1)

       ================================================================================
       Error executing action `install` on resource 'package[git]'
       ================================================================================


       Chef::Exceptions::Package
       -------------------------
       git has no candidate in the apt-cache


       Resource Declaration:
       ---------------------
       # In /tmp/kitchen-chef-solo/cookbooks/git/recipes/default.rb

         1: package "git"
         2:



       Compiled Resource:
       ------------------
       # Declared in /tmp/kitchen-chef-solo/cookbooks/git/recipes/default.rb:1:in `from_file'

       package("git") do
         action :install
         retries 0
         retry_delay 2
         package_name "git"
         cookbook_name :git
         recipe_name "default"
       end



       [2013-10-17T07:00:40+00:00] INFO: Running queued delayed notifications before re-raising exception
       [2013-10-17T07:00:40+00:00] ERROR: Running exception handlers
       [2013-10-17T07:00:40+00:00] ERROR: Exception handlers complete
       [2013-10-17T07:00:40+00:00] FATAL: Stacktrace dumped to /tmp/kitchen-chef-solo/cache/chef-stacktrace.out
       Chef Client failed. 0 resources updated
       [2013-10-17T07:00:40+00:00] FATAL: Chef::Exceptions::ChildConvergeError: Chef run process exited unsuccessfully (exit code 1)
>>>>>> Converge failed on instance <default-ubuntu-1004>.
>>>>>> Please see .kitchen/logs/default-ubuntu-1004.log for more details
>>>>>> ------Exception-------
>>>>>> Class: Kitchen::ActionFailed
>>>>>> Message: SSH exited (1) for command: [sudo -E chef-solo --config /tmp/kitchen-chef-solo/solo.rb --json-attributes /tmp/kitchen-chef-solo/dna.json  --log_level info]
>>>>>> ----------------------
```
