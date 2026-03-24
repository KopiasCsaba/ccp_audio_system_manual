#!/bin/bash
cd "$(dirname "$0")"
inkscape schematic.svg --export-dpi 600 -o schematic.png