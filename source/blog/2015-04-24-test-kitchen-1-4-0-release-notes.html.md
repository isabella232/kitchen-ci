---
title: Test Kitchen 1.4.0 Release Notes
date: 2015-04-24 01:00 UTC
author: Fletcher Nichol
tags: release-notes
---

For immediate release: [Test Kitchen 1.4.0](https://github.com/test-kitchen/test-kitchen/releases/tag/v1.4.0) is available on [RubyGems](https://rubygems.org/gems/test-kitchen).

READMORE


Sitting down? Good, this could take a few minutes to read through. Today we're releasing version 1.4.0 of Test Kitchen with a little something for everyone. We have an aggresively reworked plugin system including 2 new plugin concepts (Transport and Verifiers), improved SSH resiliency when instances are booting, first steps at SSH compression to make converges quicker, better HTTP proxy support, a fully realized Windows story, and more.

Let's dig in a little, shall we?

## Installing

If you have a Ruby workflow with RubyGems and/or Bundler this won’t be too much work:

Gem install with:

~~~sh
gem install test-kitchen --version "~> 1.4"
gem install kitchen-vagrant --version "~> 0.17"
gem install winrm-transport # only needed if you want to spin up Windows instances
~~~

To use in a project with Bundler, the following goes into your Gemfile:

~~~ruby
gem "test-kitchen", "~> 1.4"
gem "kitchen-vagrant", "~> 0.17"
gem "winrm-transport" # only needed if you want to spin up Windows instances
~~~

A ChefDK release is in the process of baking, and we'll update this section when it's ready.

## Windows!

Note that this release has the much-fabled "Windows guest support". How do you get started? At the moment getting Vagrant base box images of Windows is still a bit of a pain, but if you have access to one, here are the versions that should "just work":

- Windows Server 2012r2
- Windows Server 2012r2 Core (you will need .NET 4.5 installed however)
- Windows Server 2012 (your system/image must have the KB2842230 hotfix applied (https://support.microsoft.com/en-us/kb/2842230))
- Windows Server 2008r2
- Windows 8.1 Pro,Enterprise,etc.
- Windows 8 Pro,Enterprise,etc. (your system/image must have the KB2842230 hotfix applied (https://support.microsoft.com/en-us/kb/2842230))
- Windows 7

## Windows with Kitchen::Vagrant

The [kitchen-vagrant 0.17.0](https://github.com/test-kitchen/kitchen-vagrant/releases/tag/v0.17.0) release comes with awareness and support for spinning up Windows instances, so be sure to use this version or higher if Vagrant is your Driver of choice.

To make the WinRM host and port detection logic work, you will need to install one Vagrant plugin called `vagrant-winrm`. To install this, please run the following:

~~~sh
vagrant plugin install vagrant-winrm
~~~

|| Note
|| You do **not** want to prepend `bundle exec` or anything else; this is a Vagrant plugin and will be available to any future Vagrant projects on your workstation.

If you forget this step then don't worry, any `kitchen` command that needs it will prompt you like so:

~~~
kitchen list
>>>>>> ------Exception-------
>>>>>> Class: Kitchen::UserError
>>>>>> Message: WinRM Transport requires the vagrant-winrm Vagrant plugin to properly communicate with this Vagrant VM. Please install this plugin with: `vagrant plugin install vagrant-winrm' and try again.
>>>>>> ----------------------
>>>>>> Please see .kitchen/logs/kitchen.log for more details
>>>>>> Also try running `kitchen diagnose --all` for configuration
~~~

Run `vagrant plugin install vagrant-winrm` and try again.

Now, assuming you have a Vagrant base box called "windows-2012r2", you can use a .kitchen.yml similar to:

~~~yaml
---
driver:
  name: vagrant

platforms:
  - name: windows-2012r2

suites:
  - name: default
~~~

Note that with the updates in kitchen-vagrant you don’t need to set/override a `:box`, `:box_url`, `:communicator`, `:guest`, `:port`, `:username`, or `:password`. Sane defaults should apply.

For anyone who has tried the now defunct windows-guest-support branch, you may have seen extra transport configuration like this:

~~~yaml
---
driver:
  name: vagrant

platforms:
  - name: windows-2012r2
    transport:
      name: winrm

suites:
  - name: default
~~~

This is what Test Kitchen’s going to give you by default for any platform name starting with /^win/ (case insensitive) so add it, or don’t, it should work either way. If you don’t believe me, run `kitchen diagnose` against both and note the difference :)

Any Vagrant base box should have `vm.communicator = “winrm”` and `vm.guest = “windows”` set by default, otherwise `vagrant up` will not be able to correctly boot the VM. Note that there are some Windows base boxes out there with `vm.communicator = “ssh”` set, so plan accordingly.

## Building Windows Vagrant Boxes

Due to Microsoft's EULA restrictions, it isn't currently possible to distribute Windows Vagrant boxes--even if they are evaluation versions from publically downloadible ISO images. This leaves us with the task of building the boxes ourselves, but thankfully [Packer](https://packer.io/) makes this a good deal easier.

To test the functionality of Test Kitchen in development, the [boxcutter/windows](https://github.com/boxcutter/windows) was used to create various Windows box versions. You will need [Packer](https://packer.io/downloads.html) installed but should work on most operating systems. For example, here's how you can build your own Windows Server 2012r2 evaluation box using Boxcutter:

~~~sh
git clone https://github.com/boxcutter/windows.git
cd windows
make vmware/eval-win2012r2-standard
~~~

Note that on my 13" MacBook Retina the download-to-built time was 44 minutes. Long, but not bad considering.

Finally, add the build box to Vagrant, calling it `"windows-2012r2"` (a box starting with "win" will help Test Kitchen do the right thing out of the box):

~~~sh
vagrant box add windows-2012r2 ./box/vmware/eval-win2012r2-standard-nocm-1.0.4.box
~~~

Also note that the [joefitzgerald/packer-windows](https://github.com/joefitzgerald/packer-windows) also creates a wide variety of Windows Vagrant boxes and may be more your speed if looking for alternatives.

## Windows Test Flight

Now that we have a Windows box, let's try it out! This example uses [ChefDK](https://downloads.chef.io/chef-dk/) to generate a cookbook:

~~~sh
chef generate cookbook hello
cd hello
~~~

Next, we'll edit the `.kitchen.yml` file to use a single platform--Windows 2012r2:

~~~yaml
---
driver:
  name: vagrant

provisioner:
  name: chef_zero

platforms:
  - name: windows-2012r2

suites:
  - name: default
    run_list:
      - recipe[hello::default]
~~~

Finally, let's add a simple [log resource](http://docs.chef.io/resource_log.html) into our default recipe:

~~~sh
echo 'log "Hello, Windows"' >> recipes/default.rb
~~~

You should now be able to run `kitchen list`:

~~~sh
kitchen list
~~~

and see our single instance, using the WinRM transport:

~~~
Instance                Driver   Provisioner  Verifier  Transport  Last Action
default-windows-2012r2  Vagrant  ChefZero     Busser    Winrm      <Not Created>
~~~

Why not give this a spin while we're at it?

~~~sh
kitchen test
~~~

You'll see something like the following:

~~~
-----> Starting Kitchen (v1.4.0)
-----> Cleaning up any prior instances of <default-windows-2012r2>
-----> Destroying <default-windows-2012r2>...
       Finished destroying <default-windows-2012r2> (0m0.00s).
-----> Testing <default-windows-2012r2>
-----> Creating <default-windows-2012r2>...
       Bringing machine 'default' up with 'vmware_fusion' provider...
       ==> default: Cloning VMware VM: 'windows-2012r2'. This can take some time...
       ==> default: Verifying vmnet devices are healthy...
       ==> default: Preparing network adapters...
       ==> default: Starting the VMware VM...
       ==> default: Waiting for machine to boot. This may take a few minutes...
       ==> default: Machine booted and ready!
       ==> default: Forwarding ports...
           default: -- 3389 => 3389
           default: -- 5985 => 5985
           default: -- 22 => 2222
       ==> default: Configuring network adapters within the VM...
       ==> default: Configuring secondary network adapters through VMware
       ==> default: on Windows is not yet supported. You will need to manually
       ==> default: configure the network adapter.
       ==> default: Machine not provisioning because `--no-provision` is specified.
       [WinRM] Established
       Vagrant instance <default-windows-2012r2> created.
       Finished creating <default-windows-2012r2> (1m3.04s).
-----> Converging <default-windows-2012r2>...
       Preparing files for transfer
       Preparing dna.json
       Resolving cookbook dependencies with Berkshelf 3.2.3...
       Removing non-cookbook files before transfer
       Preparing validation.pem
       Preparing client.rb
-----> Installing Chef Omnibus (install only if missing)
       Downloading package from https://opscode-omnibus-packages.s3.amazonaws.com/windows/2008r2/x86_64/chef-client-12.2.1-1.msi
       Download complete.
       Successfully verified C:\Users\vagrant\AppData\Local\Temp\chef-true.msi

       Installing Chef Omnibus package C:\Users\vagrant\AppData\Local\Temp\chef-true.msi
       Installation complete
       Transferring files to <default-windows-2012r2>
       Starting Chef Client, version 12.2.1
       Creating a new client identity for default-windows-2012r2 using the validator key.
       [2015-04-27T13:58:06-07:00] WARN: Child with name 'dna.json' found in multiple directories: C:/Users/vagrant/AppData/Local/Temp/kitchen/dna.json and C:/Users/vagrant/AppData/Local/Temp/kitchen/dna.json
       [2015-04-27T13:58:06-07:00] WARN: Child with name 'dna.json' found in multiple directories: C:/Users/vagrant/AppData/Local/Temp/kitchen/dna.json and C:/Users/vagrant/AppData/Local/Temp/kitchen/dna.json
       resolving cookbooks for run list: ["hello::default"]
       [2015-04-27T13:58:06-07:00] WARN: Child with name 'dna.json' found in multiple directories: C:/Users/vagrant/AppData/Local/Temp/kitchen/dna.json and C:/Users/vagrant/AppData/Local/Temp/kitchen/dna.json
       Synchronizing Cookbooks:
         - hello
       Compiling Cookbooks...
       Converging 1 resources
       Recipe: hello::default
         * log[Hello, Windows] action write


       Running handlers:
       Running handlers complete
       Chef Client finished, 1/1 resources updated in 13.486613 seconds
       Finished converging <default-windows-2012r2> (2m25.94s).
-----> Setting up <default-windows-2012r2>...
       Finished setting up <default-windows-2012r2> (0m0.00s).
-----> Verifying <default-windows-2012r2>...
       Preparing files for transfer
-----> Installing Busser (busser)
       Successfully installed thor-0.19.0
       Successfully installed busser-0.7.1
       2 gems installed
-----> Setting up Busser
       Creating BUSSER_ROOT in C:\Users\vagrant\AppData\Local\Temp\verifier
       Creating busser binstub
       Installing Busser plugins: busser-serverspec
       Plugin serverspec installed (version 0.5.6)
-----> Running postinstall for serverspec plugin
       Suite path directory C:/Users/vagrant/AppData/Local/Temp/verifier/suites does not exist, skipping.
       Transferring files to <default-windows-2012r2>
-----> Running serverspec test suite
-----> Installing Serverspec..
-----> serverspec installed (version 2.14.1)

       hello::default
         does something (PENDING: Replace this with meaningful tests)

       Pending: (Failures listed here are expected and do not affect your suite's status)

         1) hello::default does something
            # Replace this with meaningful tests
            # ./AppData/Local/Temp/verifier/suites/serverspec/default_spec.rb:8

       Finished in 0 seconds (files took 0.45317 seconds to load)
       1 example, 0 failures, 1 pending

       C:/opscode/chef/embedded/bin/ruby.exe -IC:/Users/vagrant/AppData/Local/Temp/verifier/suites/serverspec -I'C:/Users/vagrant/AppData/Local/Temp/verifier/gems/gems/rspec-support-3.2.2/lib';'C:/Users/vagrant/AppData/Local/Temp/verifier/gems/gems/rspec-core-3.2.3/lib' 'C:/Users/vagrant/AppData/Local/Temp/verifier/gems/gems/rspec-core-3.2.3/exe/rspec' --pattern 'C:/Users/vagrant/AppData/Local/Temp/verifier/suites/serverspec/**/*_spec.rb' --color --format documentation --default-path C:/Users/vagrant/AppData/Local/Temp/verifier/suites/serverspec
       Finished verifying <default-windows-2012r2> (5m28.08s).
-----> Destroying <default-windows-2012r2>...
       ==> default: Stopping the VMware VM...
       ==> default: Deleting the VM...
       Vagrant instance <default-windows-2012r2> destroyed.
       Finished destroying <default-windows-2012r2> (0m10.99s).
       Finished testing <default-windows-2012r2> (9m8.07s).
-----> Kitchen is finished. (9m10.23s)
~~~

You might notice that the `verify` action takes over 50% of the run time… we have some ideas here, so stay tuned ;)

In the meantime, happy Windows testing!

![Confetti Party](blog/test-kitchen-1-4-0-release-notes/confetti.gif)

Let’s take a peek at some of the other highlights…

## Other Highlights

### Self-Aware Provisioners

This feature introduces a `#call(state)` method which exists in `Kitchen::Provisioner::Base` which will be invoked by Test Kitchen when the converge action is performed. For backwards compatibility, the same convergence "template" is used, relying on a small number of public methods that return command strings and 3 methods responsible for sandbox creation and cleanup.

The high-level description of the default `#call(state)` method is as follows:

1. Create the temporary sandbox on the workstation with "stuff" to transfer to the remote instance.
2. Run the `#install_command` on the remote instance, if it is implemented.
3. Run the `#init_command` on the remote instance, if it is implemented.
4. Transfer all files in the sandbox path to the remote instance's configured `:root_path`.
5. Run the `#prepare_command` on the remote instance, if it is implemented.
6. Run the `#run_command` on the remote instance, if it is implemented.

As a Provisioner author, you may elect to overwrite or partially re-implement the `#call(state)` method to do whatever you need in whatever order makes sense. This key difference allows Provisioner authors to entirely own the `kitchen converge` action and not rely on the Driver.

### (Potentially Breaking) Provisioners responsible for converge action

This is potentially breaking to Driver authors if all of the following are true:

* Your Driver currently directly inherits from `Kitchen::Driver::Base`
* Your Driver implements/overrides the `#converge` method

Put another way, your Driver may have issues if it looks like the following:

~~~ruby
module Kitchen
  module Driver
    class MyDriver < Kitchen::Driver::Base
      def converge(state)
        # custom converge work
      end
    end
  end
end
~~~

For the vast majority of open source Drivers in the wild, current behavior is maintained as they all inherit from `Kitchen::Driver::SSHBase`. This class has been cemented to preserve its current behavior, and Test Kitchen will invoke the `#converge` method for these Drivers.

A future deprecation process may remove the `SSHBase` backwards compatibility, but not without plenty of lead time and warning. Due to the constraints of semantic versioning, by definition, this wouldn't occur before a 2.x codebase release.

### (Potentially Breaking) Transports responsible for login action

This is potentially breaking to Driver authors if all of the following are true:

* Your Driver currently inherits from `Kitchen::Driver::Base`
* Your Driver implements/overrides the `#login_command` method

Put another way, your Driver may have issues if it looks like the following:

~~~ruby
module Kitchen
  module Driver
    class MyDriver < Kitchen::Driver::Base
      def login_command(state)
        # custom converge work
      end
    end
  end
end
~~~

For the vast majority of open source Drivers in the wild, current behavior is maintained as they all inherit from `Kitchen::Driver::SSHBase`. This class has been cemented to preserve its current behavior, and Test Kitchen will invoke the `#login_command` method for these Drivers.

### Self-Aware Verifiers

This feature introduces a `#call(state)` method which exists in `Kitchen::Verifier::Base` which will be invoked by Test Kitchen when the verify action is performed. The setup action which previously installed the Busser gem and plugins, becomes a dummy or "no-op" action. In other words all previous behavior in the setup action now takes place in the verify action. For backwards compatibility, the same verify "template" is used, relying on a small number of public methods that return strings and 3 new methods responsible for sandbox creation and cleanup (with a very similar implementation to that in Provisioners).

The high-level description of the default `#call(state)` method is as follows:

1. Create the temporary sandbox on the workstation with "stuff" to transfer to the remote instance.
2. Run the `#install_command` on the remote instance, if it is implemented.
3. Run the `#init_command` on the remote instance, if it is implemented.
4. Transfer all files in the sandbox path to the Verifier's configured `:root_path` on the remote instance.
5. Run the `#prepare_command` on the remote instance, if it is implemented.
6. Run the `#run_command` on the remote instance, if it is implemented.

As a Verifier author, you may elect to overwrite or partially re-implement the `#call(state)` method to do whatever you need in whatever order makes sense. This key difference allows Verifier authors to entirely own the `kitchen verify` action and not rely on the Driver.

### (Potentially Breaking) Verifiers responsible for verify action

This is a potentially breaking change to Driver authors if all of the following are true:

* Your Driver currently directly inherits from `Kitchen::Driver::Base`
* Your Driver implements/overrides the `#setup` and/or `#verify` methods

Put another way, your Driver may have issues if it looks like the following:

~~~ruby
module Kitchen
  module Driver
    class MyDriver < Kitchen::Driver::Base
      def setup(state)
        # custom setup work
      end

      def verify(state)
        # custom verify work
      end
    end
  end
end
~~~

For the vast majority of open source Drivers in the wild, current behavior is maintained as they all inherit from `Kitchen::Driver::SSHBase`. This class has been cemented to preserve its current behavior, and Test Kitchen will invoke the `#setup` and `#verify` methods for these Drivers.

### Add Platform `:os_type` for instance path type hinting

A new configurable attribute is introduced to a Platform entry called `:os_type`. For example:

~~~yaml
---
driver:
  name: docker

provisioner:
  name: chef_zero

platforms:
  - name: ubuntu-14.04
    os_type: unix
  - name: windows-8.1
    os_type: windows
~~~

The interpretation of `:os_type` is very narrowly defined as follows:

* `"windows"` means a Windows operating system, requiring Windows paths such as `"C:\\Users"`, `"$env:TEMP\\stuff"`, or `"%TEMP%\\more"`.
* `"unix"` means a non-Windows operating system, or UNIX derivative--the implication is essentially the same. This implies unix-style paths such as `"some/path/"` or "`/absolute/paths/are/nice`".
* `nil` or unset will default to meaning `"unix"` to ensure backwards compatibility if values are somehow not properly passed in.
* Any other value will be passed down into the system, and allows for some future operating system support or a flag for bizarre custom behavior. This part is where dragons live.

### Add remote host `:shell_type` hinting support

Platform has a new method `#shell_type` which will normally return either `"powershell"` or `"bourne"` depending on the pre-declared capabilities of the remote instance. The implicit default will be `"bourne"` for backwards compatibility.

### Add `:sudo_command` to Provisioners, Verifiers, & ShellOut

In an effort to better support older distributions (such as CentOS 5), and other distributions which don't ship with sudo in `$PATH` (such as Solaris), a new configuration attribute is introduced into `Provisioner::Base` and `Verifier::Base` called `:sudo_command`. For greatest portability and backwards compatibility this defaults to `"sudo -E"` but is now customizable depending on your situation.

For example:

~~~yaml
---
driver:
  name: vagrant

platforms:
  - name: centos-7.0                      # defaults apply
  - name: centos-5.11                     # removes -E flag
    provisioner:
      sudo_command: sudo
    verifier:
      sudo_command: sudo
  - name: solaris-10                      # sets custom path to sudo
    provisioner:
      sudo_command: /usr/local/bin/sudo
    verifier:
      sudo_command: /usr/local/bin/sudo
~~~

Note that a future feature proposes a way to remove the provisioner/verifier duplication but this would only be a convenience, not a behavior change.

Finally, `Driver::Base` was not augmented with this configuration attribute as it is no longer responsible for creating the commands to execute on remote instances--this is now solely the purview of Provisioner and Verifier plugins.

### Add plugin diagnostics, exposed via `kitchen diagnose`

This feature adds a new flag to `kitchen diagnose`: `--plugins` which adds a `:plugins` hash to the diagnostic output. It is the unique set of all loaded Driver, Provisioner, Verifier, and Transport plugins which is keyed by the `#name` of the plugin.

For example, a .kitchen.yml with the following configuration:

~~~yaml
---
driver:
  name: vagrant

provisioner:
  name: chef_zero

verifier:
  name: dummy

platforms:
  - name: ubuntu-14.04
    transport:
      name: ssh
  - name: centos-7.0
    driver:
      name: docker
    transport:
      name: ssh
  - name: windows-2012r2-core
    transport:
      name: winrm
~~~

with an invocation of `kitchen diagnose --plugins` would produce a diagnostic output similar to:

~~~yaml
---
timestamp: 2015-03-28 00:43:32 UTC
kitchen_version: 1.4.0.dev
plugins:
  driver:
    Docker:
      class: Kitchen::Driver::Docker
    Vagrant:
      class: Kitchen::Driver::Vagrant
  provisioner:
    ChefZero:
      class: Kitchen::Provisioner::ChefZero
  transport:
    Ssh:
      class: Kitchen::Transport::Ssh
    Winrm:
      class: Kitchen::Transport::Winrm
  verifier:
    Dummy:
      class: Kitchen::Verifier::Dummy
~~~

### Add `:keepalive` & `:keepalive_interval` attributes to SSH Transport

By default, keepalive packets are enabled with a 60-second interval. Both of these settings are configurable in a transport block, such as:

~~~yaml
---
driver:
  name: vagrant

provisioner:
  name: chef_zero

transport:
  name: ssh
  keepalive: true
  keepalive_interval: 5

platforms:
  - name: ubuntu-14.04

suites:
  - name: default
~~~

### Add default `:compression` & `:compression_level` attributes to SSH Transport

There are 2 new configuration attributes for all SSH Transports:

* `:compression` - can be set to `"zlib"` or `"none"`, default is `"zlib"`
* `:compression_level` - can be set to a number between 0 and 9 where 0 is uncompressed and 9 is maximum compression, default is `9`

These values are passed directly into the [net-ssh](https://github.com/net-ssh/net-ssh/blob/95e2a9404957517061492d880ed7278700e9ad2c/lib/net/ssh.rb#L106-L108) library when being invoked.

### Increased HTTP proxy support for executing commands

This release also added more a complete strategy for HTTP proxy variable setting. If both `:http_proxy` and `:https_proxy` are set, then the following Bourne shell environment variables are exported:

* `http_proxy`
* `HTTP_PROXY`
* `https_proxy`
* `HTTPS_PROXY`

And the following PowerShell environment variables are set:

* `$env:http_proxy`
* `$env:HTTP_PROXY`
* `$env:https_proxy`
* `$env:HTTPS_PROXY`

These environment variables will be set for every command executed in the Chef-related and Shell Provisioners, as well as the Busser Verifier.

The Bourne shell environment variable setting has also changed. Previously they were set with an `env` prepended to the `sh -c '...'` wrapped command. Now these environment variables are set inside the `sh -c '...'` at the top and are exported.

For example running `wget "http://chef.io/chef/install.sh"` with `:http_proxy` and `:https_proxy` set would generate a command similar to:

~~~bash
sh -c '
http_proxy="http://proxy"; export http_proxy
HTTP_PROXY="http://proxy"; export HTTP_PROXY
https_proxy="https://proxy"; export https_proxy
HTTPS_PROXY="https://proxy"; export HTTPS_PROXY

wget "http://chef.io/chef/install.sh"
'
~~~

### Add API versioning metadata to all plugin types

New in this release is a new metadata field for each type of plugin (Drivers, Provisioners, Verifiers, and Transports).

* Drivers have a `kitchen_driver_api_version` class method
* Provisioners have a `kitchen_provisioner_api_version` class method
* Verifiers have a `kitchen_verifier_api_version` class method
* Transports have a `kitchen_transport_api_version` class method

All existing plugins in the wild will have a `nil` value by default which will be treated the same way as version `1`.

* The newer style Drivers, shipping in the 1.4.0 release will be version 2 of the Driver API.
* The newer style Provisioners, shipping in the 1.4.0 release will be version 2 of the Provisioner API.
* All Transports are at version 1 of the API as they are a new abstraction.
* All Verifiers are at version 1 of the API as they are a new abstraction.

### Support symbol values in solo.rb (chef_solo) & client.rb (chef_zero)

This allows for settings such as the following to serialize correctly into `client.rb` or `solo.rb` (depending on the Provisioner). For example:

~~~yaml
---
driver:
  name: vagrant

provisioner:
  name: chef_zero
  client_rb:
    ssl_verify_mode: :verify_none

platforms:
  - name: centos-7.0

suites:
  - name: default
~~~

### Add `:chef_metadata_url` to Chef Provisioners for Windows installs

This configuration attribute is only used for Windows-based platforms and computes a suitable default based on:

* The base of the value of `:chef_omnibus_url`
* The version information in `:require_chef_omnibus`
* Any project info given in `:chef_omnibus_install_options`

For example, given the following YAML fragment:

~~~yaml
---
provisioner:
  name: chef_zero
  require_chef_omnibus: 12.1

platforms:
  - name: windows-8
~~~

The value of `:chef_metadata_url` would be:

~~~
https://www.chef.io/chef/metadata?p=windows&m=x86_64&pv=2008&v=12.1
~~~

To install ChefDK:

~~~yaml
---
provisioner:
  name: chef_zero
  require_chef_omnibus: 0.4
  chef_omnibus_install_options: -P chefdk

platforms:
  - name: windows-8
    provisioner:
      chef_omnibus_root: $env:systemdrive\opscode\chefdk
~~~

Would produce a `:chef_metadata_url` value of:

~~~
https://www.chef.io/chef/metadata-chefdk?p=windows&m=x86_64&pv=2008&v=0.4
~~~

### (Backwards Compatibility) Backfilling Transport support for Driver::SSHBase

A lot of work has been done to provide backwards compatibility for the SSHBase Driver superclass upon which most existing drivers are based. The `Kitchen::SSH` object is swapped out for a newly-wired Transport which for the moment is assumed to be `Transport::Ssh`. No existing methods are removed, no existing method signatures are modified. There are 3 remaining methods which are meant to be used with `Kitchen::SSH`:

* `#run_remote` uses a `Kitchen::SSH` connection and rescues the relevant exceptions
* `#transfer_path` also uses a `Kitchen::SSH` connection and rescues the relevant exceptions
* `#build_ssh_args` returns an Array structure used to populate the `Kitchen::SSH` constructor

These above methods are preserved as-is for Driver subclasses which may call them.

### (Backwards Compatibility) Preserve Busser's `#setup_cmd`, `#run_cmd`, & `#sync_cmd`

Here are the implementation details for these methods (intended only to preserve behavior for external code that directly invoke old Busser methods):

* `#setup_cmd` - will call `#install_command` to preserve behavior
* `#run_cmd` - will call `#run_command` to preserve behavior
* `#sync_cmd` - will log a warning message to the end user to let them know that this method no longer transfers files

There are (hopefully) very few instances where custom code will directly invoke these methods, but they are here just in case.

## Full Changleog

(*This is a selected roll-up of 1.4.0 pre-release [changelogs](https://github.com/test-kitchen/test-kitchen/blob/master/CHANGELOG.md)*)

### Potentially breaking changes

**Note::** while a huge amount of effort has gone into preserving backwards compatibility, there could be issues when running this release using certain Drivers and Provisioners, especially ones that are deeply customized. Drivers that inherit directly from `Kitchen::Driver::Base` may need to be updated, while Driver that inherit directly from `Kitchen::Driver::SSHBase` should continue to operate as before. Other libraries/addons/plugins which patch internals of Test Kitchen's code may break or work differently and would be extremely hard to preserve while adding new functionality. Sadly, this is a tradeoff.

* Drivers are no longer responsible for `converge`, `setup`, `verify`, and `login` actions. The updated Driver API contract ([Driver::Base](https://github.com/test-kitchen/test-kitchen/blob/master/lib/kitchen/driver/base.rb)) only requires implementing the `#create` and `#destroy` methods, same as before. However, for Drivers that directly inherit from `Kitchen::Driver::Base`, any custom `#converge`, `#setup`, `#verify`, or `#login_command` methods will no longer be called. ([@fnichol][])
* Drivers which inherit directly from `Kitchen::Driver::SSHBase` are now considered "Legacy Drivers" as further improvements for these Drivers may not be available in future releases. The previous behavior is preserved, i.e. the Driver's `#converge`, `#setup`, and `#verify` methods are called and all methods signatures (and relative behavior) is preserved. ([Driver::SSHBase](https://github.com/test-kitchen/test-kitchen/blob/master/lib/kitchen/driver/ssh_base.rb), [Commit notes](https://github.com/test-kitchen/test-kitchen/commit/d816d6fd1bd21548b485ca91e0ff9303e99a6fbc)) ([@fnichol][])
* Provisioners are now self-aware, completely owning the `converge` action. The original public methods of the Base Provisioner are maintained but are now invoked with a `#call(state)` method on the Provisioner object. Provisioner authors may elect to implement the command and sandbox methods, or re-implement the `#call` method which may not call any of the previously mentioned methods. ([Provisioner::Base](https://github.com/test-kitchen/test-kitchen/blob/master/lib/kitchen/provisioner/base.rb), [Commit notes](https://github.com/test-kitchen/test-kitchen/commit/3196675e519a2fb97af4bcac80ef11f5e37f2537)) ([@fnichol][])
* Transport are not responsible for the `login` command. ([Commit notes](https://github.com/test-kitchen/test-kitchen/commit/ae360a11d8c18ff5d1086ee19b099db1d0422024)) ([@fnichol][])
* Busser is now a plugin of type Verifier (see below for details on Verifiers). Any external code that directly creates a `Kitchen::Busser` object will fail as the class has moved to `Kitchen::Verifier::Busser`. Any external code that directly invokes Busser's `#sync_cmd` will log a warning and will **not** transfer test files (authors of plugins may now call `instance.transport(state).upload(locals, remote)` in its place). ([@fnichol][])
* Verifiers are responsible for the `verify` action. ([Commit notes](https://github.com/test-kitchen/test-kitchen/commit/d62f577003c1920259eb627cc4479c0b21e0c374)) ([@fnichol][])
* Pull request [#649][]: Preserve Busser's #setup_cmd, #run_cmd, & #sync_cmd for better backwards compatibility. ([@fnichol][])
* Pull request [#672][]: Extract WinRM-dependant code from Transport::Winrm into the winrm-transport gem, meaning that WinRM support is now a soft dependency of Test Kitchen, similar to Berkshelf and Librarian-Chef. This means the first time a Winrm Transport is requested, a `kitchen` command will crash with a UserError message instructing the user to install the winrm-transport gem. Existing projects which do not use the Winrm Transport will be unaffected and have no extra gem dependencies to manage. ([@fnichol][])

### Bug fixes

* Issue [#611][], pull request [#673][]: Ensure that secret key is deleted before converge for chef_zero and chef_solo Provisioners. ([@fnichol][])
* Issue [#389][], pull request [#674][]: Expand path for `:ssh_key` if provided in kitchen.yml for Ssh Transport. ([@fnichol][])
* Pull request [#653][]: Consider `:require_chef_omnibus = 11` to be a modern version for Chef Provisioners. ([@fnichol][])

### New features

* ChefZero Provisioner supports Windows paths and PowerShell commands and works with the WinRM Transport (default behavior for Platform names starting with `/^win/`). ([Provisioner::ChefZero](https://github.com/test-kitchen/test-kitchen/blob/master/lib/kitchen/provisioner/chef_zero.rb)) ([@fnichol][])
* ChefSolo Provisioner supports Windows paths and PowerShell commands and works with the WinRM Transport (default behavior for Platform names starting with `/^win/`). ([Provisioner::ChefSolo](https://github.com/test-kitchen/test-kitchen/blob/master/lib/kitchen/provisioner/chef_solo.rb)) ([@fnichol][])
* Shell Provisioner supports PowerShell scripts in addition to Bourne shell scripts ([Provisioner::Shell](https://github.com/test-kitchen/test-kitchen/blob/master/lib/kitchen/provisioner/shell.rb)) ([@fnichol][])
* Platform operating system and shell hinting: By default, Windows platform names (case insensitive platform names starting with `/^win/`) will have `:os_type` set to `"windows"` and `:shell_type` set to `"powershell"`. By default, non-Windows platform names will have `:os_type` set to `"unix"` and `:shell_type` set to `"bourne"`. The methods `#windows_os?`, `#unix_os?`, `#powershell_shell?`, `#bourne_shell?`, and `#remote_path_join` are available for all Driver, Provisioner, Verifier, and Transport authors. ([@fnichol][])
* New plugin type: Transport, which executes commands and transfers files to remote instances. ([Transport::Base](https://github.com/test-kitchen/test-kitchen/blob/master/lib/kitchen/transport/base.rb)) ([@afiune][], [@mwrock][], [@fnichol][])
* New Transport: WinRM: which re-uses a remote shell to execute commands and upload files over WinRM. Currently non-SSL/plaintext authentication only. ([Transport::Winrm](https://github.com/test-kitchen/test-kitchen/blob/master/lib/kitchen/transport/winrm.rb)) ([@afiune][], [@mwrock][], [@fnichol][])
* New Transport: SSH, which re-uses one SSH connection where possible. Improvements such as keepalive, retries, and further configuration attributes are included. This replaces the more general `Kitchen:SSH` class, which remains in the codebase for plugins that call this class directly. ([Transport::Ssh](https://github.com/test-kitchen/test-kitchen/blob/master/lib/kitchen/transport/ssh.rb)) ([@fnichol][])
* New plugin type: Verifier, which executes post-convergence tests on the instance. Busser is now a Verifier. ([Verifier::Base](https://github.com/test-kitchen/test-kitchen/blob/master/lib/kitchen/verifier/base.rb)) ([@fnichol][])
* Add [API versioning](d8f1a7db9e506c44f321462e1fba0b1e24994070) metadata to all plugin types. ([@fnichol][])
* Pull request [#667][], pull request [#668][]: Add plugin diagnostics, exposed via `kitchen diagnose`. ([@fnichol][])
* Pull request [#675][], issue [#424][]: Add default `:compression` & `:compression_level` configuration attributes to Ssh Transport.
* Pull request [#651][], issue [#592][], issue [#629][], issue [#307][]: Add :sudo_command to Provisioners, Verifiers, & ShellOut. ([@fnichol][])

#### Improvements

* In addition to supporting setting `http_proxy` and `https_proxy` environment variables when `:http_proxy` and `:https_proxy` are set in Provisioner and Verifier blocks, `HTTP_PROXY` and `HTTPS_PROXY` environment variables will also be set/exported in ChefZero/ChefSolo Provisioners and Busser Verifier. ([@fnichol][])
* Pull request [#600][], pull request [#633][], issue [#85][]: Add `--log-overwrite` flag to CLI anywhere `--log-level` is accepted.  By default it is true and will clear out the log every time Test Kitchen runs. To disable this behavior pass `--log-overwrite=false` or `--no-log-overwrite`.  You can also configure this with the environment variable `KITCHEN_LOG_OVERWRITE`. ([@tyler-ball][])
* Refactor "non-trivial" (i.e. more than a line or two) Bourne and PowerShell code bodies into static files under support/ for better code review by domain experts. ([@fnichol][])
* Pull request [#530][], issue [#429][]: Stop uploading empty directories. ([@whiteley][])
* Pull request [#588][]: Change getchef.com to chef.io in ChefZero and ChefSolo Provisioners. ([@jdmundrawala][])
* Pull request [#658][], issue [#654][]: Updated for sh compatibility based on install.sh code which supports more platforms including Solaris. ([@scotthain][], [@curiositycasualty][], [@fnichol][])
* Pull request [#652][], pull request [#666][], issue [#556][]: Support symbol values in solo.rb & client.rb for chef_zero and chef_solo Provisioners. ([@fnichol][])


[#20]: https://github.com/test-kitchen/test-kitchen/issues/20
[#31]: https://github.com/test-kitchen/test-kitchen/issues/31
[#61]: https://github.com/test-kitchen/test-kitchen/issues/61
[#64]: https://github.com/test-kitchen/test-kitchen/issues/64
[#65]: https://github.com/test-kitchen/test-kitchen/issues/65
[#71]: https://github.com/test-kitchen/test-kitchen/issues/71
[#73]: https://github.com/test-kitchen/test-kitchen/issues/73
[#74]: https://github.com/test-kitchen/test-kitchen/issues/74
[#76]: https://github.com/test-kitchen/test-kitchen/issues/76
[#77]: https://github.com/test-kitchen/test-kitchen/issues/77
[#80]: https://github.com/test-kitchen/test-kitchen/issues/80
[#81]: https://github.com/test-kitchen/test-kitchen/issues/81
[#82]: https://github.com/test-kitchen/test-kitchen/issues/82
[#84]: https://github.com/test-kitchen/test-kitchen/issues/84
[#85]: https://github.com/test-kitchen/test-kitchen/issues/85
[#90]: https://github.com/test-kitchen/test-kitchen/issues/90
[#92]: https://github.com/test-kitchen/test-kitchen/issues/92
[#94]: https://github.com/test-kitchen/test-kitchen/issues/94
[#97]: https://github.com/test-kitchen/test-kitchen/issues/97
[#98]: https://github.com/test-kitchen/test-kitchen/issues/98
[#99]: https://github.com/test-kitchen/test-kitchen/issues/99
[#102]: https://github.com/test-kitchen/test-kitchen/issues/102
[#104]: https://github.com/test-kitchen/test-kitchen/issues/104
[#105]: https://github.com/test-kitchen/test-kitchen/issues/105
[#108]: https://github.com/test-kitchen/test-kitchen/issues/108
[#111]: https://github.com/test-kitchen/test-kitchen/issues/111
[#112]: https://github.com/test-kitchen/test-kitchen/issues/112
[#113]: https://github.com/test-kitchen/test-kitchen/issues/113
[#114]: https://github.com/test-kitchen/test-kitchen/issues/114
[#116]: https://github.com/test-kitchen/test-kitchen/issues/116
[#119]: https://github.com/test-kitchen/test-kitchen/issues/119
[#120]: https://github.com/test-kitchen/test-kitchen/issues/120
[#122]: https://github.com/test-kitchen/test-kitchen/issues/122
[#123]: https://github.com/test-kitchen/test-kitchen/issues/123
[#124]: https://github.com/test-kitchen/test-kitchen/issues/124
[#128]: https://github.com/test-kitchen/test-kitchen/issues/128
[#129]: https://github.com/test-kitchen/test-kitchen/issues/129
[#131]: https://github.com/test-kitchen/test-kitchen/issues/131
[#132]: https://github.com/test-kitchen/test-kitchen/issues/132
[#134]: https://github.com/test-kitchen/test-kitchen/issues/134
[#136]: https://github.com/test-kitchen/test-kitchen/issues/136
[#137]: https://github.com/test-kitchen/test-kitchen/issues/137
[#140]: https://github.com/test-kitchen/test-kitchen/issues/140
[#141]: https://github.com/test-kitchen/test-kitchen/issues/141
[#142]: https://github.com/test-kitchen/test-kitchen/issues/142
[#147]: https://github.com/test-kitchen/test-kitchen/issues/147
[#151]: https://github.com/test-kitchen/test-kitchen/issues/151
[#152]: https://github.com/test-kitchen/test-kitchen/issues/152
[#153]: https://github.com/test-kitchen/test-kitchen/issues/153
[#154]: https://github.com/test-kitchen/test-kitchen/issues/154
[#155]: https://github.com/test-kitchen/test-kitchen/issues/155
[#157]: https://github.com/test-kitchen/test-kitchen/issues/157
[#161]: https://github.com/test-kitchen/test-kitchen/issues/161
[#163]: https://github.com/test-kitchen/test-kitchen/issues/163
[#166]: https://github.com/test-kitchen/test-kitchen/issues/166
[#170]: https://github.com/test-kitchen/test-kitchen/issues/170
[#171]: https://github.com/test-kitchen/test-kitchen/issues/171
[#172]: https://github.com/test-kitchen/test-kitchen/issues/172
[#176]: https://github.com/test-kitchen/test-kitchen/issues/176
[#178]: https://github.com/test-kitchen/test-kitchen/issues/178
[#179]: https://github.com/test-kitchen/test-kitchen/issues/179
[#187]: https://github.com/test-kitchen/test-kitchen/issues/187
[#188]: https://github.com/test-kitchen/test-kitchen/issues/188
[#192]: https://github.com/test-kitchen/test-kitchen/issues/192
[#193]: https://github.com/test-kitchen/test-kitchen/issues/193
[#206]: https://github.com/test-kitchen/test-kitchen/issues/206
[#217]: https://github.com/test-kitchen/test-kitchen/issues/217
[#218]: https://github.com/test-kitchen/test-kitchen/issues/218
[#222]: https://github.com/test-kitchen/test-kitchen/issues/222
[#227]: https://github.com/test-kitchen/test-kitchen/issues/227
[#231]: https://github.com/test-kitchen/test-kitchen/issues/231
[#235]: https://github.com/test-kitchen/test-kitchen/issues/235
[#240]: https://github.com/test-kitchen/test-kitchen/issues/240
[#242]: https://github.com/test-kitchen/test-kitchen/issues/242
[#249]: https://github.com/test-kitchen/test-kitchen/issues/249
[#253]: https://github.com/test-kitchen/test-kitchen/issues/253
[#254]: https://github.com/test-kitchen/test-kitchen/issues/254
[#256]: https://github.com/test-kitchen/test-kitchen/issues/256
[#258]: https://github.com/test-kitchen/test-kitchen/issues/258
[#259]: https://github.com/test-kitchen/test-kitchen/issues/259
[#262]: https://github.com/test-kitchen/test-kitchen/issues/262
[#265]: https://github.com/test-kitchen/test-kitchen/issues/265
[#266]: https://github.com/test-kitchen/test-kitchen/issues/266
[#272]: https://github.com/test-kitchen/test-kitchen/issues/272
[#275]: https://github.com/test-kitchen/test-kitchen/issues/275
[#276]: https://github.com/test-kitchen/test-kitchen/issues/276
[#277]: https://github.com/test-kitchen/test-kitchen/issues/277
[#278]: https://github.com/test-kitchen/test-kitchen/issues/278
[#280]: https://github.com/test-kitchen/test-kitchen/issues/280
[#282]: https://github.com/test-kitchen/test-kitchen/issues/282
[#283]: https://github.com/test-kitchen/test-kitchen/issues/283
[#285]: https://github.com/test-kitchen/test-kitchen/issues/285
[#286]: https://github.com/test-kitchen/test-kitchen/issues/286
[#287]: https://github.com/test-kitchen/test-kitchen/issues/287
[#288]: https://github.com/test-kitchen/test-kitchen/issues/288
[#293]: https://github.com/test-kitchen/test-kitchen/issues/293
[#296]: https://github.com/test-kitchen/test-kitchen/issues/296
[#298]: https://github.com/test-kitchen/test-kitchen/issues/298
[#302]: https://github.com/test-kitchen/test-kitchen/issues/302
[#303]: https://github.com/test-kitchen/test-kitchen/issues/303
[#304]: https://github.com/test-kitchen/test-kitchen/issues/304
[#305]: https://github.com/test-kitchen/test-kitchen/issues/305
[#306]: https://github.com/test-kitchen/test-kitchen/issues/306
[#307]: https://github.com/test-kitchen/test-kitchen/issues/307
[#309]: https://github.com/test-kitchen/test-kitchen/issues/309
[#310]: https://github.com/test-kitchen/test-kitchen/issues/310
[#313]: https://github.com/test-kitchen/test-kitchen/issues/313
[#316]: https://github.com/test-kitchen/test-kitchen/issues/316
[#318]: https://github.com/test-kitchen/test-kitchen/issues/318
[#343]: https://github.com/test-kitchen/test-kitchen/issues/343
[#352]: https://github.com/test-kitchen/test-kitchen/issues/352
[#353]: https://github.com/test-kitchen/test-kitchen/issues/353
[#357]: https://github.com/test-kitchen/test-kitchen/issues/357
[#358]: https://github.com/test-kitchen/test-kitchen/issues/358
[#363]: https://github.com/test-kitchen/test-kitchen/issues/363
[#366]: https://github.com/test-kitchen/test-kitchen/issues/366
[#370]: https://github.com/test-kitchen/test-kitchen/issues/370
[#373]: https://github.com/test-kitchen/test-kitchen/issues/373
[#375]: https://github.com/test-kitchen/test-kitchen/issues/375
[#381]: https://github.com/test-kitchen/test-kitchen/issues/381
[#389]: https://github.com/test-kitchen/test-kitchen/issues/389
[#397]: https://github.com/test-kitchen/test-kitchen/issues/397
[#399]: https://github.com/test-kitchen/test-kitchen/issues/399
[#416]: https://github.com/test-kitchen/test-kitchen/issues/416
[#424]: https://github.com/test-kitchen/test-kitchen/issues/424
[#427]: https://github.com/test-kitchen/test-kitchen/issues/427
[#429]: https://github.com/test-kitchen/test-kitchen/issues/429
[#431]: https://github.com/test-kitchen/test-kitchen/issues/431
[#433]: https://github.com/test-kitchen/test-kitchen/issues/433
[#450]: https://github.com/test-kitchen/test-kitchen/issues/450
[#454]: https://github.com/test-kitchen/test-kitchen/issues/454
[#456]: https://github.com/test-kitchen/test-kitchen/issues/456
[#457]: https://github.com/test-kitchen/test-kitchen/issues/457
[#462]: https://github.com/test-kitchen/test-kitchen/issues/462
[#477]: https://github.com/test-kitchen/test-kitchen/issues/477
[#478]: https://github.com/test-kitchen/test-kitchen/issues/478
[#481]: https://github.com/test-kitchen/test-kitchen/issues/481
[#489]: https://github.com/test-kitchen/test-kitchen/issues/489
[#498]: https://github.com/test-kitchen/test-kitchen/issues/498
[#504]: https://github.com/test-kitchen/test-kitchen/issues/504
[#507]: https://github.com/test-kitchen/test-kitchen/issues/507
[#510]: https://github.com/test-kitchen/test-kitchen/issues/510
[#521]: https://github.com/test-kitchen/test-kitchen/issues/521
[#524]: https://github.com/test-kitchen/test-kitchen/issues/524
[#526]: https://github.com/test-kitchen/test-kitchen/issues/526
[#527]: https://github.com/test-kitchen/test-kitchen/issues/527
[#530]: https://github.com/test-kitchen/test-kitchen/issues/530
[#531]: https://github.com/test-kitchen/test-kitchen/issues/531
[#543]: https://github.com/test-kitchen/test-kitchen/issues/543
[#549]: https://github.com/test-kitchen/test-kitchen/issues/549
[#554]: https://github.com/test-kitchen/test-kitchen/issues/554
[#555]: https://github.com/test-kitchen/test-kitchen/issues/555
[#556]: https://github.com/test-kitchen/test-kitchen/issues/556
[#557]: https://github.com/test-kitchen/test-kitchen/issues/557
[#558]: https://github.com/test-kitchen/test-kitchen/issues/558
[#567]: https://github.com/test-kitchen/test-kitchen/issues/567
[#579]: https://github.com/test-kitchen/test-kitchen/issues/579
[#580]: https://github.com/test-kitchen/test-kitchen/issues/580
[#581]: https://github.com/test-kitchen/test-kitchen/issues/581
[#588]: https://github.com/test-kitchen/test-kitchen/issues/588
[#592]: https://github.com/test-kitchen/test-kitchen/issues/592
[#600]: https://github.com/test-kitchen/test-kitchen/issues/600
[#611]: https://github.com/test-kitchen/test-kitchen/issues/611
[#629]: https://github.com/test-kitchen/test-kitchen/issues/629
[#633]: https://github.com/test-kitchen/test-kitchen/issues/633
[#648]: https://github.com/test-kitchen/test-kitchen/issues/648
[#649]: https://github.com/test-kitchen/test-kitchen/issues/649
[#651]: https://github.com/test-kitchen/test-kitchen/issues/651
[#652]: https://github.com/test-kitchen/test-kitchen/issues/652
[#653]: https://github.com/test-kitchen/test-kitchen/issues/653
[#654]: https://github.com/test-kitchen/test-kitchen/issues/654
[#656]: https://github.com/test-kitchen/test-kitchen/issues/656
[#658]: https://github.com/test-kitchen/test-kitchen/issues/658
[#666]: https://github.com/test-kitchen/test-kitchen/issues/666
[#667]: https://github.com/test-kitchen/test-kitchen/issues/667
[#668]: https://github.com/test-kitchen/test-kitchen/issues/668
[#672]: https://github.com/test-kitchen/test-kitchen/issues/672
[#673]: https://github.com/test-kitchen/test-kitchen/issues/673
[#674]: https://github.com/test-kitchen/test-kitchen/issues/674
[#675]: https://github.com/test-kitchen/test-kitchen/issues/675
[@ChrisLundquist]: https://github.com/ChrisLundquist
[@MarkGibbons]: https://github.com/MarkGibbons
[@adamhjk]: https://github.com/adamhjk
[@afiune]: https://github.com/afiune
[@arangamani]: https://github.com/arangamani
[@arunthampi]: https://github.com/arunthampi
[@benlangfeld]: https://github.com/benlangfeld
[@bkw]: https://github.com/bkw
[@bryanwb]: https://github.com/bryanwb
[@calavera]: https://github.com/calavera
[@chrishenry]: https://github.com/chrishenry
[@coderanger]: https://github.com/coderanger
[@curiositycasualty]: https://github.com/curiositycasualty
[@daniellockard]: https://github.com/daniellockard
[@ekrupnik]: https://github.com/ekrupnik
[@fnichol]: https://github.com/fnichol
[@fnordfish]: https://github.com/fnordfish
[@gmiranda23]: https://github.com/gmiranda23
[@gondoi]: https://github.com/gondoi
[@grahamc]: https://github.com/grahamc
[@grubernaut]: https://github.com/grubernaut
[@hollow]: https://github.com/hollow
[@jaimegildesagredo]: https://github.com/jaimegildesagredo
[@jasonroelofs]: https://github.com/jasonroelofs
[@jdmundrawala]: https://github.com/jdmundrawala
[@jgoldschrafe]: https://github.com/jgoldschrafe
[@jochenseeber]: https://github.com/jochenseeber
[@jonsmorrow]: https://github.com/jonsmorrow
[@josephholsten]: https://github.com/josephholsten
[@jrwesolo]: https://github.com/jrwesolo
[@jschneiderhan]: https://github.com/jschneiderhan
[@jstriebel]: https://github.com/jstriebel
[@jtgiri]: https://github.com/jtgiri
[@jtimberman]: https://github.com/jtimberman
[@juliandunn]: https://github.com/juliandunn
[@justincampbell]: https://github.com/justincampbell
[@kamalim]: https://github.com/kamalim
[@kisoku]: https://github.com/kisoku
[@lamont-granquist]: https://github.com/lamont-granquist
[@manul]: https://github.com/manul
[@martinb3]: https://github.com/martinb3
[@mattray]: https://github.com/mattray
[@mconigliaro]: https://github.com/mconigliaro
[@mcquin]: https://github.com/mcquin
[@michaelkirk]: https://github.com/michaelkirk
[@miketheman]: https://github.com/miketheman
[@mthssdrbrg]: https://github.com/mthssdrbrg
[@mwrock]: https://github.com/mwrock
[@oferrigni]: https://github.com/oferrigni
[@patcon]: https://github.com/patcon
[@portertech]: https://github.com/portertech
[@rarenerd]: https://github.com/rarenerd
[@reset]: https://github.com/reset
[@rhass]: https://github.com/rhass
[@ringods]: https://github.com/ringods
[@robcoward]: https://github.com/robcoward
[@rteabeault]: https://github.com/rteabeault
[@ryansouza]: https://github.com/ryansouza
[@ryotarai]: https://github.com/ryotarai
[@saketoba]: https://github.com/saketoba
[@sawanoboly]: https://github.com/sawanoboly
[@scarolan]: https://github.com/scarolan
[@schisamo]: https://github.com/schisamo
[@scotthain]: https://github.com/scotthain
[@sethvargo]: https://github.com/sethvargo
[@smith]: https://github.com/smith
[@someara]: https://github.com/someara
[@srenatus]: https://github.com/srenatus
[@stevendanna]: https://github.com/stevendanna
[@thommay]: https://github.com/thommay
[@tknerr]: https://github.com/tknerr
[@tyler-ball]: https://github.com/tyler-ball
[@whiteley]: https://github.com/whiteley
[@zts]: https://github.com/zts
