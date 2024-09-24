#!/bin/bash

# Set the default commit message
DEFAULT_COMMIT_MESSAGE="Default commit message"

# Use the provided argument as the commit message, or use the default if not provided
COMMIT_MESSAGE=${1:-$DEFAULT_COMMIT_MESSAGE}

git add .
git commit -m "$COMMIT_MESSAGE"
git push
