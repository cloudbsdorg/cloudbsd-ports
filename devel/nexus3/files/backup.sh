#!/bin/sh
#
# nexus3 backup script
# Install to: /usr/local/etc/periodic/daily/ or /usr/local/etc/periodic/weekly/
# Or run manually: sh /usr/local/nexus3/bin/nexus-backup.sh
#

# Configuration
BACKUP_DIR="${BACKUP_DIR:-/var/backups/nexus3}"
NEXUS_DATA_DIR="${NEXUS_DATA_DIR:-/var/sonatype-work/nexus3}"
RETENTION_DAYS="${RETENTION_DAYS:-7}"
NEXUS_USER="${NEXUS_USER:-nexus}"
NEXUS_CMD="${NEXUS_CMD:-/usr/local/nexus3/bin/nexus}"

# Create backup directory
mkdir -p "$BACKUP_DIR"

# Log file
LOG="$BACKUP_DIR/backup.log"

log_msg() {
    echo "$(date '+%Y-%m-%d %H:%M:%S') - $1" >> "$LOG"
}

log_msg "Starting Nexus3 backup..."

# Check if nexus is running
if ! service nexus3 status >/dev/null 2>&1; then
    log_msg "WARNING: Nexus3 is not running, skipping backup"
    exit 0
fi

# Create backup filename with timestamp
TIMESTAMP=$(date '+%Y%m%d_%H%M%S')
BACKUP_FILE="$BACKUP_DIR/nexus3_backup_${TIMESTAMP}.tar.gz"

# Stop nexus gracefully
log_msg "Stopping Nexus3..."
service nexus3 stop >/dev/null 2>&1

# Wait for shutdown
WAIT_COUNT=0
while [ $WAIT_COUNT -lt 60 ]; do
    if ! pgrep -f "$NEXUS_CMD" >/dev/null 2>&1; then
        break
    fi
    sleep 1
    WAIT_COUNT=$((WAIT_COUNT + 1))
done

# Force stop if still running
if pgrep -f "$NEXUS_CMD" >/dev/null 2>&1; then
    log_msg "WARNING: Forcing shutdown..."
    service nexus3 forcestop >/dev/null 2>&1
    sleep 5
fi

# Create backup
log_msg "Creating backup: $BACKUP_FILE"
tar -czf "$BACKUP_FILE" -C /var/sonatype-work nexus3 2>/dev/null

if [ $? -eq 0 ]; then
    log_msg "Backup created successfully"
    BACKUP_SIZE=$(du -h "$BACKUP_FILE" | cut -f1)
    log_msg "Backup size: $BACKUP_SIZE"
else
    log_msg "ERROR: Backup failed"
fi

# Start nexus
log_msg "Starting Nexus3..."
service nexus3 start >/dev/null 2>&1

# Clean old backups
log_msg "Cleaning backups older than $RETENTION_DAYS days..."
find "$BACKUP_DIR" -name "nexus3_backup_*.tar.gz" -mtime +$RETENTION_DAYS -delete 2>/dev/null
CLEANED=$(find "$BACKUP_DIR" -name "nexus3_backup_*.tar.gz" -mtime +$RETENTION_DAYS 2>/dev/null | wc -l)
[ "$CLEANED" -gt 0 ] && log_msg "Removed $CLEANED old backup(s)"

# List current backups
log_msg "Current backups:"
du -h "$BACKUP_DIR"/nexus3_backup_*.tar.gz 2>/dev/null | while read size file; do
    log_msg "  $file ($size)"
done

log_msg "Backup complete"
