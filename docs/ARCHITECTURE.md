# Architecture

VINI-JB follows a clean, modular architecture with clear separation of concerns.

## Directory Structure

```
VINI-JB/
├── App/                    # Application entry point
│   └── VINIJBApp.swift
├── FileSystem/             # Filesystem operations
│   ├── FileSystemManager.swift
│   ├── PathResolver.swift
│   ├── JailbreakAccess.swift
│   ├── ContainerManager.swift
│   └── DirectoryBrowser.swift
├── Patches/                # Patch management
│   ├── PatchManager.swift
│   ├── PatchInstaller.swift
│   ├── PatchBackupManager.swift
│   └── PatchRestoreManager.swift
├── Remote/                 # API and network
│   ├── APIClient.swift
│   └── RemotePatchService.swift
├── Models/                 # Data models
│   ├── Models.swift
│   └── PatchModels.swift
├── UI/                     # User interface
│   ├── ContentView.swift
│   ├── Home/
│   ├── Apps/
│   ├── FileBrowser/
│   ├── Patches/
│   ├── Backups/
│   ├── Settings/
│   └── Diagnostics/
├── Authentication/         # Auth management
│   └── KeychainManager.swift
└── helpers/                # Utilities
    └── LoginManager.swift
```

## Core Components

### FileSystem Layer

**FileSystemManager**: Protocol-based abstraction for all file operations. Ensures all file access goes through a single layer.

**PathResolver**: Converts abstract destinations (DOCUMENTS, LIBRARY, etc.) to actual URLs. Handles jailbreak path resolution.

**JailbreakAccess**: Detects jailbreak availability and determines access level. Provides diagnostic information.

**ContainerManager**: Manages app container discovery and access.

**DirectoryBrowser**: Provides directory browsing capabilities with search support.

### Patches Layer

**PatchManager**: Orchestrates the patch lifecycle - sync, download, version management.

**PatchInstaller**: Handles patch installation with validation and verification.

**PatchBackupManager**: Creates and manages backups before patch installation.

**PatchRestoreManager**: Restores patches from backups.

### Remote Layer

**APIClient**: Low-level HTTP client with authentication and token refresh.

**RemotePatchService**: High-level API for fetching patches from VINI backend.

## Design Principles

1. **Separation of Concerns**: Each layer has a single responsibility
2. **Protocol-Oriented**: Use protocols for testability and flexibility
3. **No Direct File Access**: All file operations go through FileSystemManager
4. **No Hardcoded Paths**: Use PathResolver for all path resolution
5. **Security First**: Never store secrets in code, use Keychain
