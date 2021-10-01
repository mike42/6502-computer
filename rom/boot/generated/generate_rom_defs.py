"""
generate_rom_defs.py:

Reads CC65 debug information from the ROM, and save label/constant definitions to rom_defs.s.
"""
import os
from dataclasses import dataclass
from typing import List


@dataclass
class DebugLine:
    """ One line of debug output """
    line_type: str
    values: dict

    @staticmethod
    def _process_value(key: str, val: str):
        if key == "ref":
            # List of values
            return [DebugLine._process_value("_" + key, x) for x in val.split("+")]
        if val.startswith("\""):
            # String
            return val.strip("\"")
        if val.startswith("0x"):
            # Hex value, change to format suitable for inclusion in assembler source.
            hex_str = val[2:].lower()
            if len(hex_str) % 2 == 1:
                # Round out to even number
                return "$0" + hex_str
            return "$" + hex_str
        if not val.isnumeric():
            # enums like addrsize, type
            return val
        # Everything else is numeric, so parse it!
        return int(val)

    @staticmethod
    def from_str(line: str):
        """
        Slice up strings to read the line. General format is:

        scope	id=0,name="",mod=0,size=784,span=346+345+344
        """
        # eg. 'scope', 'major=2,minor=0'
        line_type, kv_pairs_str = line.strip().split("\t", maxsplit=1)
        # eg. [['major', '2'], ['minor', '0']]
        key_value_list = [x.split("=", maxsplit=1) for x in kv_pairs_str.split(",")]
        # into dictionary, unquote quoted fields
        values = {x: DebugLine._process_value(x, v) for x, v in key_value_list}
        return DebugLine(line_type, values)


def read_symbols_from_lines(lines: List[str]) -> List[DebugLine]:
    return [DebugLine.from_str(x) for x in lines]


def is_interersting_line(line: DebugLine) -> bool:
    if line.line_type != "sym": # Only interested in symbols
        return False
    if 'parent' in line.values: # Local labels
        return False
    return True


def filter_debug_symbols(lines: List[DebugLine]) -> List[DebugLine]:
    interesting_lines = [x for x in lines if is_interersting_line(x)]
    return sorted(interesting_lines, key=lambda x: x.values['name'])


"""
; locations of some functions in ROM
.export acia_print_char := $c014
.export acia_recv_char  := $c020
.export shell_newline   := $c113
.export sys_exit        := $c11e

"""
if __name__ == "__main__":
    script_dir = os.path.dirname(__file__)
    source_file = os.path.join(script_dir, "../boot.dbg")
    dest_file = os.path.join(script_dir, "rom_defs.s")
    with open(source_file) as f:
        all_defs = read_symbols_from_lines(f.readlines())
    filtered_defs = filter_debug_symbols(all_defs)
    with open(dest_file, "w") as f:
        for symbol in filtered_defs:
            name = symbol.values['name']
            val = symbol.values['val']
            if symbol.values['type'] == "lab":
                f.write(f".export {name:32} := {val}\n")
            else:
                f.write(f".export {name:32} = {val}\n")
