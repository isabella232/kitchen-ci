## Writing a Test

```
$ mkdir -p test/integration/default/bats
```

```sh
#!/usr/bin/env bats

@test "git binary is found in PATH" {
  run which git
  [ "$status" -eq 0 ]
}
```
