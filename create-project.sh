#!/bin/bash

# Enable debugging to help identify issues
set -e  # Exit on error
#set -x  # Uncomment to debug

# Display brief usage instructions
display_usage() {
    echo "============================================================="
    echo "PROJECT CREATOR - USAGE INSTRUCTIONS"
    echo "============================================================="
    echo "1. Run with: ./create-project.sh [project_name]"
    echo "2. Enter project name when prompted if not provided as argument"
    echo "3. Create files by specifying name and program"
    echo "4. Supported programs: Photoshop, Illustrator, After-Effects"
    echo "============================================================="
}

# Create project folder structure only
create_project_structure() {
    local folder_name="$1"
    
    # If no project name was provided, ask for it
    if [ -z "$folder_name" ]; then
        read -p 'Enter the name of the project: ' folder_name
    fi
    
    # Ensure folder_name is not empty
    if [ -z "$folder_name" ]; then
        echo "Error: Project name cannot be empty" >&2
        exit 1
    fi
    
    # Set up absolute paths - Note: Using "Desktop" with capital D
    HOME_DIR="$HOME"
    PROJECTS_DIR="$HOME_DIR/Desktop/PROJECTS"
    PROJECT_PATH="$PROJECTS_DIR/$folder_name"
    TOOLS_DIR="$PROJECT_PATH/project-tools"
    
    echo "Creating project at: $PROJECT_PATH" >&2
    
    # Create project directories using mkdir -p to avoid errors
    mkdir -p "$PROJECTS_DIR"
    mkdir -p "$PROJECT_PATH"
    mkdir -p "$TOOLS_DIR"
    mkdir -p "$PROJECT_PATH/save-here"
    mkdir -p "$TOOLS_DIR/previous-versions"
    
    echo "Created project directory structure at: $PROJECT_PATH" >&2
    
    # Return the paths to be used by other functions (without any other output)
    echo "$PROJECT_PATH:$TOOLS_DIR:$folder_name"
}

# Write all helper scripts and docs
create_project_files() {
    # Parse the input paths
    IFS=':' read -r PROJECT_PATH TOOLS_DIR folder_name <<< "$1"
    
    # Ensure we have valid paths
    if [ -z "$PROJECT_PATH" ] || [ -z "$TOOLS_DIR" ]; then
        echo "Error: Invalid project paths" >&2
        exit 1
    fi
    
    echo "Creating project files in: $PROJECT_PATH"
    echo "Tools directory: $TOOLS_DIR"
    
    # Create .gitignore file
    cat > "$PROJECT_PATH/.gitignore" << EOL
# Git Version Control Configuration
# -------------------------------
# OPTION 1: Track Adobe files (default)
# This will track all changes but may make your repository large

# OPTION 2: Ignore Adobe files (uncomment to activate)
# This will avoid tracking large binary files
# *.psd
# *.ai
# *.aep

# Always ignore Adobe temp files
**/Adobe\ Premiere\ Pro\ Auto-Save/*
**/Adobe\ After\ Effects\ Auto-Save/*
*.tmp
.DS_Store

# Ignore the previous-versions folder which stores extracted versions
project-tools/previous-versions/
EOL
    echo "Created .gitignore file at: $PROJECT_PATH/.gitignore"

    # Create auto-commit script for file changes
    AUTO_COMMIT_PATH="$TOOLS_DIR/auto-commit.sh"
    cat > "$AUTO_COMMIT_PATH" << EOL
#!/bin/bash

# Auto-commit script that watches for file changes and automatically commits them
# This script runs in the background and commits changes when files are saved

# Set project directory explicitly
PROJECT_DIR="$PROJECT_PATH"

# Check if fswatch is installed
if ! command -v fswatch &> /dev/null; then
    echo "fswatch is required for file monitoring but not installed."
    echo "Install it with: brew install fswatch"
    echo "Then run this script again: ./project-tools/auto-commit.sh"
    exit 1
fi

echo "Starting file monitoring for automatic Git commits..."
echo "Watching directory: \$PROJECT_DIR"
echo "Press Ctrl+C to stop monitoring"

# Initialize Git if not already initialized
if [ ! -d "\$PROJECT_DIR/.git" ]; then
    echo "Initializing Git repository..."
    ( cd "\$PROJECT_DIR" && git init > /dev/null )
fi

# Watch for file changes in the project directory
fswatch -0 -e ".*/.git/*" -e ".*/project-tools/previous-versions/*" -e ".*/*.txt" "\$PROJECT_DIR" | while read -d "" event
do
    # Get the changed file
    changed_file="\$event"
    
    # Check if the file exists
    if [[ -f "\$changed_file" ]]; then
        # Get the file extension
        ext="\${changed_file##*.}"
        
        # Only commit Adobe files
        if [[ "\$ext" == "psd" || "\$ext" == "ai" || "\$ext" == "aep" ]]; then
            # Get current timestamp
            timestamp=\$(date +"%H-%M")
            
            # Add the changed file and commit with timestamp
            ( cd "\$PROJECT_DIR" && git add "\$changed_file" && git commit -m "Auto-commit at \$timestamp for \${changed_file##*/}" )
            echo "[Auto-commit] Committed changes to \${changed_file##*/} at \$timestamp"
        fi
    fi
done
EOL
    chmod +x "$AUTO_COMMIT_PATH"
    echo "Created auto-commit script at: $AUTO_COMMIT_PATH"

    # Create a helper script to extract previous versions
    EXTRACT_VERSION_PATH="$TOOLS_DIR/extract-version.sh"
    cat > "$EXTRACT_VERSION_PATH" << EOL
#!/bin/bash

# Helper script to extract a previous version of a file
# Usage: ./project-tools/extract-version.sh <filename> [<commit-hash>]

# Set project directory explicitly
PROJECT_DIR="$PROJECT_PATH"
VERSIONS_DIR="$TOOLS_DIR/previous-versions"

if [ \$# -lt 1 ]; then
    echo "Usage: ./project-tools/extract-version.sh <filename> [<commit-hash>]"
    echo "Example: ./project-tools/extract-version.sh Logo-04-23.psd abc1234"
    exit 1
fi

FILENAME=\$1
COMMIT=\$2

# Check if Git is initialized
if [ ! -d "\$PROJECT_DIR/.git" ]; then
    echo "Error: Git repository not initialized."
    echo "Please run 'git init' in the project directory first."
    exit 1
fi

# If no commit specified, show available versions
if [ -z "\$COMMIT" ]; then
    echo "Available versions of \$FILENAME:"
    ( cd "\$PROJECT_DIR" && git log --pretty=format:"%h - %cd: %s" --date=short -- "\$FILENAME" 2>/dev/null )
    echo ""
    echo "To extract a version, run: ./project-tools/extract-version.sh \$FILENAME <commit-hash>"
    exit 0
fi

# Create previous-versions directory if it doesn't exist
mkdir -p "\$VERSIONS_DIR"

# Extract the version and save with commit hash in the name
EXTENSION="\${FILENAME##*.}"
BASENAME="\${FILENAME%.*}"
OUTPUT_FILE="\$VERSIONS_DIR/\${BASENAME}-\${COMMIT}.\${EXTENSION}"

# Check if file exists in that commit
( cd "\$PROJECT_DIR" && git cat-file -e "\$COMMIT:\$FILENAME" 2>/dev/null )
if [ \$? -eq 0 ]; then
    # Extract the file
    ( cd "\$PROJECT_DIR" && git show "\$COMMIT:\$FILENAME" > "\$OUTPUT_FILE" )
    echo "Extracted version from commit \$COMMIT to \$OUTPUT_FILE"
    echo "You can now open this file directly in its respective Adobe application"
    
    # Detect file type and offer to open
    case "\$EXTENSION" in
        psd)
            echo "Opening in Photoshop..."
            open -a "/Applications/Adobe Photoshop 2022/Adobe Photoshop 2022.app" "\$OUTPUT_FILE"
            ;;
        ai)
            echo "Opening in Illustrator..."
            open -a "/Applications/Adobe Illustrator 2023/Adobe Illustrator.app" "\$OUTPUT_FILE"
            ;;
        aep)
            echo "Opening in After Effects..."
            open -a "/Applications/Adobe After Effects 2022/Adobe After Effects.app" "\$OUTPUT_FILE"
            ;;
    esac
else
    echo "Error: File \$FILENAME does not exist in commit \$COMMIT"
    exit 1
fi
EOL
    chmod +x "$EXTRACT_VERSION_PATH"
    echo "Created extract-version script at: $EXTRACT_VERSION_PATH"

    # Create a Git usage guide
    GIT_GUIDE_PATH="$PROJECT_PATH/GIT-GUIDE.md"
    cat > "$GIT_GUIDE_PATH" << EOL
# Git Version Control Guide

This guide explains how to work with Git version control in this project.

## Basic Git Commands

### Save Your Changes

1. **Check what files have changed:**
   \`\`\`
   git status
   \`\`\`

2. **Add your changes to staging:**
   \`\`\`
   git add .
   \`\`\`

3. **Commit your changes with a message:**
   \`\`\`
   git commit -m "Description of what you changed"
   \`\`\`

### View History

1. **View commit history:**
   \`\`\`
   git log
   \`\`\`

2. **View commit history in a compact format:**
   \`\`\`
   git log --oneline
   \`\`\`

### Switch Between Versions

1. **Temporarily switch to a previous version:**
   \`\`\`
   git checkout <commit-hash>
   \`\`\`
   (Get the commit hash from git log)

2. **Return to the latest version:**
   \`\`\`
   git checkout master
   \`\`\`

3. **Permanently revert to a previous version:**
   \`\`\`
   git revert <commit-hash>
   \`\`\`

## Automatic Version Control

This project includes a script that automatically commits your changes whenever you save a file:

1. **Start automatic commit monitoring:**
   \`\`\`
   ./project-tools/auto-commit.sh
   \`\`\`
   This will watch for file changes and commit them automatically with a timestamp.

2. **Stop monitoring:**
   Press Ctrl+C in the terminal window where auto-commit.sh is running.

## Accessing Previous Versions in File Explorer

This project includes a special script that extracts previous versions of files so you can open them directly in Adobe applications:

1. **View available versions of a file:**
   \`\`\`
   ./project-tools/extract-version.sh Logo-04-23.psd
   \`\`\`

2. **Extract a specific version to open in Photoshop:**
   \`\`\`
   ./project-tools/extract-version.sh Logo-04-23.psd abc1234
   \`\`\`
   (Replace abc1234 with the actual commit hash from step 1)

3. **Find extracted files:**
   All extracted previous versions are saved in the "project-tools/previous-versions" folder
   with the commit hash added to the filename for identification.

## Working with Adobe Files

1. **Opening Files:**
   - Open the Adobe program first
   - Use File > Open to navigate to your project folder
   - Select the file and open it

2. **Saving Files:**
   - Always save to the same location with the same name
   - Use Save As only if you want to create a new version
   - When you save, the auto-commit script will automatically create a version in Git

3. **Version Control:**
   - Changes are automatically committed when you save files
   - This allows you to track the history of your work
   - You can always extract previous versions using the extract-version.sh script

## Important Notes

- Binary files (like PSD, AI, AEP) won't show meaningful diffs in Git
- Git will store a complete copy of the file each time you commit changes
- For large files, consider using Git LFS or modifying .gitignore
EOL
    echo "Created Git guide at: $GIT_GUIDE_PATH"

    # Create a README file in the project root
    README_PATH="$PROJECT_PATH/README.md"
    cat > "$README_PATH" << EOL
# ${folder_name} Project

This project was created with the Project Creator script.

## Project Structure

- **Adobe Files**: Store your PSD, AI, and AEP files in the main directory
- **save-here**: A folder for storing any additional project assets
- **project-tools**: Contains helper scripts and guides for this project

## Getting Started

1. Open your Adobe application (Photoshop, Illustrator, or After Effects)
2. Create or edit files in this directory
3. Use the tools in the project-tools folder to manage versions

## Helper Scripts

All helper scripts and guides are located in the project-tools folder:

- **auto-commit.sh**: Automatically commits changes when you save files
- **extract-version.sh**: Extracts previous versions of files
- **GIT-GUIDE.md**: Detailed instructions for version control

Run scripts from the project root with:
\`\`\`
./project-tools/auto-commit.sh
./project-tools/extract-version.sh filename.psd
\`\`\`
EOL
    echo "Created README file at: $README_PATH"
    
    echo "Project files creation complete"
}

# Create design file and launch application - NO GIT OPERATIONS
create_file() {
    # Parse the input paths
    IFS=':' read -r PROJECT_PATH TOOLS_DIR folder_name <<< "$1"
    
    photoshop="photoshop"
    illustrator="illustrator"
    aftereffects="after-effects"
    
    echo "Creating design file in: $PROJECT_PATH"
    
    while true; do
        read -p 'Enter the name of the new file: ' filename
        read -p 'What program will you be working in?: ' program
        
        # Convert input to lowercase
        program=$(echo "$program" | tr '[:upper:]' '[:lower:]')
        
        # Capitalize first letter of filename
        first_char=$(echo "${filename:0:1}" | tr '[:lower:]' '[:upper:]')
        rest_of_name="${filename:1}"
        capitalized_filename="${first_char}${rest_of_name}"
        
        # Get current date in mm-dd format
        current_date=$(date +"%m-%d")
        # Add date to filename
        dated_filename="${capitalized_filename}-${current_date}"
        
        if [[ "$program" == "$photoshop" ]]; then
            programfile="${dated_filename}.psd"
            # Create placeholder file
            touch "$PROJECT_PATH/$programfile"
            echo "Created placeholder file: $programfile"
            echo "File path: $PROJECT_PATH/$programfile"
            
            # Create a shortcut text file with instructions
            INSTRUCTIONS_FILE="$TOOLS_DIR/${dated_filename}-instructions.txt"
            {
                echo "TO USE THIS FILE:"
                echo "1. Open Photoshop"
                echo "2. Go to File > Open"
                echo "3. Navigate to: $PROJECT_PATH"
                echo "4. Select $programfile and click Open"
                echo "5. Begin working and save regularly"
                echo "6. To enable version control, run: cd \"$PROJECT_PATH\" && git init"
                echo "7. See project-tools/GIT-GUIDE.md for version control instructions"
                echo "8. To access previous versions: ./project-tools/extract-version.sh $programfile"
                echo "9. To enable automatic commits when saving: ./project-tools/auto-commit.sh"
            } > "$INSTRUCTIONS_FILE"
            
            # Launch Photoshop separately
            echo "Launching Photoshop..."
            open -a "/Applications/Adobe Photoshop 2022/Adobe Photoshop 2022.app"
            break
            
        elif [[ "$program" == "$illustrator" ]]; then
            programfile="${dated_filename}.ai"
            # Create placeholder file
            touch "$PROJECT_PATH/$programfile"
            echo "Created placeholder file: $programfile"
            echo "File path: $PROJECT_PATH/$programfile"
            
            # Create a shortcut text file with instructions
            INSTRUCTIONS_FILE="$TOOLS_DIR/${dated_filename}-instructions.txt"
            {
                echo "TO USE THIS FILE:"
                echo "1. Open Illustrator"
                echo "2. Go to File > Open"
                echo "3. Navigate to: $PROJECT_PATH"
                echo "4. Select $programfile and click Open"
                echo "5. Begin working and save regularly"
                echo "6. To enable version control, run: cd \"$PROJECT_PATH\" && git init"
                echo "7. See project-tools/GIT-GUIDE.md for version control instructions"
                echo "8. To access previous versions: ./project-tools/extract-version.sh $programfile"
                echo "9. To enable automatic commits when saving: ./project-tools/auto-commit.sh"
            } > "$INSTRUCTIONS_FILE"
            
            # Launch Illustrator separately
            echo "Launching Illustrator..."
            open -a "/Applications/Adobe Illustrator 2023/Adobe Illustrator.app"
            break
            
        elif [[ "$program" == "$aftereffects" ]]; then
            programfile="${dated_filename}.aep"
            # Create placeholder file
            touch "$PROJECT_PATH/$programfile"
            echo "Created placeholder file: $programfile"
            echo "File path: $PROJECT_PATH/$programfile"
            
            # Create a shortcut text file with instructions
            INSTRUCTIONS_FILE="$TOOLS_DIR/${dated_filename}-instructions.txt"
            {
                echo "TO USE THIS FILE:"
                echo "1. Open After Effects"
                echo "2. Go to File > Open"
                echo "3. Navigate to: $PROJECT_PATH"
                echo "4. Select $programfile and click Open"
                echo "5. Begin working and save regularly"
                echo "6. To enable version control, run: cd \"$PROJECT_PATH\" && git init"
                echo "7. See project-tools/GIT-GUIDE.md for version control instructions"
                echo "8. To access previous versions: ./project-tools/extract-version.sh $programfile"
                echo "9. To enable automatic commits when saving: ./project-tools/auto-commit.sh"
            } > "$INSTRUCTIONS_FILE"
            
            # Launch After Effects separately
            echo "Launching After Effects..."
            open -a "/Applications/Adobe After Effects 2022/Adobe After Effects.app"
            break
            
        else
            echo "Unknown program. Please enter Photoshop, Illustrator, or After-Effects."
        fi
    done
    
    # Ask if user wants to initialize Git and start monitoring
    echo "Your project has been set up successfully!"
    echo ""
    echo "NEXT STEPS:"
    echo "1. Initialize version control in a new terminal window with:"
    echo "   cd \"$PROJECT_PATH\" && git init"
    echo ""
    echo "2. After initializing Git, you can start automatic commit monitoring with:"
    echo "   \"$TOOLS_DIR/auto-commit.sh\""
    echo ""
    echo "3. Documentation for all features is in project-tools/GIT-GUIDE.md"
}

# Main execution
display_usage

# Check if project name was provided as a command line argument
if [ $# -gt 0 ]; then
    folder_name="$1"
    PATHS=$(create_project_structure "$folder_name")
else
    # No argument provided, create_project_structure will prompt for name
    PATHS=$(create_project_structure "")
fi

# Make sure PATHS is not empty
if [ -z "$PATHS" ]; then
    echo "Error: Failed to create project structure"
    exit 1
fi

# Execute other functions with the paths returned from create_project_structure
create_project_files "$PATHS"
create_file "$PATHS"

# After all operations are complete, offer to initialize Git
echo ""
echo "Project setup is complete. Do you want to initialize Git now? (y/n): "
read init_git
if [[ "$init_git" == "y" || "$init_git" == "Y" ]]; then
    # Parse paths again to get PROJECT_PATH
    IFS=':' read -r PROJECT_PATH TOOLS_DIR folder_name <<< "$PATHS"
    echo "Initializing Git in $PROJECT_PATH..."
    (cd "$PROJECT_PATH" && git init)
    echo "Git repository initialized. You can now use version control."
else
    echo "You can initialize Git later by running: cd \"$PROJECT_PATH\" && git init"
fi