Copy to `/etc/docker/daemon.json`.

Need to set `default-ulimit nofile` because the default changed with RL9 and
the default value is too low.

```
# RL9
$ cat /etc/systemd/system.conf |grep DefaultLimitNOFILE
#DefaultLimitNOFILE=1024:524288

# RL8
$ cat /etc/systemd/system.conf |grep DefaultLimitNOFILE
#DefaultLimitNOFILE=
```

Need to set `default-cgroupns-mode` to `host` because
`default-cgroupns-mode` default changed to `private` in RL9
because the switch to Cgroup v2.
