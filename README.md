# WordPress Rotational Backups

Lightweight Bash script for automated WordPress backups with count-based rotation, strict error handling, and secure credential injection.

## Features
- Count-based retention (keeps latest `N`, never drops to zero during outages)
- Secure DB auth via `MYSQL_PWD` (no CLI warnings, no `ps` exposure)
- Fail-fast (`set -euo pipefail`) + timestamped logging
- Dotfile-safe archiving (`.htaccess`, `.user.ini`, etc.)

## Requirements
`wp-cli`

## Setup
```bash
git clone https://github.com/Narayana108/wordPress-rotational-backups && cd wordpress-rotational-backups

chmod +x wp-backup.sh
vim wp-backup.sh  # Edit paths & retention
./wp-backup.sh
```
Logs write to `$_BACKUP_DIR/backup.log` and stdout.

## Configuration
Edit at the top of the script:
| Var | Default | Purpose |
|-----|---------|---------|
| `_WP_DIR` | `/var/www/html` | WP root (no trailing slash) |
| `_BACKUP_DIR` | `/home/ubuntu/backups/wp` | Backup destination (must exist) |
| `_RETENTION` | `11` | Number of latest backups to keep |

## Automation (Debian/Ubuntu)
**User cron:**
```bash
crontab -e
0 5 * * * /path/to/wp-backup.sh >/dev/null 2>&1
```

**System-wide (recommended for servers):**
```bash
echo "0 5 * * * root /path/to/wp-backup.sh >/dev/null 2>&1" | sudo tee /etc/cron.d/wp-backup
sudo chmod 644 /etc/cron.d/wp-backup
```

## Notes
- Date format is `%m_%d_%Y`. Running twice daily overwrites. Change to `%m_%d_%Y_%H%M%S` if needed.
- Ensure `$_BACKUP_DIR` is `chmod 700` if storing sensitive data.
- Test restores periodically. Backups are only as good as your last verified restore.

## License
MIT. Use at your own risk.
