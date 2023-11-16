#!/bin/bash

set -e

INPUT_MD_PATH=$(realpath "$1")
PDF_PATH="$(dirname $(realpath "$1"))/$(basename "$1" .md).pdf"

cd $(dirname "$1")

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

cat >tmp.html <<EOF
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

pandoc -f markdown "$INPUT_MD_PATH" >> tmp.html  2>/dev/null

cat >>tmp.html <<EOF
</div>

</body>
</html>
EOF

# Remove TOC
#sed -i '/<!-- TOC -->/,/<!-- TOC -->/d' tmp.html

google-chrome --headless --no-pdf-header-footer --print-to-pdf=tmp.pdf tmp.html >/dev/null 2>&1

cat >pagenumber.latex <<EOF
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
pdflatex pagenumber.latex

rm tmp.pdf tmp.html pagenumber.log pagenumber.aux pagenumber.latex
mv pagenumber.pdf $PDF_PATH
