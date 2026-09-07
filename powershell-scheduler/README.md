# PowerShell Scheduler for Unraid

A lightweight Docker container for running PowerShell 7 scripts on a schedule using Linux `cron`.

The container is designed specifically for use on an [Unraid](https://unraid.net/) server. PowerShell is provided by Microsoft's .NET SDK container image, while the scheduler and supporting scripts are maintained in this repository.

## Features

- PowerShell 7
- Linux `cron` scheduling
- Designed for Unraid
- Scripts stored outside the Docker container
- Configuration stored outside the Docker container
- Persistent execution logs
- No external database or web interface
- Container can be rebuilt without losing scripts or configuration
- Designed to be built locally on the Unraid server

## Architecture

```text
GitHub Repository
        │
        │ git pull
        ▼
     Unraid
        │
        │ docker build
        ▼
┌───────────────────────────────┐
│    PowerShell Scheduler       │
│                               │
│  Microsoft .NET SDK +         │
│  PowerShell + cron            │
│                               │
│  /config  ──► crontab         │
│  /scripts ──► *.ps1           │
│  /logs    ──► *.log           │
└───────────────────────────────┘
```

The Docker image contains the scheduler infrastructure. User scripts, schedules, and logs are stored on the Unraid filesystem and are not part of the image.

## Repository Structure

```text
.
├── Dockerfile
├── entrypoint.sh
├── run-powershell-script
├── README.md
└── examples/
    └── crontab
```

## Unraid Directory Structure

The recommended Unraid application-data directory is:

```text
/mnt/user/appdata/powershell-scheduler/
```

with the following structure:

```text
powershell-scheduler/
├── config/
│   └── crontab
├── scripts/
│   ├── script1.ps1
│   ├── script2.ps1
│   └── ...
├── logs/
│   ├── script1.log
│   ├── script2.log
│   └── ...
└── docker/
    └── [this repository]
```

The `docker` directory contains the source code used to build the image. The other directories contain runtime data.

## Building the Image

Clone the repository onto the Unraid server:

```bash
mkdir -p /mnt/user/appdata/powershell-scheduler/docker

cd /mnt/user/appdata/powershell-scheduler/docker

git clone <REPOSITORY-URL> .
```

Build the image:

```bash
docker build --pull -t powershell-scheduler:latest .
```

The `--pull` option ensures that Docker checks for a newer version of the base image before building.

## Updating

Pull the latest source from GitHub:

```bash
cd /mnt/user/appdata/powershell-scheduler/docker

git pull
```

Then rebuild:

```bash
docker build --pull -t powershell-scheduler:latest .
```

Recreate the container after rebuilding so it uses the new image.

User scripts, configuration, and logs are stored outside the image and will not be affected by rebuilding the container.

## Configuration

### Cron Schedule

The scheduler reads its cron configuration from:

```text
/config/crontab
```

On Unraid, this corresponds to:

```text
/mnt/user/appdata/powershell-scheduler/config/crontab
```

Example:

```cron
# Run every 5 minutes
*/5 * * * * /usr/local/bin/run-powershell-script /scripts/test.ps1 /logs/test.log

# Run every hour at 15 minutes past the hour
15 * * * * /usr/local/bin/run-powershell-script /scripts/hourly.ps1 /logs/hourly.log

# Run every day at 2:00 AM
0 2 * * * /usr/local/bin/run-powershell-script /scripts/daily.ps1 /logs/daily.log
```

Standard Linux cron syntax is used.

### Scripts

PowerShell scripts are stored in:

```text
/scripts
```

On Unraid:

```text
/mnt/user/appdata/powershell-scheduler/scripts
```

For example:

```text
scripts/
├── property-monitor.ps1
├── backup-check.ps1
└── daily-report.ps1
```

Scripts are executed using PowerShell 7 with:

```text
-NoLogo -NoProfile -NonInteractive
```

This makes scheduled execution independent of an interactive PowerShell session.

### Logs

Execution logs are stored in:

```text
/logs
```

On Unraid:

```text
/mnt/user/appdata/powershell-scheduler/logs
```

Each scheduled script can have its own log file.

## Time Zone

The container should be configured with the desired IANA time zone using the `TZ` environment variable.

For a Pacific Time Unraid server:

```text
TZ=America/Los_Angeles
```

This allows cron schedules to use local time rather than UTC.

## Docker Volumes

The container uses three persistent volume mappings:

| Unraid Path | Container Path | Purpose |
|---|---|---|
| `/mnt/user/appdata/powershell-scheduler/config` | `/config` | Cron configuration |
| `/mnt/user/appdata/powershell-scheduler/scripts` | `/scripts` | PowerShell scripts |
| `/mnt/user/appdata/powershell-scheduler/logs` | `/logs` | Execution logs |

No persistent data should be stored inside the container itself.

## Docker Configuration

Example:

```bash
docker run -d \
  --name=PowerShell-Scheduler \
  --restart unless-stopped \
  -e TZ=America/Los_Angeles \
  -v /mnt/user/appdata/powershell-scheduler/config:/config:rw \
  -v /mnt/user/appdata/powershell-scheduler/scripts:/scripts:rw \
  -v /mnt/user/appdata/powershell-scheduler/logs:/logs:rw \
  powershell-scheduler:latest
```

The Unraid Docker template should provide equivalent configuration through the Unraid Docker interface.

## Testing

Create a simple test script:

```powershell
$timestamp = Get-Date -Format "yyyy-MM-dd HH:mm:ss"

Write-Host "PowerShell Scheduler Test"
Write-Host "Time: $timestamp"
Write-Host "Host: $env:HOSTNAME"
Write-Host "PowerShell version: $($PSVersionTable.PSVersion)"
Write-Host "Test completed successfully."
```

Save it as:

```text
/scripts/test.ps1
```

Then add the following to `config/crontab`:

```cron
*/5 * * * * /usr/local/bin/run-powershell-script /scripts/test.ps1 /logs/test.log
```

Restart the container.

After the scheduled execution, check:

```text
/logs/test.log
```

You can also view the container's startup and scheduler messages with:

```bash
docker logs PowerShell-Scheduler
```

## Security

The container does not require privileged access.

Only directories explicitly mapped into the container are available to scheduled scripts.

Keep in mind that **PowerShell scripts execute with the permissions available to the container**. Only place trusted scripts in the scripts directory.

Avoid mapping the entire Unraid filesystem unless a script specifically requires it.

## Design Goals

This project intentionally keeps the scheduler simple.

It is intended to provide:

- A reliable PowerShell runtime
- Simple cron-based scheduling
- Persistent scripts and logs
- Easy rebuilding and updating
- Minimal dependencies
- No web interface
- No database

More advanced scheduling, monitoring, notification, and job-management functionality may be added later if needed.

## Base Image

The container is based on Microsoft's .NET SDK container image:

```text
mcr.microsoft.com/dotnet/sdk:8.0
```

PowerShell is included in the Microsoft-provided SDK image.

The image is built locally rather than pulled from a third-party Docker registry.

## License

[Choose a license for this project.]
