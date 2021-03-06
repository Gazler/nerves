# Getting Started

## Introduction

Nerves defines an entirely new way to build embedded systems using Elixir. It is specifically designed for embedded systems, not desktop or server systems. You can think of Nerves as containing three parts:

**Platform** - a customized, minimal buildroot-derived Linux that boots directly to the BEAM VM.

**Framework** - ready-to-go library of Elixir modules to get you up and running quickly.

**Tooling** - powerful command-line tools to manage builds, update firmware, configure devices, and more.

Taken together, the Nerves platform, framework, and tooling provide a highly specialized environment for using Elixir to build advanced embedded devices.

## Common Terms

In the following guides, support channels, and forums you may hear the following terms being used.

Term | Definition
--- | ---
host | The computer on which you are editing and compiling your code, and assembling firmware
target | The type of system for which your firmware is built - raspberry pi, raspberry pi 2, beaglebone, etc
toolchain | Compilers, linkers, binutils, C runtime, etc which are designed to build code for the target
system | A lean buildroot-based linux distribution that has been customized and cross-compiled
assemble | The process of combining system, application, and configuration into a firmware bundle
firmware bundle | A single file that contains and assembled version of everything needed to burn firmware
firmware image | Built from a firmware bundle, that contains partition table, partitions, bootloader, etc

## Creating a New Nerves App

Before we start using Nerves, it is important that you take a minute to read the [Installation Guide](installation.html). The installation guide will assist you in getting your machine configured for running Nerves.

Lets create a new project. The Nerves new project generator can be called form anywhere and can take either an absolute path or a relative path. In addition, the new project generator requires that you specify the default target you which the project to use. This is helpful and allow you to omit passing the target tag on every call. Visit the [Targets Page](targets.html) for more information on which tags are used for which target boards.

```
$ mix nerves.new hello_nerves --target rpi3
* creating hello_nerves/config/config.exs
* creating hello_nerves/lib/my_app.ex
* creating hello_nerves/test/test_helper.exs
* creating hello_nerves/test/my_app_test.exs
* creating hello_nerves/rel/vm.args
* creating hello_nerves/rel/.gitignore
* creating hello_nerves/.gitignore
* creating hello_nerves/mix.exs
* creating hello_nerves/README.md
```

Nerves will generate the the files and, structure, and directories needed for our application. The next step is to cd into our hello_nerves all directory

```
$ cd hello_nerves
```

and fetch the dependencies

```
$ mix deps.get
```

> It is important to note that Nerves supports the ability of multi-target. This means that the same code base can support running on a variety of different target boards. Because of this, It is very important that your mix file only includes a single nerves_system at any time. For more information check out the [Targets Page](targets.html#target-dependencies)

Once our deps are fetched, we can start to compile our project. The goal is for us to make Nerves Firmware, a bundle which contains a Nerves based linux system and our application, But first we are going to need to create the system which requires us to fetch bot the system and the toolchain. This task is done for us by the nerves_bootstrap utility in a special stage called precompile. This means, the first time you ask dependencies or your application to compile, Nerves will fetch the system and toolchain from one of our cache mirrors. Lets start the process and get a coffee...

```
$ mix compile
Nerves Precompile Start
...
Compile Nerves toolchain
Downloading from Github Cache
Unpacking toolchain to build dir
...
Generated nerves_system_rpi3 app
[nerves_system][compile]
[nerves_system][http] Downloading system from cache
[nerves_system][http] System Downloaded
[nerves_system][http] Unpacking System
...
Nerves Env loaded
Nerves Precompile End
```

At this point, the Nerves System and Toolchain have been pulled down to your machine and your Mix environment as been bootstrapped to point to the right locations. We can verify this by getting Nerves to print out the location of these new assets.

```
$ NERVES_DEBUG=1 mix compile
Nerves Env loaded
------------------
Nerves Environment
------------------
target:     rpi3
toolchain:  _build/rpi3/dev/nerves/toolchain
system:     _build/rpi3/dev/nerves/system
app:        /Users/nerves/hello_nerves
```

You'll notice that subsequent calls to compile will not fetch or build the system.

## Making Firmware

Now that we have a compiled nerves application we can produce firmware. Nerves firmware is the product of turning your application into an OTP release, adding it to the system image, and laying out a partition scheme. You can create the firmware bundle with the following command

```
$ mix firmware
Nerves Env loaded
Nerves Firmware Assembler
...
Building _images/rpi3/hello_nerves.fw...
```

This will eventually output a firmware bundle file `_images/rpi3/hello_nerves.fw`. This file is an archive formatted bundle and metadata about your firmware release. To create a bootable SD card you can use the command

```
$ mix firmware.burn
Burn rpi3-0.0.1 to SD card at /dev/rdisk3, Proceed? [Y/n]
```

This command will attempt to automatically discover the SD card inserted in your machine. There may be situations where this command does not discover your SD card. This may occur if you have more than one SD card inserted into the machine, or you have disk images mounted at the same time. If you find this to happen, you can specify which device to write to by passing the `-d` arg to the command. This command wraps fwup and any extra arguments passed, will be forwarded to fwup.

```
$ mix firmware.burn -d /dev/rdisk3
```

> Note: You can also pass -d to specify an output file. This will allow you to create a binary image you can burn later using dd or some other image copy utility

Now that we have our SD card burned. You can insert it into your device and boot it up. For Raspberry Pi, connect it to your HDMI display and you should boot to the IEx Console.

## Nerves Examples

To get up and running quickly, you can checkout out our collection of example projects
```
$ git clone https://github.com/nerves-project/nerves-examples
$ cd nerves-examples/blinky
$ mix deps.get && mix firmware
```

The example projects contain an app called Blinky, known as "The Hello World of Hardware". If you are ever curious about project structuring or can't get something running, it is advised to check out blinky and run it on your target.
