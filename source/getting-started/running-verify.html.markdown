## Running Kitchen Verify

```
$ kitchen verify default-ubuntu-1204
-----> Starting Kitchen (v1.0.0.beta.3)
-----> Setting up <default-ubuntu-1204>
Fetching: thor-0.18.1.gem (100%)
Fetching: busser-0.4.1.gem (100%)
Successfully installed thor-0.18.1
Successfully installed busser-0.4.1
2 gems installed
-----> Setting up Busser
       Creating BUSSER_ROOT in /opt/busser
       Creating busser binstub
       Plugin bats installed (version 0.1.0)
-----> Running postinstall for bats plugin
      create  /tmp/bats20131017-4295-1sifgho/bats
      create  /tmp/bats20131017-4295-1sifgho/bats.tar.gz
Installed Bats to /opt/busser/vendor/bats/bin/bats
      remove  /tmp/bats20131017-4295-1sifgho
       Finished setting up <default-ubuntu-1204> (0m9.58s).
-----> Verifying <default-ubuntu-1204>
       Suite path directory /opt/busser/suites does not exist, skipping.
Uploading /opt/busser/suites/bats/git_installed.bats (mode=0644)
-----> Running bats test suite
1..1
ok 1 git binary is found in PATH
       Finished verifying <default-ubuntu-1204> (0m1.02s).
-----> Kitchen is finished. (0m10.89s)
```

```
$ kitchen list
Instance             Driver   Provisioner  Last Action
default-ubuntu-1204  Vagrant  Chef Solo    Verified
```
