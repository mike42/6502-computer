# 6502 computer hardware

This directory contains information about the hardware side of this project.

- [kicad/](https://github.com/mike42/6502-computer/tree/main/hardware/kicad) - CAD source files for schematic and PCB
- [gerber/](https://github.com/mike42/6502-computer/tree/main/hardware/gerber/) - PCB manufacturing files 
- [6502_computer_schematic.pdf](https://github.com/mike42/6502-computer/tree/main/hardware/6502_computer_schematic.pdf) - Human-readable schematic
- [case/](https://github.com/mike42/6502-computer/tree/main/hardware/case/) - STL files for 3D printed computer case.
- Parts list (below)

## Parts list for assembling PCB

This is the full list of parts which are required to fully populate the PCB for this build. I've stuck with the parts which I actually used, though many can be substituted if you check the data sheets.

![PCB diagram](https://raw.githubusercontent.com/mike42/6502-computer/main/hardware/6502_computer_pcb_diagram.svg)

### IC’s and sockets

Notes on IC's and sockets

- If you see a designator mentioned twice, one is the IC, the other is the socket.
- All sockets are optional except U9.

| Qty. | Description                    | Installed at | Product ref.                                                                         |
| ---- | ------------------------------ | ------------ | ------------------------------------------------------------------------------------ |
|   1  | 65C02S CPU                     | U1           | [WDC W65C02S6TPG-14](https://au.mouser.com/ProductDetail/955-W65C02S6TPG-14)         |
|   1  | 65C22S VIA                     | U3           | [WDC W65C22S6TPG-14](https://au.mouser.com/ProductDetail/955-W65C22S6TPG-14)         |
|   2  | DIP-40 socket                  | U1, U3       | [Mill-Max 110-99-640-41-001000](https://au.mouser.com/ProductDetail/575-199640)      |
|   1  | 65C51N ACIA                    | U6           | [WDC W65C51N6TPG-14](https://au.mouser.com/ProductDetail/955-W65C51N6TPG-14)         |
|   1  | SRAM 32k x 8                   | U8           | [Alliance AS6C62256-55PCN](https://au.mouser.com/ProductDetail/913-AS6C62256-55PCN)  |
|   2  | DIP-28 socket                  | U6, U8       | [Mill-Max 110-99-628-41-001000](https://au.mouser.com/ProductDetail/575-199628)      |
|   1  | EEPROM 32k x 8                 | U9           | [Atmel AT28C256-15PU](https://au.mouser.com/ProductDetail/556-AT28C25615PU)          |
|   1  | Low-profile DIP-28 ZIF socket  | U9           | [Aires 28-526-10](https://au.mouser.com/ProductDetail/535-28-526-10)                 |
|   1  | 74LS138 demultiplexer          | U2           | [Texas Instruments SN74LS138N](https://au.mouser.com/ProductDetail/595-SN74LS138N)   |
|   1  | DIP-16 socket                  | U2           | [Mill-Max 110-44-316-41-001000](https://au.mouser.com/ProductDetail/575-11044316)    |
|   1  | 74LS00 quad NAND gate          | U4           | [Texas Instruments SN74LS00N](https://au.mouser.com/ProductDetail/595-SN74LS00N)     |
|   1  | DIP-14 socket                  | U4           | [Mill-Max 110-44-314-41-001000](https://au.mouser.com/ProductDetail/575-11044314)    |
|   1  | 1.8432 MHz oscillator          | X1           | [CTS MXO45HS-3C-1M8432](https://au.mouser.com/ProductDetail/774-MXO45HS-3C-1.8)      |
|   1  | Oscillator socket              | X1           | [Aires 1108800](https://au.mouser.com/ProductDetail/535-1108800)                     |
|   1  | 7805 voltage regulator         | U5           | [STMicroelectronics L7805ABV](https://au.mouser.com/ProductDetail/511-L7805ABV)      |
|   1  | DS1813 reset / voltage monitor | U7           | [Maxim Integrated DS1813-5+](https://au.mouser.com/ProductDetail/700-DS1813-5%2b)    |

### Connectors

Notes on connectors:

- If you use the exact parts here, then one of the 2x20 headers needs to be snapped apart to populate 2x6 footprints at J4 and J5.
- The shunts at J3 should be installed to connect the VIA to IRQ, and the ACIA to NMI. These are labelled on the PCB.

| Qty. | Description                       | Installed at | Product ref.                                                                                           |
| ---- | --------------------------------- | ------------ | ------------------------------------------------------------------------------------------------------ |
|    2 | 2x20 male pin header              | J1, J4, J5   | [Amphenol FCI 10129381-940002BLF](https://au.mouser.com/ProductDetail/649-1012938194002BLF)            |
|    1 | Barrel jack                       | J2           | [Adafruit 373](https://au.mouser.com/ProductDetail/485-373)                                            |
|    1 | 1x6 male pin header               | J6           | [Amphenol FCI 10129378-906001BLF](https://au.mouser.com/ProductDetail/Amphenol-FCI/10129378-906001BLF) |
|    2 | SPDT switch 2.54mm lead spacing   | SW1, SW2     | [SparkFun COM-00102](https://au.mouser.com/ProductDetail/474-COM-00102)                                |
|    1 | Momentary switch                  | SW3          | [SparkFun COM-00097](https://au.mouser.com/ProductDetail/474-COM-00097)                                |
|    2 | 1x2 male pin header               | J3           | [Amphenol FCI 10129378-902001BLF](https://au.mouser.com/ProductDetail/649-1012937890201BLF)            |
|    2 | Shunt/jumper                      | J3           | [TE Connectivity 2-382811-1](https://au.mouser.com/ProductDetail/571-2-382811-1)                       |

### Basic components

| Qty. | Description                                             | Installed at                         | Product ref.                                                |
| ---- | ------------------------------------------------------- | ------------------------------------ | ----------------------------------------------------------- |
|    1 | 0.1 µF ceramic capacitor, 2.54mm lead spacing (10 pack) | C1, C2, C3, C4, C5, C6, C7, C8, C10  | [Adafruit 753](https://au.mouser.com/ProductDetail/485-753) |
|    1 | 1 µF electrolytic capacitor, 1.5mm lead spacing         | C9                                   | –                                                           |
|    1 | 1N5819 schottky diode                                   | D1                                   | –                                                           |
|    1 | 5.0 mm LED                                              | D2                                   | –                                                           |
|    3 | 3.3 kΩ resistor 1/4w                                    | R1 R2 R4                             | –                                                           |
|    1 | 1 kΩ resistor 1/4w                                      | R3                                   | –                                                           |

## Additional parts to install in case

| Qty. | Description                                              | Product ref.                                                                                                 |
| ---- | -------------------------------------------------------- | ------------------------------------------------------------------------------------------------------------ |
|    1 | 16mm Illuminated Pushbutton - Red Latching On/Off Switch | [Adafruit 1442](https://core-electronics.com.au/16mm-illuminated-pushbutton-red-latching-on-off-switch.html) |
|    1 | 330 Ω resistor 1/4w                                      | –                                                                                                            |
|    1 | Momentary Button - Panel Mount                           | [SparkFun COM-11006](https://core-electronics.com.au/momentary-button-panel-mount-black.html)                |
|    1 | Piezo Buzzer                                             | [TDK PS1240P02BT](https://core-electronics.com.au/piezo-buzzer-ps1240.html)                                  |
|    4 | M3 x 5+6mm hex standoff                                  | Generic, similar to [this](https://www.minikits.com.au/SPA-M3x5-6-B-C)                                       |
|    4 | M3 nut                                                   | [Polulu 1069](https://core-electronics.com.au/machine-hex-nut-m3-25-pack.html)                               |
|    4 | M3 x 5 mm screw                                          | [Polulu 1075](https://core-electronics.com.au/machine-screw-m3-5mm-length-phillips-25-pack.html)             |
|    1 | Heat-shrink tubing kit                                   | [Adafruit 344](https://core-electronics.com.au/heat-shrink-pack.html)                                        |
|    1 | Stranded wire                                            | –                                                                                                            |
|    1 | Du Pont connector kit                                    | –                                                                                                            |
|    1 | FTDI Cable 5V (FT232RQ-based)                            | [Sparkfun DEV-09718](https://core-electronics.com.au/ftdi-cable-5v.html)                                     |
|    1 | Adhesive rubber feet                                     | [Adafruit 550](https://core-electronics.com.au/little-rubber-bumper-feet-pack-of-4.html)                     |

### Case installation notes

First solder three pairs of wires to the underside of the PCB for adding connectors. Each wire is soldered to the PCB on one end, with a female Du Pont connector on the other end (2 x 1 housing).

- Power: Attach to pins 1 and 2 of SW1 to control DC barrel jack, or attach between Pin 4 of J6 (labelled `NC`) and Pin 1 of J5 (labelled `5V`) for power over USB.
- Reset: Connect to underside of SW3. One wire should attach to `GND`, the other to `RES`.
- Speaker: Connect to underside of J1, at pins 24 (labelled `IO2`) and pin 2 (labelled `GND`).

Next, add the corresponding connectors to the power/reset buttons and speaker.

- Power: Solder a wire to each power terminal, and terminate it to a 2x1 male Du Point connector. Solder a wire to each LED terminal, adding a resistor on the GND line, and terminating them to a 2x1 female Du Pont connector.
- Reset: Solder wire to each terminal, terminate to a 2x1 male Du Pont connector
- Speaker: Solder wire to each terminal, terminate to a 2x1 male Du Pont connector

To assemble, first check that the reset button fits (the hole is too small in the case model, and will need to be expanded). Install stand-offs, then feed the UART cable through the oval-shaped hole. Next, add the PCB, and install the power and reset buttons. After this, you can connect the UART cable, power button, and reset button to the board. The power LED connects to pin 1 and 2 of J5. The final step is to super-glue the speaker over the hole at the back of the case.

## Additional parts to install microSD

Some of the test programs in this repository expect an SD card to be connected. Any 5V-compatible microSD break-out board could be used. These exact parts will fit inside the case with the lid closed.

| Qty. | Description                                              | Product ref.                                                                                          |
| ---- | -------------------------------------------------------- | ----------------------------------------------------------------------------------------------------- |
|    1 | Level Shifting microSD Breakout                          | [Sparkfun DEV-13743](https://core-electronics.com.au/sparkfun-level-shifting-microsd-breakout.html)   |
|    1 | 1x7 male pin header                                      | Generic, similar to [this](https://au.mouser.com/ProductDetail/Amphenol-FCI/10129378-907001BLF)       |
|    1 | 1x7 female pin header                                    | [Polulu 1017](https://core-electronics.com.au/0-100-2-54-mm-female-header-1x7-pin-straight.html)      |
|    1 | 2x6 female Du Pont housing                               | [Polulu 1914](https://core-electronics.com.au/0-1-2-54mm-crimp-connector-housing-2x6-pin-5-pack.html) |
|    1 | microSD card 16 GB                                       | –                                                                                                     |

### microSD installation notes

These parts can be used to install a microSD card in the case, attaching to J4. The card sits parallel to J4.

Glue the female pin header to the side of the Du Pont housing to make an adapter. You will need 6 wires, soldered on one end, and with a female Du Pont connector on the other end:

- Pin 1 (labelled `5V`) connects to `VCC`
- Pin 2 (labelled `GND`) connects to `GND`
- Pin 5 (labelled `PA0`) connects to `DO`
- Pin 6 (labelled `PA1`) connects to `SCK`
- Pin 7 (labelled `PA2`) connects to `DI`
- Pin 8 (labelled `PA3`) connects to `CS`

Solder the male pin headers to the microSD breakout, connect the module to the adapter, and attach it to J4. Wiggle it around a bit, and add insulating tape to anything it can contact. You can then fit an SD card.
