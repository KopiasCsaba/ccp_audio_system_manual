#!/bin/bash
cd "$(dirname "$0")/.."
MD_TO_PDF=$(realpath "scripts/md_to_pdf.sh")

echo $MD_TO_PDF


# Use find to get a list of files
files=$(find . -type f | grep -E '\.md$' | grep -vE 'for_online_managers|streampc' | grep -v "README.md")

# Iterate through the files using a for loop
for file in $files; do
  echo "Processing: $file"
   bash $MD_TO_PDF $file;
  # Add your actions or commands here for each file
done
