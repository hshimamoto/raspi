Raspi OS setup scripts
======================

Dependencies
------------

### Install packages
```
$ sudo apt-get -y install qemu qemu-user-static binfmt-support
```

### Download RasPiOS images
```
2023-02-21-raspios-bullseye-arm64-lite.img.xz
2023-02-21-raspios-bullseye-arm64.img.xz
```

How to use
----------

```
$ ./setup.sh <hostname> <template> [extra config]
```

References
----------
https://gist.github.com/cinderblock/20952a653989e55f8a7770a0ca2348a8

License
-------
MIT License Copyright(c) 2020, 2021, 2022, 2023 Hiroshi Shimamoto
