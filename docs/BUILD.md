# Build Guide

## Prerequisites

- macOS with Xcode 14.0 or later
- iOS 15.0+ device (jailbroken recommended)
- Swift 5.0+

## Building

1. Open the project in Xcode:
   ```bash
   open VINI-JB.xcodeproj
   ```

2. Select your target device or simulator

3. Build and run (⌘R)

## Configuration

### Bundle Identifier

The default bundle identifier is `com.vini.jb`. Change it in the Xcode project settings if needed.

### API Endpoint

The API endpoint is configured in `Remote/APIClient.swift`:
```swift
private let baseURL = "https://vini-v2-api.loboangel39.workers.dev"
```

## Testing

VINI-JB includes unit tests for core components. Run tests with:
- ⌘U in Xcode
- Or: `xcodebuild test -project VINI-JB.xcodeproj -scheme VINI-JB`

## Troubleshooting

### Build Errors

- **Missing dependencies**: VINI-JB uses only system frameworks
- **Code signing**: Ensure you have a valid development certificate
- **Deployment target**: Must be iOS 15.0 or later

### Runtime Issues

- **Jailbreak not detected**: Check that jailbreak paths are accessible
- **Permission denied**: Verify filesystem access level in Diagnostics
- **Network errors**: Check API endpoint and internet connection
