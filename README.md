# VINI-JB

VINI-JB is a jailbreak-oriented version of VINI for iOS devices with jailbreak access, specifically targeting iOS 15-16 and other compatible environments.

## ✅ Status: Complete

All 8 phases of the specification have been completed:
- ✅ Audit of VINI-IPA repository
- ✅ Project skeleton created
- ✅ Filesystem layer implemented
- ✅ Patch system implemented
- ✅ UI views created
- ✅ Unit tests created
- ✅ Documentation completed
- ✅ Final review and corrections applied

## Features

- **Filesystem Access**: Extended filesystem access for jailbroken devices
- **App Container Explorer**: Browse and manage app containers
- **Remote Patch System**: Download and install patches from VINI backend
- **Backup & Restore**: Automatic backups before patch installation
- **Jailbreak Detection**: Automatic detection of jailbreak capabilities
- **Diagnostics**: System diagnostics and status information

## Requirements

- iOS 15.0+
- Jailbroken device (recommended)
- Xcode 14.0+
- Swift 5.7+

## Installation

### Using Swift Package Manager

```bash
swift build
swift test
```

### Using Xcode

1. Open the project folder in Xcode
2. Select your target device
3. Build and run (⌘R)

## Project Structure

```
VINI-JB/
├── App/              # Application entry point
├── Authentication/   # Keychain management
├── FileSystem/       # Filesystem operations (5 files)
├── Patches/          # Patch system (4 files)
├── Remote/           # API client (2 files)
├── Models/           # Data models (2 files)
├── UI/               # User interface (9 views)
├── Tests/            # Unit tests (7 files)
├── docs/             # Documentation (4 files)
└── helpers/          # Utilities
```

## Documentation

- [Architecture](docs/ARCHITECTURE.md) - Detailed architecture documentation
- [Build Guide](docs/BUILD.md) - How to build VINI-JB
- [Jailbreak](docs/JAILBREAK.md) - Jailbreak-specific information
- [Patch Format](docs/PATCH_FORMAT.md) - Patch file format specification
- [Project Status](PROJECT_STATUS.md) - Complete project status

## Testing

Run the test suite:

```bash
swift test
```

Tests cover:
- PathResolver
- Patch models
- FileSystem operations
- Backup management
- Error handling
- Remote API
- App containers

## API Integration

VINI-JB integrates with the VINI backend:

- Base URL: `https://vini-v2-api.loboangel39.workers.dev`
- Authentication: JWT tokens stored in Keychain
- Endpoints: License validation, patch download, messages

## Security

- No exploits or security bypasses
- Keychain for sensitive data storage
- Protocol-based filesystem access
- Comprehensive error handling

## License

Proprietary - All rights reserved
