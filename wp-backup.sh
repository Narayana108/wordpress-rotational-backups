#!/bin/bash
set -euo pipefail

# EDIT THESE VARS
_WP_DIR="/var/www/html"
_BACKUP_DIR="/home/vyasa/backups"
_RETENTION=11

# Start 
_LOG_FILE="$_BACKUP_DIR/backup.log"

# Log
log() { echo "[$(date '+%Y-%m-%d %H:%M:%S')] $*" | tee -a "$_LOG_FILE"; }
die() { log "FATAL: $*"; exit 1; }

# Pre-flight
[[ -d "$_WP_DIR" ]] || die "WP dir not found: $_WP_DIR"
[[ -d "$_BACKUP_DIR" ]] || die "Backup dir not found: $_BACKUP_DIR"
command -v wp &>/dev/null || die "wp-cli missing"
command -v mysqldump &>/dev/null || die "mysqldump missing"

# File names
_NOW=$(date +"%m_%d_%Y")
_DB_BKP="wp_db_${_NOW}.sql"
_SITE_BKP="wp_site_${_NOW}.tgz"

log "Starting backup..."

# Credentials
DBNAME=$(wp config get DB_NAME --path="$_WP_DIR") || die "Failed to read DB_NAME"
DBUSER=$(wp config get DB_USER --path="$_WP_DIR") || die "Failed to read DB_USER"
DBPASS=$(wp config get DB_PASSWORD --path="$_WP_DIR") || die "Failed to read DB_PASSWORD"
DBHOST=$(wp config get DB_HOST --path="$_WP_DIR") || die "Failed to read DB_HOST"

# DB dump
log "Dumping database..."
MYSQL_PWD="$DBPASS" mysqldump -u "$DBUSER" -h "$DBHOST" "$DBNAME" > "$_BACKUP_DIR/$_DB_BKP" || die "mysqldump failed"
log "DB saved: $_DB_BKP"

# Site archive 
log "Archiving files..."
tar -czf "$_BACKUP_DIR/$_SITE_BKP" -C "$_WP_DIR" . || die "tar failed"
log "Site saved: $_SITE_BKP"

# Rotation (Count based)
log "Rotating (keeping latest $_RETENTION)..."
mapfile -t db < <(ls -1t "$_BACKUP_DIR"/wp_db_*.sql 2>/dev/null || true)
((${#db[@]} > _RETENTION)) && { log "Removing old DB: ${db[*]:_RETENTION}"; rm -- "${db[@]:_RETENTION}"; }

mapfile -t site < <(ls -1t "$_BACKUP_DIR"/wp_site_*.tgz 2>/dev/null || true)
((${#site[@]} > _RETENTION)) && { log "Removing old site: ${site[*]:_RETENTION}"; rm -- "${site[@]:_RETENTION}"; }

log "Backup completed successfully."
