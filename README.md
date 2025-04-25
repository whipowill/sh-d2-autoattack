# AutoAttack

A shell script that lets you hold down spacebar to simulate repeating mouse clicks.

I wrote this for playing ARPG games (which are very clicky) to save me from developing carpal tunnel syndrome.  You can edit the script to limit which windows it will run in, which I have set for Diablo, Torchlight, and Path of Exile.

Written on Ubuntu 22.04 LTS (Jammy Jellyfish).

## Install

Clone this repo:

```
$ git clone git@github.com:whipowill/sh-d2-autoattack.git
```

Install a couple dependencies:

```bash
$ sudo apt install evemu-tools evtest
```

Find out your keyboard id and mouse event path:

```
$ xinput list // look for your keyboard ID number (example 11)
$ sudo evtest // look for your mouse event path (example /dev/input/event2)
```

Edit the script to use these values:

```
$ cd /path/to/script
$ vim AutoAttack.sh
```

## Usage

Script has to be run with root privileges to be able to access your devices.

```bash
$ cd /path/to/script
$ sudo bash AutoAttack.sh
```

You can bind this to an alias for easier access:

```bash
$ vim ~/.bashrc
> alias autoattack="sudo bash /path/to/script/AutoAttack.sh"
$ source ~/.bashrc
$ autoattack
```

Press ``control-c`` to kill the script.

## External Links

- [ahk-d2-autoattack](https://github.com/whipowill/ahk-d2-autoattack) - My original AutoHotKey version for Windows.