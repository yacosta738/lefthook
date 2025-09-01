#!/usr/bin/env bash

# SPDX-FileCopyrightText: Copyright Yuniel Acosta, CU
# SPDX-License-Identifier: MIT

# Test script for commitlint.sh
# This script tests various commit message formats to ensure they are properly validated

set -euo pipefail

# Colors for output
GREEN='\033[0;32m'
RED='\033[0;31m'
BLUE='\033[0;34m'
NC='\033[0m' # No Color

# Test counter
TESTS_PASSED=0
TESTS_FAILED=0

test_commit_message() {
    local message="$1"
    local expected_result="$2"  # "pass" or "fail"
    local description="$3"
    
    echo -e "${BLUE}Testing:${NC} $description"
    echo -e "${BLUE}Message:${NC} \"$message\""
    
    # Create temporary commit message file
    local temp_file=$(mktemp)
    echo "$message" > "$temp_file"
    
    # Run commitlint script
    if ./.lefthook/commit-msg/commitlint.sh "$temp_file" >/dev/null 2>&1; then
        local actual_result="pass"
    else
        local actual_result="fail"
    fi
    
    # Check result
    if [ "$actual_result" = "$expected_result" ]; then
        echo -e "${GREEN}✅ PASS${NC}"
        ((TESTS_PASSED++))
    else
        echo -e "${RED}❌ FAIL${NC} - Expected: $expected_result, Got: $actual_result"
        ((TESTS_FAILED++))
    fi
    
    # Cleanup
    rm -f "$temp_file"
    echo
}

echo "🧪 Running commitlint tests..."
echo

# Valid conventional commits
test_commit_message "feat: add new feature" "pass" "Basic feat commit"
test_commit_message "fix: resolve bug in authentication" "pass" "Basic fix commit"
test_commit_message "docs: update README" "pass" "Basic docs commit"
test_commit_message "feat(auth): add OAuth2 support" "pass" "Commit with scope"
test_commit_message "feat!: breaking change" "pass" "Breaking change with !"
test_commit_message "feat(api)!: major API change" "pass" "Breaking change with scope and !"

# Valid commits with emojis (only after colon in title)
test_commit_message "feat: 🎉 add celebration feature" "pass" "Emoji after colon"
test_commit_message "feat: add celebration feature 🎉" "pass" "Emoji at end of title"
test_commit_message "feat(party): 🎉 add celebration feature 🥳" "pass" "Multiple emojis after colon"
test_commit_message "fix(api): resolve bug 🐛" "pass" "Bug emoji in title"

# Invalid commits with emojis (before colon)
test_commit_message "🎉 feat: add celebration feature" "fail" "Emoji before type (not allowed)"
test_commit_message "feat(🎉party): add celebration feature" "fail" "Emoji in scope (not allowed)"
test_commit_message "feat(party🎉): add celebration feature" "fail" "Emoji at end of scope (not allowed)"

# Invalid commits
test_commit_message "invalid commit message" "fail" "No type prefix"
test_commit_message "feat add new feature" "fail" "Missing colon"
test_commit_message "feat:" "fail" "Missing description"
test_commit_message "feat: " "fail" "Empty description"
test_commit_message "FEAT: add new feature" "fail" "Uppercase type (if strict)"
test_commit_message "unknown: add new feature" "fail" "Invalid type"

# Edge cases
test_commit_message "feat(very-long-scope-name): add feature" "pass" "Long scope name"
test_commit_message "revert: let us never again speak of the noodle incident" "pass" "Revert commit"

# Merge commit tests
test_commit_message "Merge branch 'feature/auth' into main" "pass" "Merge branch commit"
test_commit_message "Merge pull request #123 from user/feature-branch" "pass" "Merge pull request commit"
test_commit_message "Merge branch 'very-long-feature-branch-name-that-exceeds-normal-commit-length-limits-significantly'" "pass" "Long merge branch commit"
test_commit_message "Merge pull request #456 from contributor/extremely-long-feature-branch-name-that-would-normally-fail-length-validation" "pass" "Long merge pull request commit"

# Multi-line commit (only testing first line)
multiline_commit="feat: add new feature

This is a longer description of the feature.

BREAKING CHANGE: This breaks the old API."
test_commit_message "$multiline_commit" "pass" "Multi-line commit with BREAKING CHANGE"

echo "📊 Test Results:"
echo -e "${GREEN}Passed: $TESTS_PASSED${NC}"
echo -e "${RED}Failed: $TESTS_FAILED${NC}"

if [ $TESTS_FAILED -eq 0 ]; then
    echo -e "${GREEN}🎉 All tests passed!${NC}"
    exit 0
else
    echo -e "${RED}💥 Some tests failed!${NC}"
    exit 1
fi
