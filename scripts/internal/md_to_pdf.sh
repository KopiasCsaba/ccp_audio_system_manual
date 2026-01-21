#!/bin/bash

set -e

INPUT_MD_PATH=$(realpath "$1")
PDF_PATH="$(dirname $(realpath "$1"))/$(basename "$1" .md).pdf"
WORK_DIR=$(dirname "$INPUT_MD_PATH")

# Create temporary directory for latex processing
TEMP_DIR=$(mktemp -d)
trap "rm -rf $TEMP_DIR; rm -f $WORK_DIR/.tmp.html" EXIT

FILE_FOOTER=$(basename "$INPUT_MD_PATH" .md)
FILE_FOOTER=${FILE_FOOTER^^}
FILE_FOOTER="${FILE_FOOTER//_/ }"


echo "CONVERTING $INPUT_MD_PATH"

if [ -z "$ALL" ]; then
  if [ -f "$PDF_PATH" ]; then
    pdf_modification_time=$(stat -c %Y "$PDF_PATH")
    input_file_modification_time=$(stat -c %Y "$INPUT_MD_PATH")

    # Compare the timestamps and perform an action
    if [[ $input_file_modification_time -lt $pdf_modification_time ]]; then
      echo "PDF is up to date."
      exit
    fi
  fi
fi

cat >$WORK_DIR/.tmp.html <<EOF
<!doctype html>
<html lang=en-US>
<head>
<style>
body {
font-family: Roboto;
  font-family: 'Georgia', serif;
}

table {
border:1px solid black;
border-collapse:collapse;
}
tr, td, th {
border:1px solid black;
}

th {
font-weight:bold;
}

img {
padding: 1px;
margin: 1px;
border: 1px solid gray;
}

a {
color: #34315b;
}

ul, ol {
padding-bottom: 7px;
}

</style>
<meta charset=utf-8>
</head>
<body>
<div id="container">

EOF

pandoc -f markdown "$INPUT_MD_PATH" >> $WORK_DIR/.tmp.html 2>/dev/null

cat >>$WORK_DIR/.tmp.html <<EOF
</div>

</body>
</html>
EOF

# Remove TOC
#sed -i '/<!-- TOC -->/,/<!-- TOC -->/d' $WORK_DIR/.tmp.html

# Run brave from the markdown directory so relative image paths work
cd "$WORK_DIR"

# Use timeout to prevent hanging (30 seconds max)
echo "Converting HTML to PDF..."
timeout 30 brave-browser \
    --headless=new \
    --no-sandbox \
    --disable-setuid-sandbox \
    --disable-gpu \
    --disable-dev-shm-usage \
    --disable-software-rasterizer \
    --disable-extensions \
    --disable-background-networking \
    --disable-sync \
    --disable-features=VizDisplayCompositor \
    --no-first-run \
    --mute-audio \
    --password-store=basic \
    --no-pdf-header-footer \
    --print-to-pdf=$TEMP_DIR/tmp.pdf \
    .tmp.html 2>&1 | grep -v "ERROR:dbus" | grep -v "ERROR:bus.cc" | grep -v "ERROR:components" || {
    echo "ERROR: brave-browser failed or timed out"
    exit 1
}

# Clean up HTML file
rm .tmp.html

cat >$TEMP_DIR/pagenumber.latex <<EOF
\documentclass[8pt]{article}
\usepackage[final]{pdfpages}
\usepackage{fancyhdr}

\topmargin 70pt
\oddsidemargin 70pt

\pagestyle{fancy}
\fancyfoot{}
\fancyfoot[R]{\vspace*{8pt} $FILE_FOOTER / \thepage}
\renewcommand{\headrulewidth}{0pt}
\renewcommand{\footrulewidth}{0pt}
\fancyfootoffset{2cm} % Adjust this value as needed

\begin{document}
\includepdfset{pagecommand=\thispagestyle{fancy}}
\includepdf[fitpaper=true,scale=1,pages=-]{tmp.pdf}
\end{document}

EOF
cd $TEMP_DIR
echo "Adding page numbers with pdflatex..."
pdflatex -interaction=nonstopmode pagenumber.latex > /dev/null || {
    echo "ERROR: pdflatex failed"
    exit 1
}

mv pagenumber.pdf $PDF_PATH
echo "✓ Created: $PDF_PATH"
