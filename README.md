# NAS Backup Script

A Windows batch script for automated file synchronization to a NAS using robocopy.

## Features

- Reads source and destination mappings from a configuration file
- Creates timestamped logs for each sync operation
- Provides summary statistics (jobs executed, failed)
- Handles multiple sync jobs in a single run

## Usage

```cmd
backup.cmd
```

The script will read `sync_map.txt` and synchronize all configured directories.

## Configuration

### sync_map.txt Format

The `sync_map.txt` file is not included in the repository to protect private information. Create it in the script directory with the following format:

```
# Lines starting with # are comments
NASROOT=\\your-nas-path

# Each sync job: source|destination
C:\Path\To\Source|Backup\Folder\Name
D:\Another\Source|Another\Destination
```

**Format rules:**
- `NASROOT=` sets the base NAS path (required)
- Sync jobs use the format: `SOURCE_PATH|RELATIVE_DEST_PATH`
- Source path is absolute on your local system
- Destination path is relative to NASROOT
- Lines starting with `#` are ignored as comments
- Empty lines are ignored

**Example:**
```
NASROOT=\\192.168.1.100\backups

C:\Users\John\Documents|Documents
D:\Projects|Work\Projects
E:\Photos|Media\Photos
```

## Robocopy Arguments

The script uses the following robocopy arguments:

- `/E` - Copy subdirectories, including empty ones
- `/XO` - Exclude older files (only copy newer files)
- `/FFT` - Assume FAT file times (2-second granularity)
- `/MT:8` - Multi-threaded copying with 8 threads
- `/R:5` - Number of retries on failed copies (5 retries)
- `/W:5` - Wait time between retries (5 seconds)
- `/ETA` - Show estimated time of arrival for each file
- `/TEE` - Output to console and log file
- `/DCOPY:DAT` - Copy directory timestamps (Data, Attributes, Timestamps)
- `/LOG+:` - Append output to log file

## Logs

Logs are stored in the `logs\` directory with the naming format: `YYYY-MM-DD-N.log`

Multiple runs on the same day increment the counter (N) automatically.

## Exit Codes

- `0` - All sync jobs completed successfully
- `1` - One or more sync jobs failed
