---
title: Test Kitchen 1.3.0 Release Notes
date: 2015-01-15 22:00 UTC
author: Fletcher Nichol
tags: release-notes
---

For immediate release: [Test Kitchen 1.3.0](https://github.com/test-kitchen/test-kitchen/releases/tag/v1.3.0) is available on [RubyGems](https://rubygems.org/gems/test-kitchen).

READMORE

Hey there, how’s it going? It’s been a while, huh? Also welcome—I’ll wager this is the first blog entry you’ve read here. There’s lots we can talk about, but for today let’s focus (and celebrate) a new release of Test Kitchen.

In terms of code churn and long term viability of the codebase, the biggest change this latest release brings is an upgrade to the project’s health tooling, a full backfilling of unit test coverage, a full reworking of the developer documentation in the form of YARD commenting, and even some refactoring as a result. Most of this work was contained in [pull request 427](https://github.com/test-kitchen/test-kitchen/pull/427) and will be a pretty dry read for most end users. However the reasoning behind it might be useful to some, so here’s an excerpt from the pull request text:

> So what happens when a project comes to life by inspiration and accident, then gets picked up and starts getting used in the field? Well, it's a balancing act of adding new features and tending the codebase garden so that future features are possible.
>
> Let's call this PR a bobcat re-landscaping effort.
>
>The goal here is backfill missing unit test coverage in critical parts of the codebase for 3 big reasons:
>
> 1. Make future [refactoring](http://c2.com/cgi/wiki?WhatIsRefactoring) quicker and lower stress. It becomes extremely expensive to properly refactor without a safety net of tests--they help enforce the previous contract for any new or modified production code.
> 2. Allow more safety when accepting pull requests and contributions. Once a more complete code coverage is achieved, we will start to ask for accompanying unit and/or integration tests to accompany pull requests. This benefits everyone.
> 3. Provide more use cases and developer documentation when navigating the codebase. Developer docs and code examples are one dimension of a successful "documented project".

Let’s take a peek at some of the highlights…

## Highlights

### PR 381/456: Add configurable defaults for chef-solo, chef-client, and chef omnibus paths

For Chef provisioners (namely, `chef_solo` and `chef_zero`) there are 2 (well 3) new configuration attributes available for customization:

* `chef_omnibus_root`: is used when checking for a Chef Omnibus installation and to calculate the default path to the `chef-client` or `chef-solo` binaries. By default, this value is `”/opt/chef”`. If you would rather use the [ChefDK](https://downloads.chef.io/chef-dk/) distribution, then you could set this value to `”/opt/chefdk”`.
* `chef_client_path`: is used with the `chef_zero` provisioner and  lets you customize your path to the `chef-client` binary when performing a Chef run. By default, this value is `”/opt/chef/bin/chef-client`” but will automatically adjusted if `chef_omnibus_root` is changed (see above).
* `chef_solo_path`: is used with the `chef_solo` provisioner and  lets you customize your path to the `chef-solo` binary when performing a Chef run. By default, this value is `”/opt/chef/bin/chef-solo`” but will automatically adjusted if `chef_omnibus_root` is changed (see above).

### PR 489: Introduce the :chef_omnibus_install_options config attribute to be able to pass additional arguments to the Chef installer script

This new configuration attribute allows you to pass additional arguments to the `install.sh` script which can install not only Omnibus Chef packages, but also the ChefDK distribution which is very useful for workstation development. Here’s a more complete example which also uses the new `chef_omnibus_root` configuration attribute as described above:

~~~yaml
---
driver:
  name: vagrant

provisioner:
  name: chef_zero
  chef_omnibus_install_options: -P chefdk
  chef_omnibus_root: /opt/chefdk

platforms:
  - name: ubuntu-12.04
  - name: centos-6.4

suites:
  - name: default
    run_list:
      - workstation_amazing
    attributes:
~~~

Note that updating the `chef_omnibus_root` is required so that the path to the `chef-client` binary becomes `”/opt/chefdk/bin/chef-client”`. Commence workstation testing!

### PR 478: Buffer Logger output & fix Chef run output formatting

Speaking personally, this is one of the most exciting improvements in this release. This returns the Chef run output to be free of clutter, noise, and duplication.

*Taken from the text of the [pull request](https://github.com/test-kitchen/test-kitchen/pull/478):*

> For more detail you can check out the commit message for the included commits.
>
> Turns out there were competing issues:
>
> * Adding the explicit `--log_level info` option on `chef-solo` and `chef-client` were conflating both outputs together
> * The SSH connection is requesting a TTY (for older/stock sudoers policies) which caused the Chef runs to believe they were running in interactive mode
> * The interactive mode also enabled coloring which isn't necessary since Kitchen is coloring the output itself
>
> When I attempted to use `--force-logger --log_level info` (in interactive) I was seeing double output of each line. When I force the Chef run to operate non-interactively (by piping through cat: `chef-solo -force-logger --log_level info ... | cat`) this resolved the double output.
>
> It seems to me that fixing the output formatting will go so far to make things better here, but is it possible that a user will need to make use of the classic logger format and thus need an option to switch this out? I'm not sold either way, but know that any formatting cleanup will be an improvement and help bring clarity back to the Chef runs here.

### PR 481: Disable color output when no TTY is present

This should help clean up Test Kitchen output in CI environments, using the `kitchen` command with unix pipes, etc.

In other words:

~~~sh
kitchen test | cat
~~~

Should *not* output colors.

Currently, the only catch is that colors are still used inside the instances for tools such as RSpec. This may require work in the Busser component.

### PR 555: Correct global YAML merge order to lowest (from highest)

This addresses a merge order bug-of-intention between the following files:

* `.kitchen.yml` (project config)
* `.kitchen.local.yml` (local config)
* `$HOME/.kitchen/config.yml` (global config)

The intended behavior was that:

1. baseline common configuration can go in the global config
2. any colliding values in the project config "win" over the global
   config
3. any colliding values in the local config "win" over the project
   config (and consequently also the global config)

This pull request restores the intended merge semantics.

## Full Changleog

### Upstream changes

* Pull request [#558][], pull request [#557][]: Update omnibus download URL to chef.io. ([@scarolan][])
* Pull request [#531][], pull request [#521][]: Update mixlib-shellout dependency to be greater or equal to 1.2 and less than 3.0. ([@lamont-granquist][])

### Bug fixes

* Pull request [#555][], issue [#524][], issue [#343][]: (**Breaking**) Correct global YAML merge order to lowest (from highest).
* Pull request [#416][]: Use `Gem::GemRunner` to install drivers with `kitchen init` generator (addresses opscode/chef-dk[#20][]). ([@mcquin][])
* Pull request [#399][]: Sleep before retrying SSH#establish_connection. ([@fnichol][])
* Pull request [#527][]: Rescue SSH authentication failures to use retry/timeout connection logic. ([@chrishenry][])
* Pull request [#363][]: Ensure that integer chef config attributes get placed in solo.rb/client.rb properly. ([@benlangfeld][], [@sethvargo][])
* Pull request [#431][]: Check for zero byte state files. ([@rhass][])
* Pull request [#554][], pull request [#543][]: Replace `/` with `-` in Instance names, allowing instance names to be used as server hostnames in most cases. ([@grubernaut][], [@fnichol][])

### New features

* Pull request [#373][]: Add new subcommand 'exec'. ([@sawanoboly][])
* Pull request [#397][]: Introduce the `:chef_zero_port` config attribute to the chef_zero provisioner. ([@jtgiri][])
* Pull request [#381][], pull request [#456][]: Add configurable defaults for chef-solo, chef-client, and chef omnibus paths. ([@sethvargo][], [@robcoward][], [@fnichol][])
* Pull request [#489][]: Introduce the `:chef_omnibus_install_options` config attribute to be able to pass additional arguments to the Chef installer script. ([@ringods][])
* Pull request [#549][]: Introduce the `:chef_zero_host` config attribute to the chef_zero provisioner. ([@jochenseeber][])
* Pull request [#454][]: Customize `:ssh_timeout` and `:ssh_retries`. ([@ekrupnik][])
* Pull request [#510][], issue [#166][]: Add support for site-cookbooks when using Librarian. ([@jstriebel][])

### Improvements

* Pull request [#427][]: Backfilling spec coverage and refactoring: technical debt edition. Epically huge, finally complete. ([@fnichol][])
* Pull request [#478][], issue [#433][], issue [#352][]: Buffer Logger output & fix Chef run output formatting. ([@fnichol][])
* Pull request [#481][]: Disable color output when no TTY is present. ([@fnichol][])
* Pull request [#526][], pull request [#462][], issue [#375][]: Die on `kitchen login` if instance is not created. ([@daniellockard][], [@fnichol][])
* Pull request [#504][]: Fix 2 tests in `SSHBase` to reflect their intent. ([@jgoldschrafe][])
* Pull request [#450][]: Update help description for CLI subcommands. ([@MarkGibbons][])
* Pull request [#477][]: Bump 'kitchen help' into new Usage section in README and add how to use "-l". ([@curiositycasualty][])
* Pull request [#567][]: Pass the template filename down to Erb for `__FILE__` et al. ([@coderanger][])
* Pull request [#498][]: Fix doc comment in `Kitchen::Loader::YAML.new`. ([@jaimegildesagredo][])
* Pull request [#507][]: Clarify comments in configuration loader. ([@martinb3][])
* Pull request [#366][]: Fix glaring "Transfering" -> "Transferring" typo. ([@srenatus][])
* Pull request [#457][]: Fix "confiuration" -> "configuration" typo in README. ([@michaelkirk][])
* Pull request [#370][]: Use Ruby 2.1 instead of 2.1.0 for CI. ([@justincampbell][])

### Heads up

* Drop Ruby 1.9.2 from TravisCI build matrix (support for Ruby 1.9.2 will be a "best effort"). ([@fnichol][])

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
[#397]: https://github.com/test-kitchen/test-kitchen/issues/397
[#399]: https://github.com/test-kitchen/test-kitchen/issues/399
[#416]: https://github.com/test-kitchen/test-kitchen/issues/416
[#427]: https://github.com/test-kitchen/test-kitchen/issues/427
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
[#531]: https://github.com/test-kitchen/test-kitchen/issues/531
[#543]: https://github.com/test-kitchen/test-kitchen/issues/543
[#549]: https://github.com/test-kitchen/test-kitchen/issues/549
[#554]: https://github.com/test-kitchen/test-kitchen/issues/554
[#555]: https://github.com/test-kitchen/test-kitchen/issues/555
[#557]: https://github.com/test-kitchen/test-kitchen/issues/557
[#558]: https://github.com/test-kitchen/test-kitchen/issues/558
[#567]: https://github.com/test-kitchen/test-kitchen/issues/567
[@ChrisLundquist]: https://github.com/ChrisLundquist
[@MarkGibbons]: https://github.com/MarkGibbons
[@adamhjk]: https://github.com/adamhjk
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
[@mthssdrbrg]: https://github.com/mthssdrbrg
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
[@zts]: https://github.com/zts
