# DeathDPI

DeathDPI is an advanced DPI (Deep Packet Inspection) bypass application for Windows 10 and 11. it is written from scratch in the D programming language and offers more features.

Note: This project is still under development. Releases and more features adding soon.

## Features

### Basic DPI Bypass Methods
- HTTP/HTTPS packet fragmentation
- TCP packet manipulation
- TTL value optimization
- DNS redirection
- Host-based filtering (blacklist/whitelist)

### Advanced Features
- IPv6 support
- HTTPS traffic manipulation
- Packet fragmentation and reassembly
- TCP/UDP/ICMP protocol support
- Automatic TTL optimization
- Statistics collection and reporting
- Detailed logging system
- Automatic update support
- GUI support (coming soon)

### Security Features
- Whitelist/Blacklist support
- Host-based filtering
- Protocol-based filtering
- Packet size control
- Secure DNS redirection

### Performance Features
- Low system resource usage
- Multithreading support
- Optimized packet processing
- Fast startup time

## Installation

For detailed installation instructions, refer to [SETUP.md](SETUP.md).

Quick installation:
```bash
# Install the D compiler
# Download the WinDivert library
dub build --build=release
```

## Usage

1. Run the application as an administrator:
```bash
bin\deathdpi.exe [config.json]
```

2. Create a configuration file:
```bash
bin\deathdpi.exe --create-config
```

3. View statistics:
```bash
bin\deathdpi.exe --stats
```

## Configuration

You can customize all features using the `config.json` file. Example configuration:

```json
{
    "fragment_http": true,
    "fragment_https": true,
    "modify_ttl": true,
    "min_ttl": 3,
    "auto_ttl": true,
    "auto_ttl_min": 3,
    "auto_ttl_max": 10,
    "blacklist": true,
    "blacklist_hosts": ["*.facebook.com"],
    "whitelist_hosts": ["*.github.com"],
    "logging": true,
    "log_file": "deathdpi.log",
    "statistics": true
}
```

## Contributing

1. Fork this repository
2. Create a new branch (`git checkout -b feature/amazing-feature`)
3. Commit your changes (`git commit -m 'New feature: XYZ'`)
4. Push your branch (`git push origin feature/amazing-feature`)
5. Create a Pull Request

## License

This project is licensed under the MIT License. See the [LICENSE](LICENSE) file for details.

## Security

This application requires administrator privileges as it manipulates network traffic. Ensure you download it from trusted sources.

## Contact

- Project: [https://github.com/Mikashades/DeathDPI-Windows](https://github.com/Mikashades/DeathDPI-Windows)
- Issues: [https://github.com/Mikashades/DeathDPI-Windows/issues](https://github.com/Mikashades/DeathDPI-Windows/issues)

## Acknowledgments

- Thanks to the [WinDivert](https://www.reqrypt.org/windivert.html) team
