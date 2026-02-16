#!/bin/bash

# Script to fix vulnerabilities found in Trivy scan
# Colors for output
RED='\033[0;31m'
GREEN='\033[0;32m'
YELLOW='\033[1;33m'
NC='\033[0m' # No Color

echo -e "${GREEN}========================================${NC}"
echo -e "${GREEN}Starting Vulnerability Fix Process${NC}"
echo -e "${GREEN}========================================${NC}"
echo ""

# Check if we're in the right directory
if [ ! -f "package.json" ]; then
    echo -e "${RED}Error: package.json not found!${NC}"
    echo -e "${YELLOW}Please run this script from your app directory${NC}"
    exit 1
fi

# Backup package.json and package-lock.json
echo -e "${YELLOW}Step 1: Creating backups...${NC}"
cp package.json package.json.backup
if [ -f "package-lock.json" ]; then
    cp package-lock.json package-lock.json.backup
    echo -e "${GREEN}✓ Backups created${NC}"
else
    echo -e "${YELLOW}! No package-lock.json found${NC}"
fi
echo ""

# Show current vulnerabilities
echo -e "${YELLOW}Step 2: Checking current vulnerabilities...${NC}"
npm audit
echo ""

# Update specific vulnerable packages
echo -e "${YELLOW}Step 3: Updating vulnerable packages...${NC}"
echo -e "${YELLOW}Updating cross-spawn to 7.0.5...${NC}"
npm install cross-spawn@7.0.5

echo -e "${YELLOW}Updating glob to 11.1.0...${NC}"
npm install glob@11.1.0

echo -e "${YELLOW}Updating tar to 7.5.7...${NC}"
npm install tar@7.5.7

echo -e "${GREEN}✓ Packages updated${NC}"
echo ""

# Run npm audit fix
echo -e "${YELLOW}Step 4: Running npm audit fix...${NC}"
npm audit fix
echo ""

# Check if vulnerabilities still exist
echo -e "${YELLOW}Step 5: Checking remaining vulnerabilities...${NC}"
AUDIT_RESULT=$(npm audit --json)
VULNERABILITIES=$(echo $AUDIT_RESULT | grep -o '"high":[0-9]*' | cut -d':' -f2)

if [ -z "$VULNERABILITIES" ] || [ "$VULNERABILITIES" -eq 0 ]; then
    echo -e "${GREEN}✓ All HIGH and CRITICAL vulnerabilities fixed!${NC}"
else
    echo -e "${YELLOW}! Some vulnerabilities may still exist${NC}"
    echo -e "${YELLOW}Running npm audit fix --force...${NC}"
    npm audit fix --force
fi
echo ""

# Final audit check
echo -e "${YELLOW}Step 6: Final vulnerability check...${NC}"
npm audit
echo ""

# Show what changed
echo -e "${YELLOW}Step 7: Summary of changes...${NC}"
echo -e "Package versions updated:"
echo -e "  - cross-spawn: $(npm list cross-spawn --depth=0 2>/dev/null | grep cross-spawn || echo 'Not found')"
echo -e "  - glob: $(npm list glob --depth=0 2>/dev/null | grep glob || echo 'Not found')"
echo -e "  - tar: $(npm list tar --depth=0 2>/dev/null | grep tar || echo 'Not found')"
echo ""

echo -e "${GREEN}========================================${NC}"
echo -e "${GREEN}Vulnerability Fix Process Complete!${NC}"
echo -e "${GREEN}========================================${NC}"
echo ""
echo -e "${YELLOW}Next steps:${NC}"
echo -e "1. Review the changes in package.json and package-lock.json"
echo -e "2. Test your application to ensure everything works"
echo -e "3. Rebuild your Docker image: ${GREEN}docker build -t mini-project .${NC}"
echo -e "4. Re-run Trivy scan: ${GREEN}trivy image --severity HIGH,CRITICAL mini-project${NC}"
echo ""
echo -e "${YELLOW}Note: Backups saved as:${NC}"
echo -e "  - package.json.backup"
echo -e "  - package-lock.json.backup"