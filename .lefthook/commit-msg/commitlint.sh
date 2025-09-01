#!/usr/bin/env bash

# SPDX-FileCopyrightText: Copyright Yuniel Acosta, CU
# SPDX-License-Identifier: MIT

# Run commitlint.sh script to lint commit messages
# based on the conventional commits specification.
# https://www.conventionalcommits.org/en/v1.0.0/
# 
# Emoji rules when ALLOW_EMOJIS=true:
# - Emojis are allowed ONLY after the colon (:) in the title
# - Emojis are allowed anywhere in the commit body
# - Emojis are NOT allowed in type or scope parts
#
# Valid:   feat(scope): 🎉 description
# Invalid: 🎉 feat(scope): description
# Invalid: feat(🎉scope): description
# 
# Create a new .commitlint configuration environment file
# in the root project to override the default configuration.

set -euo pipefail

# error message function printing in red color
# usage: error "message"
error() {
    local message=${1:-""}
    echo -e "\033[0;31m${message}\033[0m"
}

# validate input file (avoid set -u pitfalls)
if [ "$#" -lt 1 ]; then
    error "Usage: $0 <path-to-commit-msg-file>"
    exit 1
fi
if [ ! -f "${1:-}" ]; then
    error "Commit message file not found: ${1:-<missing>}"
    exit 1
fi

commitTitle=$(head -n1 "${1}")
configurationFile=".commitlint"

# source configuration environment file if exists
if [ -f "$configurationFile" ]; then
    # shellcheck source=/dev/null
    source "$configurationFile"
fi

# default values for environment variables
export MAX_COMMIT_MESSAGE_LENGTH=${MAX_COMMIT_MESSAGE_LENGTH:-80}
# valid commit prefix types for semantic versioning
export VALID_COMMIT_PREFIXES=${VALID_COMMIT_PREFIXES:-"build|chore|ci|docs|feat|fix|perf|refactor|revert|style|test"}
# allow emojis in commit messages
export ALLOW_EMOJIS=${ALLOW_EMOJIS:-true}

# check if the commit message contains merge patterns to skip validation
if echo "$commitTitle" | grep -qE 'Merge (branch|pull request)'; then
    echo "Skipping commit message check for merge commits"
    exit 0
fi

# check commit message length
if [ ${#commitTitle} -gt "${MAX_COMMIT_MESSAGE_LENGTH}" ]; then
    error "Your commit message is too long: ${#commitTitle} characters"
    exit 1
fi

# check if the commit message is valid for semantic versioning
# Use a unified pattern that works for both emoji and non-emoji cases
# The pattern requires at least one non-space character after the colon and space
commit_pattern='^('"${VALID_COMMIT_PREFIXES}"')(\([^)]+\))?!?:\s+.+'

# If emojis are enabled, do additional validation
if [ "$ALLOW_EMOJIS" = "true" ]; then
    # Check for common emoji patterns before the colon (simple heuristic)
    title_before_colon=$(echo "$commitTitle" | sed 's/:.*$//')
    if echo "$title_before_colon" | grep -q '🎉\|🔥\|✨\|🚀\|🐛\|💥\|🔐\|📝\|🎨\|⚡\|🏗️\|🔧\|🌐\|📱\|💻\|🖥️\|⌚\|📺\|🔊\|🔇\|📢\|📣\|📯\|🔔\|🔕\|📻\|📱\|📞\|☎️\|📟\|📠\|📧\|📨\|📩\|📪\|📫\|📬\|📭\|📮\|🗳️\|✏️\|✒️\|🖋️\|🖊️\|🖌️\|🖍️'; then
        error "Emojis are not allowed in type or scope, only after the colon (:)"
        echo "❌ Invalid: 🎉 feat: add feature"
        echo "❌ Invalid: feat(🎉 scope): add feature"
        echo "✅ Valid: feat: 🎉 add feature"
        echo "✅ Valid: feat(scope): add feature 🎉"
        exit 1
    fi
fi

if ! echo "$commitTitle" | grep -qE "$commit_pattern"; then
    error "Your commit message is not valid for semantic versioning: \"$commitTitle\""

    echo
    echo "Format: <type>(<scope>): <subject>"
    if [ "$ALLOW_EMOJIS" = "true" ]; then
        echo "Emojis allowed only after colon:"
        echo "✅ Valid: feat(auth): 🎉 add login feature"
        echo "✅ Valid: feat(auth): add login feature 🎉"
        echo "❌ Invalid: 🎉 feat(auth): add login feature"
        echo "❌ Invalid: feat(🎉auth): add login feature"
    fi
    echo "Scope: optional"
    echo "Example: feat(auth): add login feature"
    echo
    echo "Exclamation mark (!) is optional and can be used to indicate breaking changes."
    echo "Use it before colon (:). i.e. feat(auth)!: add login feature"
    echo
    echo "Valid types: ${VALID_COMMIT_PREFIXES//|/,}"
    echo

    exit 1
fi

# Check for BREAKING CHANGE in commit body/footer
commit_body=$(cat "${1}")
if echo "$commit_body" | grep -qE '(BREAKING CHANGE:|BREAKING-CHANGE:)'; then
    echo "✓ Breaking change detected in commit body/footer"
fi