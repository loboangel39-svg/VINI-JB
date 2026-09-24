# Jailbreak Support

VINI-JB is designed to work with jailbroken iOS devices, providing extended filesystem access and app container management.

## Supported Jailbreaks

VINI-JB supports any jailbreak that provides:
- Write access to `/var/mobile`
- Access to app containers at `/var/mobile/Containers/Data/Application`
- Standard POSIX file permissions

### Tested Jailbreaks

- **palera1n** (iOS 15-16)
- **Dopamine** (iOS 15-16)
- **Taurine** (iOS 14)
- **unc0ver** (iOS 11-14)
- **checkra1n** (iOS 12-14)

## Access Levels

VINI-JB detects three access levels:

### Sandbox Only
- No jailbreak detected
- Limited to app sandbox
- Cannot access other app containers

### Extended
- Partial jailbreak access
- Some system directories accessible
- Limited container access

### Jailbreak
- Full jailbreak access
- Complete filesystem access
- Full container management

## How It Works

### Path Resolution

VINI-JB uses `PathResolver` to locate app containers:

1. Checks common jailbreak paths:
   - `/var/mobile/Containers/Data/Application`
   - `/private/var/mobile/Containers/Data/Application`

2. Reads container metadata:
   - `.com.apple.mobile_container_manager.metadata.plist`
   - Extracts bundle ID from `MCMMetadataIdentifier`

3. Returns container URL for further operations

### File Operations

All file operations go through `FileSystemManager`:
- Validates permissions before operations
- Handles errors gracefully
- Provides detailed error messages

## Security

VINI-JB does NOT:
- Implement exploits or bypasses
- Modify system files
- Disable security features
- Assume jailbreak capabilities

VINI-JB DOES:
- Detect actual capabilities
- Request only necessary permissions
- Provide clear error messages
- Fail safely when access is denied

## Diagnostics

Use the Diagnostics screen to check:
- iOS version
- Device model
- Jailbreak status
- Filesystem access
- Container access
- API connectivity

## Troubleshooting

### Jailbreak Not Detected

1. Verify jailbreak is active
2. Check filesystem permissions
3. Review Diagnostics screen
4. Check console logs

### Permission Denied

1. Verify jailbreak access level
2. Check target path permissions
3. Ensure app has necessary entitlements
4. Review error messages

### Container Not Found

1. Verify app is installed
2. Check container path exists
3. Verify bundle ID is correct
4. Check jailbreak access level
