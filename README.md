# Shell Dojo

An interactive learning environment for mastering Linux shell commands and terminal skills.

The Shell Dojo provides a comprehensive, hands-on approach to learning essential command-line tools through practical challenges. Students progress through modules covering everything from basic navigation to advanced command chaining.

## 🏗️ Structure

The dojo is defined by [dojo.yml](./dojo.yml) and consists of six progressive modules:

### 📚 Modules and Challenges

#### 1. **Welcome to Shell** (`intro`)
- **intro** - Introduction to the learning system and shell basics

#### 2. **Snooping Around** (`navigation`) 
- **navigation-basics** - Learn `ls`, `cd`, `pwd` for file system navigation
- **hidden-treasure** - Master hidden files and advanced `ls` options

#### 3. **Understanding Commands** (`commands`)
- **command-discovery** - Learn what commands are and where they're located (`whereis`, `which`, `type`)
- **getting-help** - Master documentation tools (`man`, `--help`, `tldr`)
- **shell-environment** - Customize your shell (aliases, environment variables, different shells)

#### 4. **Pipes and I/O Redirection** (`pipes`)
- **io-basics** - Understand standard streams and redirection (`>`, `>>`, `<`)
- **pipe-mastery** - Chain commands with pipes and master data flow

#### 5. **Users and Permissions** (`permissions`)
- **permission-basics** - File permissions and access control (`chmod`, `ls -l`)
- **sudo-power** - Administrative privileges and security

#### 6. **Package Management** (`packages`)
- **package-basics** - Installing software with `apt`
- **mirror-magic** - Understanding software repositories and mirrors

### Content Modules
Educational content is organized in `core/contents/` following the MxPy naming scheme:
- **M0P0** - Introduction and key bindings
- **M1P0** - File System Navigation (Read-Only)
- **M1P1** - File Manipulation (Write Operations)
- **M2P0** - Understanding Commands
- **M2P1** - Shell Environment
- **M3P0** - Pipes and I/O Redirection
- **M4P0** - Users and Permissions
- **M5P0** - Package Management

## 📖 Curriculum Overview

Refer to [WHAT_TO_TEACH.md](https://github.com/acm-dojo/shell-dojo-core/blob/main/WHAT_TO_TEACH.md) for more details.