# 6502 computer

This repository contains the hardware and software for my home-built 65C02-based computer. At its heart, this computer is a 1980's design, and is approximately as powerful as the Apple II. It is powered over USB, and operated via a serial connection.

It features an SD card interface, simple audio interface, and two user-selectable ROMs. One ROM contains a port of EhBASIC, which is the only proprietary component in this repository. The other ROM contains a shell, written from scratch to be free and open source, which can be used to load machine-language programs from a modern PC.

Take a look at the [hardware/](https://github.com/mike42/6502-computer/tree/main/hardware) directory for how it's made, or [rom/](https://github.com/mike42/6502-computer/tree/main/rom) for the firmware source code.

### Basic specs

- 1.8432 MHz 65C02 processor
- 32 KiB RAM
- 32 KiB ROM in two 16 KiB banks
- 65C22 VIA (general purpose I/O) chip
- 65C51N ACIA (UART) interface
- Custom PCB and 3D printed case

### Image of completed build

<img src="https://raw.githubusercontent.com/mike42/6502-computer/main/hardware/6502_computer_in_case.jpg" alt="Completed project" width="600">

## Blog series

This project started out on breadboards, and I have been blogging about it as I have progressed the hardware, software, and my electronics knowlege. Posts I've written about this project include:

- [IntelliJ plugin for 6502 assembly language](https://mike42.me/blog/2021-05-intellij-plugin-for-6502-assembly-language)
- [Building a 6502 computer](https://mike42.me/blog/2021-07-building-a-6502-computer)
- [Adding a serial port to my 6502 computer](https://mike42.me/blog/2021-07-adding-a-serial-port-to-my-6502-computer)
- [Upgrades and improvements to my 6502 computer](https://mike42.me/blog/2021-08-upgrades-and-improvements-to-my-6502-computer)
- [Porting BASIC to my 6502 computer](https://mike42.me/blog/2021-09-porting-basic-to-my-6502-computer)
- [6502 computer – from breadboard to PCB](https://mike42.me/blog/2021-09-6502-computer-from-breadboard-to-pcb)
- [Re-creating the world’s worst sound card](https://mike42.me/blog/2021-10-re-creating-the-worlds-worst-sound-card)
- [Designing a 3D printed enclosure for my KiCad project in Blender](https://mike42.me/blog/2021-11-designing-a-3d-printed-enclosure-for-my-kicad-project-in-blender)
- [Implementing the XMODEM protocol for file transfer](https://mike42.me/blog/2021-12-implementing-the-xmodem-protocol-for-file-transfer)
- [Adding an SD card reader to my 6502 computer](https://mike42.me/blog/2021-12-adding-an-sd-card-reader-to-my-6502-computer)
- [Assembling my 6502 computer](https://mike42.me/blog/2012-12-assembling-my-6502-computer)
- [Rendering my 6502 computer project in Blender](https://mike42.me/blog/2022-01-rendering-my-6502-computer-project-in-blender)

## Licenses & acknowledgement

With the exception of the files noted below, this work is © 2021 Michael Billington, and is licensed under a [Creative Commons Attribution 4.0 International License](http://creativecommons.org/licenses/by/4.0/).

The design is an extension of [Ben Eater's 6502 computer tutorial](https://eater.net/6502), which is itself based on the work of the [6502.org](http://www.6502.org/) community.

### 6502 KiCad Library

The files `hardware/kicad/65xx.dcm` and `hardware/kicad/65xx.lib` are modified versions of the [6502 KiCad Library](https://github.com/Alarm-Siren/6502-kicad-library). Copyright 2018, Nicholas Parks Young. All Rights Reserved. The 6502 KiCad Library library is licensed under the GNU LGPL v2.1, which can be found in file `licenses/LGPL.txt`.

### EhBASIC

The files in `rom/basic/` are derived from EhBASIC, developed by Lee Davidson. The EhBASIC license allows for non-commerical use only. The most recent release and manual is hosted [here](https://github.com/Klaus2m5/6502_EhBASIC_V2.22), and a mirror of Lee's website can be found [here](http://retro.hansotten.nl/6502-sbc/lee-davison-web-site/).

> EhBASIC is free but not copyright free. For non commercial use there is only one
> restriction, any derivative work should include, in any binary image distributed,
> the string "Derived from EhBASIC" and in any distribution that includes human
> readable files a file that includes the above string in a human readable form
> e.g. not as a comment in an HTML file.

