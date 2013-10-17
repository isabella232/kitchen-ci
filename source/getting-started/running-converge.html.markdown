## Running Kitchen Converge

```
$ kitchen converge default-ubuntu-1204
-----> Converging <default-ubuntu-1204>
-----> Installing Chef Omnibus (true)
--2013-10-17 06:30:01--  https://www.opscode.com/chef/install.sh
Resolving www.opscode.com (www.opscode.com)... 184.106.28.83
Connecting to www.opscode.com (www.opscode.com)|184.106.28.83|:443... connected.
HTTP request sent, awaiting response... 200 OK
Length: 6790 (6.6K) [application/x-sh]
Saving to: `STDOUT'

100%[======================================>] 6,790       --.-K/s   in 0s

2013-10-17 06:30:01 (45.6 MB/s) - written to stdout [6790/6790]

Downloading Chef  for ubuntu...
Installing Chef
Selecting previously unselected package chef.
(Reading database ... 53291 files and directories currently installed.)
Unpacking chef (from .../tmp.DG6AAIZy/chef__amd64.deb) ...
Setting up chef (11.6.2-1.ubuntu.12.04) ...
Thank you for installing Chef!
       Preparing current project directory as a cookbook
       Removing non-cookbook files in sandbox
       Uploaded /var/folders/ld/ykg04kvx5y53v7qkhpp254y40000gn/T/default-ubuntu-1204-sandbox-20131017-64178-1uu6djw/cookbooks/git/metadata.rb (27 bytes)
       Uploaded /var/folders/ld/ykg04kvx5y53v7qkhpp254y40000gn/T/default-ubuntu-1204-sandbox-20131017-64178-1uu6djw/cookbooks/git/recipes/default.rb (45 bytes)
       Uploaded /var/folders/ld/ykg04kvx5y53v7qkhpp254y40000gn/T/default-ubuntu-1204-sandbox-20131017-64178-1uu6djw/dna.json (28 bytes)
       Uploaded /var/folders/ld/ykg04kvx5y53v7qkhpp254y40000gn/T/default-ubuntu-1204-sandbox-20131017-64178-1uu6djw/solo.rb (168 bytes)
[2013-10-17T06:30:28+00:00] INFO: Forking chef instance to converge...
Starting Chef Client, version 11.6.2
[2013-10-17T06:30:28+00:00] INFO: *** Chef 11.6.2 ***
[2013-10-17T06:30:28+00:00] INFO: Setting the run_list to ["recipe[git]"] from JSON
[2013-10-17T06:30:28+00:00] INFO: Run List is [recipe[git]]
[2013-10-17T06:30:28+00:00] INFO: Run List expands to [git]
[2013-10-17T06:30:28+00:00] INFO: Starting Chef Run for default-ubuntu-1204
[2013-10-17T06:30:28+00:00] INFO: Running start handlers
[2013-10-17T06:30:28+00:00] INFO: Start handlers complete.
Compiling Cookbooks...
Converging 2 resources
Recipe: git::default
  * package[git] action install

[2013-10-17T06:30:28+00:00] INFO: Processing package[git] action install (git::default line 1)

    - install version 1:1.7.9.5-1 of package git

  * log[Well, that was too easy] action write

[2013-10-17T06:30:45+00:00] INFO: Processing log[Well, that was too easy] action write (git::default line 3)
[2013-10-17T06:30:45+00:00] INFO: Well, that was too easy


[2013-10-17T06:30:45+00:00] INFO: Chef Run complete in 16.548136457 seconds
[2013-10-17T06:30:45+00:00] INFO: Running report handlers
[2013-10-17T06:30:45+00:00] INFO: Report handlers complete
Chef Client finished, 2 resources updated
       Finished converging <default-ubuntu-1204> (0m44.16s).
-----> Kitchen is finished. (0m44.45s)
```

```
$ kitchen list
Instance             Driver   Provisioner  Last Action
default-ubuntu-1204  Vagrant  Chef Solo    Converged
```
