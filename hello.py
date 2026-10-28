#!/usr/bin/env python3

import os
import sys


def main():
    if len(sys.argv) != 2:
        print("Usage: python3 hello.py <file>")
        return 1

    filename = sys.argv[1]

    try:
        with open(filename, "rb") as file:
            data = file.read()

        print(f"File: {filename}")
        print(f"Size: {len(data)} bytes")

        return 0

    except OSError as error:
        print(f"Error: {error}", file=sys.stderr)
        return 1


if __name__ == "__main__":
    sys.exit(main())

