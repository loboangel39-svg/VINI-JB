# Patch Format

VINI-JB uses the `.3105` patch format, which is compatible with the VINI backend.

## File Format

The `.3105` format is a binary container with the following structure:

### Header
- Magic: `3105PATCH\0` (8 bytes)
- Version: Schema version (1 byte)
- Flags: Encryption flags (1 byte)

### Content
- Encrypted payload (AES-GCM)
- Key derivation: PBKDF2
- Metadata: Patch info, file list, destinations

## Schema Versions

### v1 (Legacy)
- Single file patches
- Basic encryption
- Fixed destinations

### v2 (Current)
- Multi-file patches
- Enhanced encryption
- Flexible destinations
- Workspace support

### v3 (Future)
- Compression support
- Delta patches
- Version tracking

## Patch Structure

```json
{
  "name": "Example Patch",
  "version": "1.0.0",
  "files": [
    {
      "name": "Assembly-CSharp-patch.bytes",
      "destination": "DOCUMENTS"
    },
    {
      "name": "localConfig.json",
      "destination": "DOCUMENTS"
    }
  ]
}
```

## Destinations

Patches can target these destinations:

- `APP_CONTAINER` - App bundle directory
- `DATA_CONTAINER` - App data directory
- `DOCUMENTS` - Documents folder
- `LIBRARY` - Library folder
- `APPLICATION_SUPPORT` - Library/Application Support
- `TMP` - Temporary directory
- `relative(path)` - Custom relative path

## Encryption

Patches are encrypted using:
- **Algorithm**: AES-256-GCM
- **Key Derivation**: PBKDF2 with SHA-256
- **Iterations**: 100,000+
- **IV**: Random per-file

## Content Key

Each patch has a unique content key stored in Keychain:
- Service: `com.apple.mobile.MobileHouseArrest.patch-keys`
- Account: Patch ID
- Accessible: After first unlock, this device only

## Validation

Before installation, VINI-JB validates:
1. Magic bytes match
2. Schema version supported
3. Encryption valid
4. Content key available
5. Destination paths valid
6. File integrity verified

## Creating Patches

Patches are created server-side and distributed through the VINI backend. The creation process:

1. Select target files
2. Choose destinations
3. Encrypt with content key
4. Generate .3105 package
5. Upload to R2 storage
6. Register in database

## Backup Format

Backups are stored as:
```
VINI/Backups/
└── {patchID}/
    ├── metadata.json
    └── files/
        └── {filename}
```

### metadata.json
```json
{
  "patchID": "uuid",
  "originalPath": "/var/mobile/...",
  "backupDate": "2024-01-01T00:00:00Z",
  "fileName": "original.bytes"
}
```

## Compatibility

VINI-JB patches are compatible with:
- VINI-IPA (non-jailbreak version)
- VINI backend API
- Standard .3105 tools

## Security

- Never store content keys in patch files
- Always use Keychain for key storage
- Validate all paths before installation
- Create backups before modification
- Verify integrity after installation
