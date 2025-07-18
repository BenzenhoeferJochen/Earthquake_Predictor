#!/usr/bin/env python3

import json
import os
import sys


def usage():
    print("Usage: templetize_folder.py <source_dir> <dest_dir> <vars_json_path>")
    sys.exit(1)


if len(sys.argv) != 4:
    usage()

source_dir = sys.argv[1]
dest_dir = sys.argv[2]
vars_json_path = sys.argv[3]

if not os.path.isdir(source_dir):
    print(f"[!] Source directory not found: {source_dir}")
    sys.exit(1)

if not os.path.isfile(vars_json_path):
    print(f"[!] Variable JSON file not found: {vars_json_path}")
    sys.exit(1)

os.makedirs(dest_dir, exist_ok=True)

# Load variable mapping: { "hardcoded_value": "terraform_var_name" }
with open(vars_json_path, "r") as f:
    value_to_var = json.load(f)


def templetize(content: str, mapping: dict) -> str:
    for value, var_name in mapping.items():
        content = content.replace(str(var_name), f"${{{value}}}")
    return content


# Process files
for root, _, files in os.walk(source_dir):
    for filename in files:
        if filename.endswith(".backup") or filename.__contains__("-lock"):
            continue
        src_path = os.path.join(root, filename)
        rel_path = os.path.relpath(src_path, source_dir)
        dst_path = os.path.join(dest_dir, rel_path)

        os.makedirs(os.path.dirname(dst_path), exist_ok=True)

        with open(src_path, "r") as src_file:
            content = src_file.read()

        templated = templetize(content, value_to_var)

        with open(dst_path, "w") as dst_file:
            dst_file.write(templated)

        print(f"[+] Templated: {rel_path} -> {dst_path}")
