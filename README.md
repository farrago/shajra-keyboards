- [About the Project](#sec-1)
- [The mappings](#sec-2)
    - [Model 01 "shajra" keymap](#sec-2-0-1)
    - [Ergodox EZ "shajra" keymap](#sec-2-0-2)
- [Using these key mappings](#sec-3)
    - [1. Install Nix on your GNU/Linux distribution](#sec-3-0-1)
    - [2. Make sure your udev rules are set](#sec-3-0-2)
    - [3. For Kaleidoscope, join the necessary OS group](#sec-3-0-3)
    - [4. Unplug and replug your keyboard](#sec-3-0-4)
    - [5. Get the code and run it](#sec-3-0-5)
- [Reverting to the factory default mapping](#sec-4)
- [Modifying and testing](#sec-5)
- [Release](#sec-6)
- [License](#sec-7)
- [Contribution](#sec-8)

[![img](https://img.shields.io/travis/shajra/shajra-keyboards/master.svg?label=master)](https://travis-ci.org/shajra/shajra-keyboards)

# About the Project<a id="sec-1"></a>

This project has the "shajra" keyboard mappings for two ergonomic split keyboards:

-   [Keyboardio's Model 01](https://shop.keyboard.io), programmed with [Kaleidoscope](https://github.com/keyboardio/Kaleidoscope) firmware.
-   [ZSA Technology Labs' Ergodox EZ](https://ergodox-ez.com), programmed with [QMK](https://docs.qmk.fm) firmware

Beyond the keymap, this project offers some streamlined automation with [Nix](https://nixos.org/nix) that you can use for your own keymap.

The rest of this document discusses using this automation. To get the most out of the keymap itself, you may be interested in the [design document](doc/design.md) explaining the motivation behind the mapping.

# The mappings<a id="sec-2"></a>

The "shajra" keymaps for both keyboards are extremely similar, which works out well because the physical layouts of these keyboards are also similar. We can more easily switch from one keyboard to another, and retain the design benefits of the mapping.

### Model 01 "shajra" keymap<a id="sec-2-0-1"></a>

![img](doc/model-01-shajra-layout.png)

### Ergodox EZ "shajra" keymap<a id="sec-2-0-2"></a>

![img](doc/ergodox-ez-shajra-layout.png)

# Using these key mappings<a id="sec-3"></a>

This project only supports a GNU/Linux operating system with the [Nix package manager](https://nixos.org/nix) installed.

QMK and Kaleidoscope have build complexities and dependencies that can take a moment to work through. Nix can automate this hassle away by downloading and setting up all the necessary third-party dependencies in way that

-   is highly reproducible
-   won't conflict with your current system/configuration.

By using Nix, we won't have to worry about downloading QMK or Kaleidoscope, or making sure we have the right version of build tools like Arduino installed, or messing with Git submodules, or setting up environment variables. Nix does all this for us. The provided scripts simplify using Nix even further.

The following steps will get your keyboard flashed.

### 1. Install Nix on your GNU/Linux distribution<a id="sec-3-0-1"></a>

> **<span class="underline">NOTE</span>**: You don't need this step if you're running NixOS, which comes with Nix baked in.

> **<span class="underline">NOTE</span>**: Nix on Macs (nix-darwin) currently won't work with this project and is not supported for Macs.

If you don't already have Nix, the official installation script should work on a variety of GNU/Linux distributions. The easiest way to run this installation script is to execute the following shell command as a user other than root:

```shell
curl https://nixos.org/nix/install | sh
```

This script will download a distribution-independent binary tarball containing Nix and its dependencies, and unpack it in `/nix`.

If you prefer to install Nix another way, reference the [Nix manual](https://nixos.org/nix/manual/#chap-installation).

### 2. Make sure your udev rules are set<a id="sec-3-0-2"></a>

To program either keyboard with a new mapping, you need to augment your OS configuration with new udev rules.

The following are recommended rules for each keyboard:

    # For Teensy/Ergodox
    ATTRS{idVendor}=="16c0", ATTRS{idProduct}=="04[789B]?",
    ENV{ID_MM_DEVICE_IGNORE}="1", ENV{ID_MM_PORT_IGNORE}="1"
    ATTRS{idVendor}=="16c0", ATTRS{idProduct}=="04[789A]?",
    ENV{MTP_NO_PROBE}="1" SUBSYSTEMS=="usb", ATTRS{idVendor}=="16c0",
    ATTRS{idProduct}=="04[789ABCD]?", MODE:="0666" KERNEL=="ttyACM*",
    ATTRS{idVendor}=="16c0", ATTRS{idProduct}=="04[789B]?", MODE:="0666"
    
    # For Kaleidoscope/Keyboardio
    SUBSYSTEMS=="usb", ATTRS{idVendor}=="1209", ATTRS{idProduct}=="2300",
    SYMLINK+="model01", ENV{ID_MM_DEVICE_IGNORE}:="1",
    ENV{ID_MM_CANDIDATE}:="0" SUBSYSTEMS=="usb", ATTRS{idVendor}=="1209",
    ATTRS{idProduct}=="2301", SYMLINK+="model01",
    ENV{ID_MM_DEVICE_IGNORE}:="1", ENV{ID_MM_CANDIDATE}:="0"

These settings should correspond to the official documentation:

-   [QMK documentation for configuring udev](https://github.com/qmk/qmk_firmware/tree/master/keyboards/ergodox_ez)
-   [Kaleidoscope documentation for configuring udev](https://github.com/keyboardio/Kaleidoscope/wiki/Install-Arduino-support-on-Linux)

Each distribution is different, but on many GNU/Linux systems, udev rules are put in a file in `/etc/udev/rules.d` with a ".rules" extension.

On some systems, you can activate these rules with the following commands:

```shell
udevadm control --reload-rules udevadm trigger
```

Or just restart the computer.

### 3. For Kaleidoscope, join the necessary OS group<a id="sec-3-0-3"></a>

> ***NOTE:*** You don't need this step if you're flashing the Ergodox EZ.

Once udev is configured, when you plug in the Keyboardio Model 01, a `/dev/ttyACM0` should appear. On many systems, this device is group-owned by the "dialout" or the "uucp" group:

In the following example, we can see the device is group-owned by the "dialout" group.

```shell
ls -l /dev/ttyACM0
```

    crw-rw---- 1 root dialout 166, 0 Nov 12 08:58 /dev/ttyACM0

On most distributions, the follow commands should work to join a group (substituting `$TTY_GROUP` and `$USERNAME`):

```shell
sudo usermod -a -G $TTY_GROUP $USERNAME
newgrp $TTY_GROUP
```

You should see memberships in the new group with the `groups` command:

```shell
groups | grep dialout
```

    users wheel video dialout docker

### 4. Unplug and replug your keyboard<a id="sec-3-0-4"></a>

Unplug your keyboard(s) and plug them back in, to make sure everything's set to program.

### 5. Get the code and run it<a id="sec-3-0-5"></a>

Clone this code base and go into the directory:

```shell
cd $SOME_WORKING_DIR
clone https://github.com/shajra/shajra-keyboards.git
cd shajra-keyboards
```

Note, the first time you run the commands described below, you'll see Nix doing a lot of downloading and compiling. After that, subsequent invocations should be quicker with less output.

1.  Flashing an Ergodox EZ keyboard

    You can run the following to flash your Ergodox EZ with the new keymap, pressing the reset button when prompted (access the reset button with an unbent paperclip inserted into the small hole in the top right corner of the right keyboard half):
    
    ```shell
    ./flash-ergodoxez
    ```
    
        
        Flashing ZSA Technology Lab's Ergodox EZ (custom "shajra" keymap)
        =================================================================
        
        FLASH SOURCE: /nix/store/z59b5cnpszla6cz69qdh7my75g4wbj50-qmk-custom-shajra-src
        FLASH BINARY: /nix/store/nf3x5hr5zhkrcxmzara2k8qkkfrcqvr1-ergodoxez-custom-shajra-hex
        
        Teensy Loader, Command Line, Version 2.1
        Read "/nix/store/nf3x5hr5zhkrcxmzara2k8qkkfrcqvr1-ergodoxez-custom-shajra-hex": 26620 bytes, 82.5% usage
        Waiting for Teensy device...
         (hint: press the reset button)

2.  Flashing a Keyboardio Model 01 keyboard

    You can run the following to flash your Keyboardio Model 01, holding down the `Prog` key and then pressing `Enter` when prompted:
    
    ```shell
    ./flash-model01
    ```
    
        
        Flashing Keyboardio's Model 01 (custom "shajra" keymap)
        =======================================================
        
        FLASH SOURCE: /nix/store/a1vwkigv1his5apdr8k070wdb3l2lxw4-model01-custom-shajra-src
        
        BOARD_HARDWARE_PATH="/nix/store/136z5dj3nnyn7gf9fx6i7xq4an3v7iz3-kaleidoscope-src/arduino/hardware" /nix/store/136z5dj3nnyn7gf9fx6i7xq4an3v7iz3-kaleidoscope-src/arduino/hardware/keyboardio/avr/libraries/Kaleidoscope/bin//kaleidoscope-builder flash
        Building ./Model01-Firmware 0.0.0 into /tmp/kaleidoscope-/sketch/7211352-Model01-Firmware.ino/output...
        - Size: firmware/Model01-Firmware/Model01-Firmware-0.0.0.elf
          - Program:   25566 bytes (89.2% Full)
          - Data:       1217 bytes (47.5% Full)
        
        To update your keyboard's firmware, hold down the 'Prog' key on your keyboard,
        and then press 'Enter'.
    
    The `Prog` key is hardwired to be the top-left-most key of the Keyboardio Model 01, but the `Enter` key can be remapped. If you forget where the `Enter` has been mapped to on your Keyboard, you can hit `Enter` on another connected keyboard.

# Reverting to the factory default mapping<a id="sec-4"></a>

This project's scripts won't save off your previous keymap from your keyboard. But we can revert to the keymap that your keyboard shipped with.

This can be done with the `-F=/`&#x2013;factory= switch, which both `./flash-ergodoxez` and `./flash-model01` support. Both scripts have a `-h=/`&#x2013;help= in case you forget your options.

# Modifying and testing<a id="sec-5"></a>

The provided code is fairly compact. If you look in the <./ergodox_ez/keymaps> and <./model_01/keymaps>, you should find familiar files that you would edit in QMK or Kaleidoscope projects, respectively.

For both keyboards, The "shajra" keymap is in it's own directory. You can make your own keymaps and put them in a sibling directory with the name of your choice.

Then you can use the `-k=/`&#x2013;keymap= switch of either script to load your custom keymap by the name you chose for the keymap in the "keymaps" directory. The scripts should pick up changes, rebuild anything necessary, and flash your keyboard.

Nix will copy your source code into `/nix/store`, and the invocation of both scripts will print out a "FLASH SOURCE:" line indicating the source used for compiling/flashing for your reference. These are the full source trees you'd normally use if following the QMK or Kaleidoscope documentation manually.

If you want to check that everything builds before flashing your keyboard, you can run a `nix-build` invocation:

```shell
nix-build --no-out-link
```

If you run `nix-build` without the `--no-out-link` switch, Nix will leave symlinks behind in your working directory that point to the built artifacts, which Nix always stores in a special `/nix/store` directory. The names of these symlinks are all prefixed with "result".

You can garbage collect `/nix/store` by running `nix-collect-garbage`:

```shell
nix-collect-garbage 2>&1
```

    finding garbage collector roots...
    deleting garbage...
    deleting '/nix/store/ix75ycc5l74lzq494cjibdnxqpwjj236-model01-custom-shajra-flash.drv'
    deleting '/nix/store/vq9swngh73g10wy7x011hmj0l762pgmv-model01-custom-shajra-hex.drv'
    deleting '/nix/store/yx5jf78l3nh5i9c14vzwfbgc40f2yrw1-arduino-1.8.9.drv'
    …
    deleting '/nix/store/qrsppll14qdc8zpnblad7crpmapzwb3v-1.0.3.zip.drv'
    deleting '/nix/store/trash'
    deleting unused links...
    note: currently hard linking saves -0.00 MiB
    110 store paths deleted, 734.50 MiB freed

The "result" symlinks generated by `nix-build` keep built artifacts from by garbage collected by `nix-collect-garbage`. Otherwise, these symlink are safe to delete, and [ignored by Git](./.gitignore).

# Release<a id="sec-6"></a>

The "master" branch of the repository on GitHub has the latest released version of this code. There is currently no commitment to either forward or backwards compatibility. However the scripts for compiling/flashing are largely stable and are less likely to change than the "shajra" keymap.

The "user/shajra" branch is a personal branch that is force-pushed to. The "master" branch should not experience force-pushes and is recommended for general use.

# License<a id="sec-7"></a>

This project is not a modified work in the traditional sense. It provides scripts the end user runs to make a modified work. Most of the source code modified (QMK, Kaleidoscope, and Model 01) is licensed under either GPLv2 or GPLv3.

If you have Nix installed, then a provided script `licenses-thirdparty` can be run to download all original source used, including license information.

In the spirit of the projects we build upon, all files in this "shajra-keyboards" project are licensed under the terms of GPLv3 or (at your option) any later version.

Please see the [COPYING.md](./COPYING.md) file for more details.

# Contribution<a id="sec-8"></a>

Feel free to file issues and submit pull requests with GitHub. Ideas for how to improve automation are welcome. If you have ideas on how to improve the "shajra" keymap, just make a compelling argument considering the factors that have already gone into [its design](doc/design.md).

There is only one author to date, so the following copyright covers all files in this project:

Copyright © 2019 Sukant Hajra
