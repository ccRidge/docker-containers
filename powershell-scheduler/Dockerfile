FROM mcr.microsoft.com/dotnet/sdk:8.0

LABEL org.opencontainers.image.title="PowerShell Scheduler"
LABEL org.opencontainers.image.description="PowerShell 7 scheduled task runner"
LABEL org.opencontainers.image.source="Custom Unraid container"

# Install cron and a couple of useful utilities
RUN apt-get update && \
    apt-get install -y --no-install-recommends \
        anacron \
        tzdata \
        ca-certificates \
        locales \
        libicu-dev \
        && echo "en_US.UTF-8 UTF-8" > /etc/locale.gen \
        && locale-gen en_US.UTF-8
    rm -rf /var/lib/apt/lists/*

ENV POWERSHELL_TELEMETRY_OPTOUT=1
ENV DOTNET_SYSTEM_GLOBALIZATION_INVARIANT=false
ENV LANG=en_US.UTF-8
ENV LC_ALL=en_US.UTF-8

# Container directories
RUN mkdir -p /config /scripts /logs

# Copy entrypoint and pwsh wrapper script
COPY entrypoint.sh /entrypoint.sh
COPY run-powershell-script /usr/local/bin/run-powershell-script
COPY run-powershell-directory /usr/local/bin/run-powershell-directory
RUN chmod +x /entrypoint.sh \
             /usr/local/bin/run-powershell-script \
             /usr/local/bin/run-powershell-directory

ENTRYPOINT ["/entrypoint.sh"]
