# DeathDPI Installation Guide

This guide provides detailed instructions for installing DeathDPI on Windows 10 and 11 systems.

## System Requirements

### Minimum Requirements
- Windows 10 (1903 or later) / Windows 11
- 2GB RAM
- 100MB free disk space
- Administrator privileges

### Recommended Requirements
- Windows 10 (21H2 or later) / Windows 11
- 4GB RAM
- 500MB free disk space
- SSD
- Administrator privileges

## Development Environment Setup

### 1. D Compiler Installation

1. Visit the [D Language website](https://dlang.org/download.html)
2. Download the DMD compiler (recommended)
3. Run the installation wizard
4. After installation, verify the D compiler installation in the command line:
```bash
dmd --version
```

### 2. DUB Package Manager

DUB comes bundled with the D compiler. Verify its installation:
```bash
dub --version
```

### 3. WinDivert Library

1. Download the latest version from the [WinDivert website](https://www.reqrypt.org/windivert.html)
2. Extract the archive
3. Copy the following files to the `WinDivert` folder in the project:
   - `WinDivert.dll` -> `WinDivert/x64/`
   - `WinDivert.lib` -> `WinDivert/x64/`
   - `WinDivert.h` -> `WinDivert/include/`

### 4. Visual Studio Build Tools (Optional)

1. Download [Visual Studio Build Tools](https://visualstudio.microsoft.com/visual-cpp-build-tools/)
2. Select the "C++ Desktop Development" workload during installation
3. Complete the installation

## DeathDPI Installation

### Building from Source Code

1. Clone the repository:
```bash
git clone https://github.com/yourusername/deathdpi.git
cd deathdpi
```

2. Install dependencies:
```bash
dub upgrade
```

3. Build the project:
```bash
# Debug build
dub build

# Release build (recommended)
dub build --build=release
```

4. Run the compiled file:
```bash
bin\deathdpi.exe
```

### Binary Installation

1. Download the latest release from the [Releases](https://github.com/yourusername/deathdpi/releases) page
2. Extract the archive
3. Run the `deathdpi.exe` file as an administrator

## Configuration

### Basic Configuration

1. Create a default configuration file:
```bash
bin\deathdpi.exe --create-config
```

2. Edit the `config.json` file:
```json
{
    "fragment_http": true,
    "fragment_https": true,
    "modify_ttl": true,
    "min_ttl": 3,
    "blacklist": true,
    "blacklist_hosts": [
        "*.facebook.com",
        "*.google.com"
    ]
}
```

### Advanced Configuration

Example configuration for advanced features:
```json
{
    "ipv6_support": true,
    "https_tampering": true,
    "packet_fragmentation": true,
    "max_packet_size": 1500,
    "tcp_tampering": true,
    "udp_tampering": true,
    "icmp_tampering": false,
    "logging": true,
    "log_file": "deathdpi.log",
    "log_level": 2,
    "statistics": true,
    "stats_interval": 60,
    "auto_update": true,
    "update_url": "https://api.github.com/repos/yourusername/deathdpi/releases/latest"
}
```

## Troubleshooting

### Common Issues

1. "Failed to open WinDivert" error:
   - Ensure you run the application as an administrator
   - Temporarily disable Windows Defender
   - Check that WinDivert files are in the correct location

2. Build errors:
   - Ensure the D compiler is up to date
   - Verify that Visual Studio Build Tools are installed
   - Reinstall dependencies: `dub upgrade`

3. Performance issues:
   - Check statistics: `deathdpi.exe --stats`
   - Review the log file
   - Monitor system resources

### Log Files

Log files are located by default at `deathdpi.log`. You can adjust log levels in the configuration file:

- Level 1: Critical errors only
- Level 2: Errors and warnings
- Level 3: Detailed debug information

## Security Recommendations

1. Firewall configuration:
   - Allow incoming/outgoing connections for DeathDPI
   - Open only necessary ports

2. Antivirus configuration:
   - Add DeathDPI to the trusted applications list
   - Add an exception for WinDivert

3. System security:
   - Keep Windows up to date
   - Regularly install security patches

## Update

1. Automatic update:
```json
{
    "auto_update": true,
    "update_url": "https://api.github.com/repos/yourusername/deathdpi/releases/latest"
}
```

2. Manual update:
```bash
git pull
dub build --build=release
```

## Uninstallation

1. Stop the application
2. Delete program files
3. Delete configuration files:
   - `config.json`
   - `deathdpi.log`
4. Clean from Windows registry (optional):
```bash
reg delete "HKLM\SOFTWARE\DeathDPI" /f
```