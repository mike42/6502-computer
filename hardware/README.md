# 6502 computer hardware

This directory contains information about the hardware side of this project.

- [kicad/](https://github.com/mike42/6502-computer/tree/main/hardware/kicad) - CAD source files for schematic and PCB
- [gerber/](https://github.com/mike42/6502-computer/tree/main/hardware/gerber/) - PCB manufacturing files 
- [6502_computer_schematic.pdf](https://github.com/mike42/6502-computer/tree/main/hardware/6502_computer_schematic.pdf) - Human-readable schematic
- [case/](https://github.com/mike42/6502-computer/tree/main/hardware/case/) - STL files for 3D printed computer case.
- Parts list (below)

## Parts list for PCB only

This is the full list of parts which are required to fully populate the PCB for this build. I've stuck with the parts which I actually used, though many can be substituted if you check the data sheets.

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

- If you use the exact parts here, then one of the 2x20 headers needs to be snapped apart to populate 2x6 footprints at J4 and J5, and two 1x2 headers are used to populate J3.
- The shunts at J3 should be installed to connect the VIA to IRQ, and the ACIA to NMI. These are labelled on the PCB.

| Qty. | Description                       | Installed at | Product ref.                                                                                 |
| ---- | --------------------------------- | ------------ | -------------------------------------------------------------------------------------------- |
|    2 | 2x20 male pin header              | J1, J4, J5   | [Amphenol FCI 10129381-940002BLF](https://au.mouser.com/ProductDetail/649-1012938194002BLF)  |
|    1 | Barrel jack                       | J2           | [Adafruit 373](https://au.mouser.com/ProductDetail/485-373)                                  |
|    1 | 1x6 female pin header             | J6           | [Harwin M20-7820646](https://au.mouser.com/ProductDetail/855-M20-7820646)                    |
|    2 | SPDT switch 2.54mm lead spacing   | SW1, SW2     | [SparkFun COM-00102](https://au.mouser.com/ProductDetail/474-COM-00102)                      |
|    1 | Momentary switch                  | SW3          | [SparkFun COM-00097](https://au.mouser.com/ProductDetail/474-COM-00097)                      |
|    2 | 1x2 male pin header               | J3           | [Amphenol FCI 10129378-902001BLF](https://au.mouser.com/ProductDetail/649-1012937890201BLF)  |
|    2 | Shunt/jumper                      | J3           | [TE Connectivity 2-382811-1](https://au.mouser.com/ProductDetail/571-2-382811-1)             |

### Basic components

There is no product link for most of these, since I'm using items from capacitor/resistor/LED/diode packs.

| Qty. | Description                                            | Installed at                         | Product ref.                                                |
| ---- | ------------------------------------------------------ | ------------------------------------ | ----------------------------------------------------------- |
|    1 | 0.1µF ceramic capacitor, 2.54mm lead spacing (10 pack) | C1, C2, C3, C4, C5, C6, C7, C8, C10  | [Adafruit 753](https://au.mouser.com/ProductDetail/485-753) |
|    1 | 1µF electrolytic capacitor, 1.5mm lead spacing         | C9                                   |                                                             |
|    1 | 1N5819 schottky diode                                  | D1                                   |                                                             |
|    1 | 5.0mm LED                                              | D2                                   |                                                             |
|    3 | 3.3k resistor 1/4w                                     | R1 R2 R4                             |                                                             |
|    1 | 1k resistor 1/4w                                       | R3                                   |                                                             |

## Extra parts for installing in case

TBD.

