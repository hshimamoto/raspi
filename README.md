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
2020-08-20-raspios-buster-armhf-lite.zip
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
MIT License Copyright(c) 2020, 2021, 2022 Hiroshi Shimamoto
