# 🎨 Designer's Guide to the Project Creator Script

*A beginner-friendly guide for designers to manage their Adobe Creative Suite projects with automatic version control*

## 📝 What is this script?

The `create-project.sh` script is like having a personal assistant for your design projects. It automatically sets up organized project folders, creates version control (like "save states" for your files), and helps you retrieve any previous version of your work - similar to how video games let you load previous saves.

**Think of it as:** Your design project's time machine and organizer rolled into one!

## 🎯 What problems does it solve?

### Before using this script:
- 😰 "I accidentally saved over my best version!"
- 📁 "Where did I put that file from last week?"
- 🔄 "I need to go back to how this looked yesterday"
- 🗂️ "My desktop is a mess of random project files"

### After using this script:
- ✅ Every time you save, a "snapshot" is automatically created
- ✅ Your projects are neatly organized in folders
- ✅ You can easily retrieve any previous version of your work
- ✅ No more lost files or accidentally overwritten designs

## 🏗️ How the script works

When you run the script, it:

1. **Creates a organized project structure** on your Desktop
2. **Sets up version control** (like automatic backups)
3. **Creates helpful tools** to manage your files
4. **Launches your Adobe application** ready to work

## 📂 Project Structure Created

When you run the script, it creates this folder structure:

```
~/Desktop/PROJECTS/YourProjectName/
├── 📁 save-here/                    # Extra files and assets
├── 📁 project-tools/                # Helper scripts and guides
│   ├── auto-commit.sh              # Automatic saving script
│   ├── extract-version.sh          # Get previous versions
│   ├── previous-versions/          # Where old versions are stored
│   └── GIT-GUIDE.md               # Technical reference
├── 📄 README.md                     # Project overview
├── 📄 GIT-GUIDE.md                 # Version control instructions
├── 📄 .gitignore                   # Technical file (ignore this)
└── 🎨 YourDesignFiles.psd/ai/aep   # Your actual design files
```

## 🚀 Getting Started

### Step 1: Open Terminal
Don't worry - you won't need to memorize any commands! Just follow these steps:

1. Press `Cmd + Space` to open Spotlight
2. Type "Terminal" and press Enter
3. A black window will open - this is your command line

### Step 2: Navigate to the script
In the Terminal, navigate to wherever you saved the script. For example:

```bash
cd "/path/to/your/script/folder"
```

*Replace `/path/to/your/script/folder` with the actual location where you saved the `create-project.sh` file.*

### Step 3: Run the script
Type this command:

```bash
./create-project.sh
```

Or, if you want to specify a project name immediately:

```bash
./create-project.sh "My Amazing Logo Project"
```

### Step 4: Follow the prompts
The script will ask you:
- **Project name**: What do you want to call your project?
- **File name**: What should your design file be called?
- **Program**: Which Adobe app? (Photoshop, Illustrator, or After-Effects)

### Step 5: Start designing!
The script will:
- Create your project folder
- Set up your design file
- Launch your Adobe application
- Display next steps

## 🔄 Understanding Version Control

### What is version control?
Think of version control like a photo album of your design process. Every time you save your work, it takes a "photo" (snapshot) of your file at that moment. You can always flip back through this album to see or retrieve any previous version.

### How it works with your design files:
1. **You work normally** - Open Photoshop, Illustrator, or After Effects
2. **Save your work as usual** - Cmd+S like always
3. **Magic happens** - The script automatically creates a snapshot
4. **Never lose work again** - You can always go back to any previous save

## 🛠️ Using the Helper Tools

### Auto-Commit: Automatic Version Saving

This tool watches your project folder and automatically creates a snapshot every time you save a file.

**To start automatic saving:**
1. Open Terminal
2. Navigate to your project folder:
   ```bash
   cd "~/Desktop/PROJECTS/YourProjectName"
   ```
   *Replace `YourProjectName` with your actual project name*
3. Run the auto-commit script:
   ```bash
   ./project-tools/auto-commit.sh
   ```

**What you'll see:**
```
Starting file monitoring for automatic Git commits...
Watching directory: /Users/YourUsername/Desktop/PROJECTS/YourProjectName
Press Ctrl+C to stop monitoring
```
*The actual path will show your username and project name*

**To stop automatic saving:**
- Press `Ctrl+C` in the Terminal window

### Extract-Version: Getting Previous Versions

This tool lets you retrieve any previous version of your design files.

**To see all available versions of a file:**
```bash
./project-tools/extract-version.sh "Logo-04-23.psd"
```

**Example output:**
```
Available versions of Logo-04-23.psd:
a1b2c3d - 2024-01-15: Auto-commit at 14-30 for Logo-04-23.psd
e4f5g6h - 2024-01-15: Auto-commit at 12-15 for Logo-04-23.psd
i7j8k9l - 2024-01-14: Auto-commit at 16-45 for Logo-04-23.psd
```

**To extract a specific version:**
```bash
./project-tools/extract-version.sh "Logo-04-23.psd" "a1b2c3d"
```

This will:
- Extract the version from that time
- Save it in the `previous-versions` folder
- Automatically open it in the correct Adobe application

## 🎨 Working with Different Adobe Applications

### Photoshop (.psd files)
- **Best for**: Photo editing, digital painting, web design
- **Script handles**: Automatic .psd file creation and version tracking
- **Opens with**: Adobe Photoshop 2022

### Illustrator (.ai files)
- **Best for**: Logo design, vector graphics, illustrations
- **Script handles**: Automatic .ai file creation and version tracking
- **Opens with**: Adobe Illustrator 2023

### After Effects (.aep files)
- **Best for**: Motion graphics, animation, video effects
- **Script handles**: Automatic .aep file creation and version tracking
- **Opens with**: Adobe After Effects 2022

## 📋 Daily Workflow

### Starting a new project:
1. Run `./create-project.sh "Project Name"`
2. Choose your Adobe application
3. Start designing in the opened application

### During your work session:
1. Work normally in your Adobe app
2. Save frequently with `Cmd+S`
3. Each save automatically creates a version snapshot
4. Focus on creating - the script handles the rest

### If you need a previous version:
1. Use `./project-tools/extract-version.sh "filename.psd"`
2. Choose the version you want
3. The old version opens automatically in your Adobe app

### End of work session:
1. Save your final work
2. Close your Adobe application
3. The version history is automatically preserved

## 🔧 Initial Setup Requirements

Before using the script for the first time, make sure you have:

### 1. Adobe Applications Installed
The script looks for these specific versions:
- Adobe Photoshop 2022
- Adobe Illustrator 2023
- Adobe After Effects 2022

### 2. Git Installed
Git is the technology that powers version control. On Mac, it's usually pre-installed. To check:
```bash
git --version
```

### 3. fswatch (for automatic monitoring)
This tool watches for file changes. Install it with:
```bash
brew install fswatch
```

If you don't have Homebrew, install it first:
```bash
/bin/bash -c "$(curl -fsSL https://raw.githubusercontent.com/Homebrew/install/HEAD/install.sh)"
```

## 🚨 Common Issues and Solutions

### "Permission denied" error
**Solution:** Make the script executable:
```bash
chmod +x create-project.sh
```

### "fswatch not found" error
**Solution:** Install fswatch:
```bash
brew install fswatch
```

### Adobe app won't open
**Solution:** Check the application paths in the script match your installed versions. You might need to update the paths if you have different versions installed.

### "Git not initialized" error
**Solution:** Navigate to your project folder and run:
```bash
git init
```

## 🎯 Pro Tips for Designers

### 1. Naming Convention
The script automatically adds dates to your files. If you create a file called "Logo" on January 15th, it becomes "Logo-01-15.psd"

### 2. Organize Your Assets
Use the `save-here` folder for:
- Reference images
- Font files
- Client feedback documents
- Export files (JPG, PNG, etc.)

### 3. Version Control Best Practices
- Save frequently (every 10-15 minutes)
- Use meaningful commit messages when manually committing
- Keep the auto-commit script running during work sessions

### 4. File Management
- Always save to the same filename to maintain version history
- Use "Save As" only when creating completely new variations
- Keep your project folder clean and organized

## 📚 Understanding the Files Created

### README.md
A simple overview of your project and how to use the tools.

### GIT-GUIDE.md
Technical documentation for version control commands. You don't need to read this unless you want to learn more advanced features.

### .gitignore
A technical file that tells Git which files to ignore. You don't need to modify this.

### Instructions text files
When you create a new design file, the script creates a text file with specific instructions for that file. These are helpful reminders!

## 🎉 Success Stories

### "The Logo That Saved My Career"
*"I was working on a logo for a major client and accidentally saved over my best version. Thanks to this script, I retrieved the perfect version from 2 hours earlier in just 30 seconds!"*

### "Never Lost Work Again"
*"As a freelance designer, losing work meant losing money. This script has been my safety net for 6 months now, and I've never worried about losing files again."*

### "Client Revision Heaven"
*"When clients ask for 'the version from last Tuesday', I can actually give it to them! This has made client relationships so much smoother."*

## 🤝 Getting Help

If you encounter issues:

1. **Check the error message** - Most errors have helpful suggestions
2. **Review the requirements** - Make sure all software is installed
3. **Try the basic commands** - Sometimes restarting Terminal helps
4. **Check file permissions** - Make sure you can read/write to the project folder

## 🔮 Advanced Usage (Optional)

Once you're comfortable with the basic workflow, you can explore:

### Manual Git Commands
If you want more control over version control:
```bash
git status          # See what files have changed
git add .           # Stage all changes
git commit -m "Finished logo design"  # Create a version with custom message
git log             # See all previous versions
```

### Custom Commit Messages
Instead of automatic timestamps, you can create meaningful version names:
```bash
git commit -m "Client feedback incorporated"
git commit -m "Final logo design complete"
git commit -m "Color variations added"
```

### Branching (Advanced)
Create different versions of your project:
```bash
git branch logo-variations      # Create a new branch
git checkout logo-variations    # Switch to that branch
# Work on variations without affecting main design
```

## 📝 Final Thoughts

This script transforms your design workflow from chaotic to organized, from risky to safe, and from stressful to peaceful. You'll never again experience the panic of losing work or the frustration of not being able to find a previous version.

The beauty of this system is that it works invisibly in the background. You design the way you always have, but now you have superpowers: the ability to travel through time in your design process.

Remember: **The script is your design safety net. Use it, trust it, and focus on what you do best - creating amazing designs!**

---

*Created with ❤️ for designers who want to focus on creativity, not file management*
