#!/bin/bash

# Script to install iOS pods while excluding mobile_scanner due to Firebase conflict
# Usage: ./install_pods.sh

set -e

export LANG=en_US.UTF-8

echo "Step 1: Running flutter pub get..."
cd "$(dirname "$0")/.."
flutter pub get

echo "Step 2: Removing mobile_scanner from iOS plugins list..."
python3 << 'PYTHON_SCRIPT'
import json
import os

deps_file = '.flutter-plugins-dependencies'
if os.path.exists(deps_file):
    with open(deps_file, 'r') as f:
        data = json.load(f)
    # Remove mobile_scanner from iOS plugins list
    if 'plugins' in data and 'ios' in data['plugins']:
        data['plugins']['ios'] = [p for p in data['plugins']['ios'] if p['name'] != 'mobile_scanner']
    with open(deps_file, 'w') as f:
        json.dump(data, f, indent=2)
    print("mobile_scanner removed from iOS plugins list")
PYTHON_SCRIPT

echo "Step 3: Removing mobile_scanner symlink..."
cd ios
rm -rf .symlinks/plugins/mobile_scanner

echo "Step 4: Cleaning old pods..."
rm -rf Pods Podfile.lock

echo "Step 5: Installing pods..."
pod install --repo-update

echo "✅ Pod installation complete! mobile_scanner excluded from iOS build."
