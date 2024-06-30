# TorWatch

**TorWatch** is a comprehensive bash script designed for monitoring the availability of websites through the Tor network. This tool not only checks if a website is accessible but also manages IP address rotation using Tor, blocks IP addresses if the site is inaccessible, and keeps detailed logs of activities to help you monitor events effectively. Whether you are a security enthusiast, a researcher, or simply someone interested in maintaining online privacy, **TorWatch** provides an efficient and automated solution for your website monitoring needs.

## Features

- **Monitor Website**: Continuously checks if the specified website is accessible via the Tor network.
- **Manual IP Change**: Change the Tor exit node by pressing `c` (no need to press Enter).
- **Automatic IP Blocking**: Blocks IP addresses when the site is down and logs these events.
- **Logging**: Saves activity logs and blocked IPs to files within a directory named after the website.
- **GeoIP Lookup**: Uses `geoiplookup` to find the geographic location of the current IP address.

## Requirements

Before you start, ensure the following tools are installed on your system:

- `figlet` – For creating ASCII art text
- `toilet` – For additional text fonts
- `geoiplookup` – For IP geolocation
- `tor` – For anonymous browsing

If any of these tools are missing, the script will attempt to install them automatically.

## Installation

### Clone the Repository

To get started, clone the repository using the following command:

```bash
git clone https://github.com/hunThubSpace/TorWatch.git
cd TorWatch
```

### Make the Script Executable

Next, make the script executable:

```bash
chmod +x torwatch.sh
```

## How to Use

### Start the Script

Run the script with the domain of the website you want to monitor:

```bash
./torwatch.sh <website>
```

Replace `<website>` with the domain name of the site you wish to monitor (e.g., `example.com`, not `https://example.com`).

### Manual IP Change

To manually change the Tor exit node:

- Press **`c`** (without pressing Enter). The script will automatically restart Tor and change the IP address.

### View Logs

The script generates two files for logging:

- **Activity Log**: Located in `<website>/<website>.log`.
- **Blocked IPs**: Stored in `<website>/<website>.blocked.txt`.

Example:

```text
example.com/example.com.log
example.com/example.com.blocked.txt
```

### Check Blocked IPs

The file `<website>/<website>.blocked.txt` contains a list of blocked IP addresses along with their geographic locations.

## Troubleshooting

Here are some common issues and solutions:

- **`geoiplookup` Command Issues**: Ensure `geoip-bin` is installed correctly. You can install it using:

    ```bash
    sudo apt-get install geoip-bin
    ```

- **Tor Service Issues**: Make sure Tor is properly installed and can be started with the following commands:

    ```bash
    sudo systemctl start tor
    sudo systemctl enable tor
    ```

If you continue to encounter issues, check the logs in `<website>/<website>.log` for more details.

## Demo

Here’s a quick demo of how `TorWatch` works:


https://github.com/hunThubSpace/TorWatch/assets/49031710/6bfab2d2-8915-467a-8a9b-670835a6e3e2





### Example Command

```bash
./torwatch.sh example.com
```

### Example Output

```text
[*] ./torwatch www.google.com [*]

[*] Site https://www.google.com is accessible through Tor. Current IP: X.X.X.X (country)
```

### Manual IP Change

When pressing `c`, the output will show:

```text
[*] Manually IP changed
```

### Blocked IP Example

If `www.google.com` is down, the script will log:

```text
[*] Site https://www.google.com returned status code 500. Blocking IP: 192.168.1.1 [Somewhere]
```

### Log Files

**`example.com/example.com.log`** might contain entries like:

```text
2024-06-30 14:20:01 - [*] Site https://example.com is accessible through Tor. Current IP: 127.0.0.1 (Somewhere)
2024-06-30 14:25:01 - [*] Site https://example.com returned status code 500. Blocking IP: 192.168.1.1 [Somewhere]
```

**`example.com/example.com.blocked.txt`** might contain entries like:

```text
192.168.1.1 - Somewhere
```
## Notes

- Ensure you have the necessary permissions to manage the Tor service and install packages.
- Use responsibly and adhere to the terms of service of the websites you are monitoring.
- Modify the script as needed to fit your specific use case.

## Acknowledgements

- Thanks to [The Tor Project](https://www.torproject.org/) for their work in promoting online privacy.

