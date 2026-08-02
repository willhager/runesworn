#!/usr/bin/env python3
"""
prefix_vars.py

Prefixes specific bare variable references with "GameState." throughout a
GDScript (or similar) file, for migrating locals to an autoloaded singleton.

- Only whole-identifier matches are replaced (no partial-word hits like
  "maxHealthBar").
- Already-prefixed references (e.g. GameState.enemyHealth) are left alone.
- Contents of string literals and comments are left untouched.
- Lines that *declare* one of these variables (e.g. "var enemyHealth : int")
  are left untouched, so you can safely run this against the autoload file
  itself without corrupting its own declarations.
- All original whitespace/line endings are preserved exactly; only the
  matched identifiers are modified.

Usage:
    python prefix_vars.py path/to/file.gd
    python prefix_vars.py path/to/file.gd -o path/to/output.gd
    python prefix_vars.py path/to/file.gd --in-place
"""

import argparse
import re
import sys
from pathlib import Path

# The variables to prefix, e.g. "enemyHealth" -> "GameState.enemyHealth"
VARIABLES = [
    "enemyHealth",
    "maxHealth",
    "enemy_damage",
    "enemy_heal",
    "enemy_shield",
    "enemy_piercing",
    "enemy_poison_counter",
    "EDice",
    "eDiceRolls",
]

PREFIX = "GameState."

# Matches string literals (single or double quoted, with basic escape
# handling) and line comments. We use this to mask off regions of each
# line that should NOT have substitutions applied.
_STRING_OR_COMMENT_RE = re.compile(
    r'(#.*$'                       # line comment to end of line
    r'|"(?:\\.|[^"\\])*"'          # double-quoted string
    r"|'(?:\\.|[^'\\])*')",        # single-quoted string
    re.MULTILINE,
)

# Build one alternation regex for all target variable names, longest first
# so e.g. "enemy_poison_counter" is tried before any shorter overlapping name.
_VAR_ALTERNATION = "|".join(sorted((re.escape(v) for v in VARIABLES), key=len, reverse=True))

# \b...\b for whole-identifier matching, with a negative lookbehind so we
# don't double-prefix something already written as GameState.varName
# (or Something.varName in general -- any preceding '.' means "leave it").
_VAR_RE = re.compile(r"(?<!\.)\b(" + _VAR_ALTERNATION + r")\b")

# Detects a declaration line for one of our target variables, e.g.:
#   var enemyHealth : int
#   var enemy_damage: int = 0
_DECL_RE = re.compile(
    r"^\s*var\s+(" + _VAR_ALTERNATION + r")\b"
)


def prefix_code_segment(code: str) -> str:
    """Apply GameState. prefixing to a segment known to contain only code
    (no string/comment content)."""
    return _VAR_RE.sub(lambda m: PREFIX + m.group(1), code)


def prefix_line(line: str) -> str:
    """Prefix target variables in a single line, skipping string/comment
    contents and skipping declaration lines entirely."""
    if _DECL_RE.match(line):
        # Leave variable declarations untouched.
        return line

    # Split the line into alternating [code, string/comment, code, ...]
    # segments, only touching the code segments.
    parts = _STRING_OR_COMMENT_RE.split(line)
    for i in range(0, len(parts), 2):  # even indices are non-matched (code)
        parts[i] = prefix_code_segment(parts[i])
    return "".join(parts)


def process_text(text: str) -> str:
    """Process a whole file's text, preserving original line endings."""
    # splitlines(keepends=True) preserves \n, \r\n, etc. per line so we can
    # reassemble the file exactly as it was, whitespace and all.
    lines = text.splitlines(keepends=True)
    return "".join(prefix_line(line) for line in lines)


def main():
    parser = argparse.ArgumentParser(
        description="Prefix specific variables with 'GameState.' in a code file."
    )
    parser.add_argument("input_file", help="Path to the file to process")
    parser.add_argument(
        "-o", "--output",
        help="Path to write the result to. Defaults to '<name>_migrated<ext>' "
             "next to the input file.",
    )
    parser.add_argument(
        "--in-place",
        action="store_true",
        help="Overwrite the input file instead of writing a new one.",
    )
    args = parser.parse_args()

    in_path = Path(args.input_file)
    if not in_path.is_file():
        print(f"Error: '{in_path}' is not a file.", file=sys.stderr)
        sys.exit(1)

    # newline="" preserves original line endings exactly (no translation).
    with open(in_path, "r", encoding="utf-8", newline="") as f:
        original_text = f.read()

    new_text = process_text(original_text)

    if args.in_place:
        out_path = in_path
    elif args.output:
        out_path = Path(args.output)
    else:
        out_path = in_path.with_name(f"{in_path.stem}_migrated{in_path.suffix}")

    with open(out_path, "w", encoding="utf-8", newline="") as f:
        f.write(new_text)

    print(f"Wrote migrated file to: {out_path}")


if __name__ == "__main__":
    main()