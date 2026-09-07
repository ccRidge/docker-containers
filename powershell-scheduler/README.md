# PowerShell Scheduler for Unraid

A lightweight Docker container for running PowerShell 7 scripts on a schedule on an Unraid server.

The scheduler uses Linux `anacron` to run PowerShell scripts organized into scheduling directories. Scripts are automatically discovered from their respective directories, allowing jobs to be added or removed without modifying a central scheduler configuration or restarting the container.

The container is designed specifically for use on an [Unraid](https://unraid.net/) server. PowerShell is provided by Microsoft's .NET SDK container image, while the scheduler and supporting scripts are maintained in this repository.

## Features

- PowerShell 7
- Linux `anacron` scheduling
- Directory-based scheduling
- Automatic discovery of PowerShell scripts
- Minute, hourly, daily, weekly, and monthly schedules
- Scripts stored outside the Docker container
- Configuration and scheduler state stored outside the Docker container
- Persistent execution logs
- Per-job execution locking
- PowerShell exit-code reporting
- Configurable time zone
- No external database
- No web interface
- Container can be rebuilt without losing scripts or configuration
- Docker image published to Docker Hub
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
┌──────────────────────────────────────┐
│        PowerShell Scheduler          │
│                                      │
│  Microsoft .NET SDK +                │
│  PowerShell + anacron                │
│                                      │
│              anacron                 │
│                 │                    │
│                 ▼                    │
│    run-powershell-directory          │
│                 │                    │
│        ┌────────┼────────┐           │
│        ▼        ▼        ▼           │
│      job1.ps1 job2.ps1 job3.ps1      │
│        │        │        │           │
│        └────────┼────────┘           │
│                 ▼                    │
│    run-powershell-script             │
│                 │                    │
│                 ▼                    │
│             PowerShell               │
│                                      │
│  /config  ──► scheduler state        │
│  /scripts ──► scheduled scripts      │
│  /logs    ──► execution logs         │
└──────────────────────────────────────┘
```

The Docker image contains the scheduler infrastructure. User scripts, scheduler state, and logs are stored on the Unraid filesystem and are not part of the image.

## Unraid Directory Structure

The recommended Unraid application-data directory is:

```text
/mnt/user/appdata/docker/powershell-scheduler/
```

with the following structure:

```text
powershell-scheduler/
├── config/
├── scripts/
│   ├── minute/
│   ├── hourly/
│   ├── daily/
│   ├── weekly/
│   └── monthly/
└── logs/
    ├── minute/
    ├── hourly/
    ├── daily/
    ├── weekly/
    └── monthly/
```

The `config` directory contains scheduler state.

The `scripts` directory contains PowerShell scripts organized by scheduling interval.

The `logs` directory contains persistent execution logs organized to mirror the script directory structure.

The Docker source code is maintained separately from the runtime data.

## Scheduling

Scripts are scheduled based on the directory in which they are stored.

The supported scheduling directories are:

| Directory | Schedule |
|---|---|
| `minute` | Every minute |
| `hourly` | Every hour |
| `daily` | Every day |
| `weekly` | Every 7 days |
| `monthly` | Every 30 days |

For example:

```text
/scripts/
├── minute/
│   └── test.ps1
├── hourly/
│   └── system-check.ps1
├── daily/
│   ├── property-monitor.ps1
│   └── backup-check.ps1
├── weekly/
│   └── cleanup.ps1
└── monthly/
    └── report.ps1
```

The scheduler automatically scans each directory when its corresponding scheduling interval runs.

Adding a new PowerShell script therefore requires nothing more than placing the script in the appropriate directory.

For example:

```text
/scripts/daily/new-job.ps1
```

will automatically become part of the daily schedule.

Removing a script from a scheduling directory removes it from future scheduling cycles.

No scheduler configuration needs to be edited, and the container does not need to be restarted.

### Minute Scheduling

The `minute` directory runs every minute.

This interval is particularly useful for testing:

```text
/scripts/minute/test.ps1
```

A script can therefore be tested quickly without creating a temporary cron configuration.

### Anacron

Anacron provides the underlying scheduling mechanism.

Scheduler state is stored under `/config`, allowing the scheduler to retain its execution history across container restarts.

This is particularly important for daily, weekly, and monthly jobs because restarting the container does not reset the scheduler's knowledge of when those jobs were last executed.

## Script Discovery and Execution

The directory scheduler is intentionally separate from the script execution wrapper.

`run-powershell-directory` is responsible for:

1. Determining the appropriate script directory.
2. Discovering PowerShell `.ps1` files.
3. Deriving a unique job name for each script.
4. Determining the corresponding log file.
5. Invoking `run-powershell-script`.

`run-powershell-script` is responsible for the actual execution of each job.

This separation keeps scheduling and execution concerns independent.

The execution wrapper handles:

- Execution timestamps
- Persistent logging
- PowerShell invocation
- Exit-code handling
- Job-level locking

## Job Names

Jobs are identified using their scheduling directory and script name.

For example:

```text
/scripts/daily/property-monitor.ps1
```

has the job name:

```text
daily/property-monitor
```

The job name is used to create a unique lock for that script.

This prevents the same PowerShell script from being executed concurrently if a previous invocation is still running.

## Job Locking

The scheduler prevents overlapping executions of the same job.

If a scheduled execution starts while the same job is already running, the second execution is skipped and the event is recorded in the job's log.

For example:

```text
2026-09-07 01:53:01 SKIPPED: Job 'daily/property-monitor' is already running script '/scripts/daily/property-monitor.ps1'
```

The lock applies to the individual job rather than the entire scheduler.

Different jobs can therefore run independently while preventing multiple simultaneous executions of the same job.

## Logging

Each PowerShell script has its own persistent log file.

The log directory mirrors the script directory structure.

For example:

```text
/scripts/daily/property-monitor.ps1
```

writes to:

```text
/logs/daily/property-monitor.log
```

Another example:

```text
/scripts/weekly/cleanup.ps1
```

writes to:

```text
/logs/weekly/cleanup.log
```

Each execution records the start time, job name, script path, script output, end time, and exit code.

A typical log entry looks like:

```text
============================================================
START:    2026-09-07 01:45:01
JOB:      daily/property-monitor
SCRIPT:   /scripts/daily/property-monitor.ps1
============================================================

PowerShell script output appears here.

============================================================
END:      2026-09-07 01:45:07
JOB:      daily/property-monitor
EXIT CODE: 0
============================================================
```

## Exit Codes

The execution wrapper preserves the exit code returned by the PowerShell script.

For example, if a PowerShell script exits with:

```powershell
exit 42
```

the scheduler records:

```text
EXIT CODE: 42
```

in the execution log and returns the same exit code from the wrapper.

A successful script should normally return:

```text
EXIT CODE: 0
```

This allows scheduled jobs to report success or failure through their process exit status.

## Scripts

PowerShell scripts are stored in:

```text
/scripts
```

and organized into scheduling directories.

For example:

```text
/scripts/daily/property-monitor.ps1
```

Scripts are executed using PowerShell 7 with:

```text
-NoLogo -NoProfile -NonInteractive
```

This makes scheduled execution independent of an interactive PowerShell session.

Only `.ps1` files are considered scheduled PowerShell scripts.

## Time Zone

The container should be configured with the desired IANA time zone using the `TZ` environment variable.

For a Pacific Time Unraid server:

```text
TZ=America/Los_Angeles
```

The container configures its system time zone from this value so that anacron scheduling and scheduler timestamps use local time rather than UTC.

The configured time zone can be seen in the container startup output.

## Docker Volumes

The container uses three persistent volume mappings:

| Unraid Path | Container Path | Purpose |
|---|---|---|
| `/mnt/user/appdata/docker/powershell-scheduler/config` | `/config` | Scheduler state |
| `/mnt/user/appdata/docker/powershell-scheduler/scripts` | `/scripts` | PowerShell scripts |
| `/mnt/user/appdata/docker/powershell-scheduler/logs` | `/logs` | Execution logs |

No persistent data should be stored inside the container itself.

## Building the Image

Clone the repository onto the Unraid server:

```bash
mkdir -p /mnt/user/appdata/docker/powershell-scheduler-source

cd /mnt/user/appdata/docker/powershell-scheduler-source

git clone <REPOSITORY-URL> .
```

Build the image:

```bash
cd powershell-scheduler

docker build --pull -t powershell-scheduler:latest .
```

The `--pull` option ensures that Docker checks for a newer version of the base image before building.

## Updating

Pull the latest source from GitHub:

```bash
cd /mnt/user/appdata/docker/powershell-scheduler-source

git pull
```

Then rebuild:

```bash
cd powershell-scheduler

docker build --pull -t powershell-scheduler:latest .
```

Recreate the container after rebuilding so it uses the new image.

User scripts, scheduler state, and logs are stored outside the image and will not be affected by rebuilding the container.

## Docker Hub

Release images are published to Docker Hub:

```text
ccridge/powershell-scheduler
```

Each release is published with both a version-specific tag and the `latest` tag.

For example:

```text
ccridge/powershell-scheduler:0.2.0
ccridge/powershell-scheduler:latest
```

Version-specific tags provide a predictable, fixed version that remains available after subsequent releases.

The `latest` tag points to the most recent published release.

Production deployments should generally use a version-specific tag when predictable upgrades are desired.

## Docker Configuration

Example:

```bash
docker run -d \
  --name=PowerShell-Scheduler \
  --restart unless-stopped \
  -e TZ=America/Los_Angeles \
  -v /mnt/user/appdata/docker/powershell-scheduler/config:/config:rw \
  -v /mnt/user/appdata/docker/powershell-scheduler/scripts:/scripts:rw \
  -v /mnt/user/appdata/docker/powershell-scheduler/logs:/logs:rw \
  ccridge/powershell-scheduler:0.2.0
```

For local development builds, replace the image name with:

```text
powershell-scheduler:latest
```

The Unraid Docker template should provide equivalent configuration through the Unraid Docker interface.

## Testing

Example test scripts are provided in the repository's `examples/` directory.

These scripts are intended to be copied into the appropriate scheduling directory on the Unraid server.

### Basic Environment Test

The basic test script is:

```text
examples/test.ps1
```

Copy it to:

```text
/mnt/user/appdata/docker/powershell-scheduler/scripts/minute/test.ps1
```

The script validates the PowerShell environment and verifies that the mounted log volume is writable.

The example script contains:

```powershell
# test.ps1 - Validates Container Environment and Volume Mounts
Write-Output "[$(Get-Date -Format 'yyyy-MM-dd HH:mm:ss')] ---> PowerShell Scheduler Test Initialized <---"
Write-Output "Running as User: $env:USERNAME"
Write-Output "PowerShell Version: $($PSVersionTable.PSVersion)"

# Test log directory access (useful if you mount a log volume)
$logPath = "/logs/test_run.log"
try {
    New-Item -ItemType Directory -Force -Path "/logs" | Out-Null
    "[$(Get-Date)] Test script successfully wrote to logs." | Out-File -FilePath $logPath -Append
    Write-Output "SUCCESS: Volume read/write access verified at $logPath"
} catch {
    Write-Warning "WARNING: Could not write to logs directory. Check volume permissions. Error: $_"
}

Write-Output "[$(Get-Date -Format 'yyyy-MM-dd HH:mm:ss')] ---> Test Completed Successfully <---"
```

The scheduler should automatically discover the script during the next minute scheduling cycle.

The scheduler's execution log will be:

```text
/logs/minute/test.log
```

The test script also writes a separate volume verification entry to:

```text
/logs/test_run.log
```

### Job Locking Test

The job-locking test script is:

```text
examples/job-locking-test.ps1
```

Copy it to:

```text
/mnt/user/appdata/docker/powershell-scheduler/scripts/minute/job-locking-test.ps1
```

The script intentionally runs longer than the one-minute scheduling interval.

The scheduler will attempt to start it again while the first execution is still running. The second attempt should be skipped because the job is already locked.

The resulting log can be checked at:

```text
/logs/minute/job-locking-test.log
```

Look for a message similar to:

```text
SKIPPED: Job 'minute/job-locking-test' is already running
```

### Viewing Container Logs

The container's startup and scheduler messages can be viewed with:

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
- Simple directory-based scheduling
- Persistent scripts and logs
- Persistent scheduler state
- Easy rebuilding and updating
- Minimal dependencies
- Simple job-level execution locking
- Predictable execution and logging
- No web interface
- No database

The project is not intended to become a full-featured enterprise job scheduler.

More advanced scheduling, monitoring, notification, and job-management functionality may be added later if it provides useful functionality without unnecessarily increasing the complexity of the container.

## Versioning

The project uses Semantic Versioning:

```text
MAJOR.MINOR.PATCH
```

The scheduler version is maintained in:

```text
powershell-scheduler/VERSION
```

For example:

```text
0.2.0
```

The version in the `VERSION` file is used by the GitHub Actions build to create the corresponding Docker image tag.

Version-specific Docker images are retained so that a particular release can always be deployed explicitly.

## Base Image

The container is based on Microsoft's .NET SDK container image:

```text
mcr.microsoft.com/dotnet/sdk:8.0
```

PowerShell is included in the Microsoft-provided SDK image.

The image can be built locally on the Unraid server or pulled from Docker Hub after a release has been published.

## License

This project is licensed under the MIT License. See the LICENSE file for the full license text.
