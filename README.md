# AutoAttack

A shell script that lets you hold down spacebar to simulate repeating mouse clicks.

I wrote this for playing ARPG games (which are very clicky) to save me from developing carpal tunnel syndrome.  You can edit the script to limit which windows it will run in, which I have set for Diablo, Torchlight, and Path of Exile.

Written on Ubuntu 22.04 LTS (Jammy Jellyfish).

## Usage

Script has to be run with root privileges to be able to access your devices.

```bash
$ sudo apt install evemu-tools
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