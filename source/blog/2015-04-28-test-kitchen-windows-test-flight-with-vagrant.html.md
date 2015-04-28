---
title: Test Kitchen Windows Test Flight with Vagrant
date: 2015-04-28 15:30 UTC
author: Fletcher Nichol
tags: windows
---


As mentioned in the [1.4.0 release notes](../test-kitchen-1-4-0-release-notes), you can now spin up instances running various versions of Windows. If would you like to try out this new functionality using nothing more than your workstation, read on.


READMORE

There are a few things we'll cover in this post:

1. Installing the vagrant-winrm Vagrant plugin
2. Building a Windows Vagrant box
3. Create a sample cookbook using the ChefDK

We'll assume that the latest Test Kitchen and Kitchen::Vagrant Driver are installed (see the [1.4.0 release notes](../test-kitchen-1-4-0-release-notes) for more details).

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

Due to Microsoft's EULA restrictions, it isn't currently possible to distribute Windows Vagrant boxes--even if they are evaluation versions from publicly downloadable ISO images. This leaves us with the task of building the boxes ourselves, but thankfully [Packer](https://packer.io/) makes this a good deal easier.

To test the functionality of Test Kitchen in development, the [boxcutter/windows](https://github.com/boxcutter/windows) was used to create various Windows box versions. You will need [Packer](https://packer.io/downloads.html) installed but should work on most operating systems. For example, here's how you can build your own Windows Server 2012r2 evaluation box using Boxcutter:

~~~sh
git clone https://github.com/boxcutter/windows.git
cd windows
make virtualbox/eval-win2012r2-standard
~~~

Note that on my 13" MacBook Retina the download-to-built time was 44 minutes. Long, but not bad considering. Also, if VMware is your cup of tea, try `make vmware/eval-win2012r2-standard`.

Finally, add the build box to Vagrant, calling it `"windows-2012r2"` (a box starting with "win" will help Test Kitchen do the right thing out of the box):

~~~sh
vagrant box add windows-2012r2 ./box/virtualbox/eval-win2012r2-standard-nocm-1.0.4.box
~~~

Also note that the [joefitzgerald/packer-windows](https://github.com/joefitzgerald/packer-windows) also creates a wide variety of Windows Vagrant boxes and may be more your speed if looking for alternatives.

## Test Flight

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

![Confetti Party](blog/test-kitchen-windows-test-flight-with-vagrant/confetti.gif)
