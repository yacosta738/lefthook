#!/bin/bash
# SPDX-FileCopyrightText: Copyright Yuniel Acosta, CU
# SPDX-License-Identifier: MIT

# setup-commitlint.sh
# Script to automatically set up commitlint configuration from remote

set -e

echo "🔧 Setting up commitlint configuration..."

# Check if we have a commitlint config already
if [ -f "commitlint.config.js" ] || [ -f "commitlint.config.mjs" ] || [ -f ".commitlintrc.js" ]; then
    echo "✅ commitlint configuration already exists. Skipping..."
    exit 0
fi

# Find the remote commitlint config
REMOTE_CONFIG=$(find .git/info/lefthook-remotes -name "commitlint.config.js" 2>/dev/null | head -1)

if [ -z "$REMOTE_CONFIG" ]; then
    echo "❌ Remote commitlint configuration not found."
    echo "   Make sure you have run 'lefthook install' first."
    exit 1
fi

# Copy the configuration
cp "$REMOTE_CONFIG" ./commitlint.config.js
echo "✅ Copied commitlint configuration from remote to ./commitlint.config.js"

echo "🎉 Setup complete! You can now customize the configuration if needed."
echo "📖 See https://commitlint.js.org/#/reference-configuration for more details."