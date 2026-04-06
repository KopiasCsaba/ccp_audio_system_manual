#!/bin/bash
cd "$(dirname "$0")"
inkscape schematic.svg --export-dpi 600 -o schematic.png
dot -Tpng -Gdpi=150 workflow_graph.dot -o workflow_graph.png