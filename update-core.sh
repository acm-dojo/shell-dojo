#!/bin/bash

# A vibe script to update the 'core' submodule to the latest commit
# from its 'main' branch, and then commit and push this change
# in the parent repository.

SUBMODULE_DIR="core"
SUBMODULE_BRANCH="main"

GREEN='\033[0;32m'
YELLOW='\033[1;33m'
RED='\033[0;31m'
NC='\033[0m' # No Color

# Exit immediately if a command exits with a non-zero status.
set -e

# --- 1. Safety Checks ---
echo -e "${YELLOW}Running safety checks...${NC}"

# Check if we are in a git repository
if ! git rev-parse --is-inside-work-tree > /dev/null 2>&1; then
    echo -e "${RED}Error: Not inside a git repository. Exiting.${NC}"
    exit 1
fi

# Check if the submodule directory exists
if [ ! -d "$SUBMODULE_DIR" ]; then
    echo -e "${RED}Error: Submodule directory '$SUBMODULE_DIR' not found.${NC}"
    echo -e "${YELLOW}Did you forget to run 'git submodule update --init'?${NC}"
    exit 1
fi

# Check if the working directory is clean
if ! git diff-index --quiet HEAD --; then
    echo -e "${RED}Error: Your working directory is not clean.${NC}"
    echo -e "${YELLOW}Please commit or stash your changes before updating the submodule.${NC}"
    exit 1
fi

echo -e "${GREEN}Safety checks passed!${NC}"

# --- 2. Update the Submodule ---
echo -e "\n${YELLOW}Updating submodule '$SUBMODULE_DIR'...${NC}"

# Navigate into the submodule, checkout the desired branch, and pull the latest changes
( # Run in a subshell to avoid needing to 'cd ..'
  cd "$SUBMODULE_DIR"
  echo "Checking out '$SUBMODULE_BRANCH' branch in submodule..."
  git checkout "$SUBMODULE_BRANCH"
  echo "Pulling latest changes from origin..."
  git pull origin "$SUBMODULE_BRANCH"
)

# --- 3. Commit the Update in the Parent Repository ---
# Check if the submodule was actually updated
if git diff --quiet -- "$SUBMODULE_DIR"; then
    echo -e "\n${GREEN}'$SUBMODULE_DIR' is already up to date. No changes to commit.${NC}"
    exit 0
fi

echo -e "\n${YELLOW}Submodule updated. Staging and committing in the parent repository...${NC}"

# Get the new commit hash from the submodule for the commit message
NEW_COMMIT_HASH=$(cd "$SUBMODULE_DIR" && git rev-parse --short HEAD)
COMMIT_MSG="chore: update '$SUBMODULE_DIR' to commit $NEW_COMMIT_HASH"

# Stage the submodule change
git add "$SUBMODULE_DIR"

# Commit the change
git commit -m "$COMMIT_MSG"

if [[ $* == *--no-push* ]]; then
    echo -e "\n${YELLOW}--no-push flag detected. Skipping push to remote.${NC}"
    exit 0
fi

# Push the commit to the remote repository
echo -e "\n${YELLOW}Pushing changes to remote...${NC}"
git push origin main
echo -e "${GREEN}✔ Changes pushed successfully!${NC}"