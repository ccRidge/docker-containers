FROM mcr.microsoft.com/dotnet/sdk:8.0

LABEL org.opencontainers.image.title="PowerShell Scheduler"
LABEL org.opencontainers.image.description="PowerShell 7 scheduled task runner"
LABEL org.opencontainers.image.source="Custom Unraid container"

ENV POWERSHELL_TELEMETRY_OPTOUT=1

# Install cron and a couple of useful utilities
RUN apt-get update && \
    apt-get install -y --no-install-recommends \
        cron \
        tzdata \
        ca-certificates && \
    rm -rf /var/lib/apt/lists/*

# Container directories
RUN mkdir -p /config /scripts /logs

# Copy entrypoint and pwsh wrapper script
COPY entrypoint.sh /entrypoint.sh
COPY run-powershell-script /usr/local/bin/run-powershell-script
COPY run-powershell-directory /usr/local/bin/run-powershell-directory
RUN chmod +x /entrypoint.sh \
             /usr/local/bin/run-powershell-script

ENTRYPOINT ["/entrypoint.sh"]
