"""
Module Documentation
---------------------

This module provides functionality for [briefly describe the purpose of the module]. 
It includes [list key features or components of the module, e.g., classes, functions, or utilities].

Key Features:
- [Feature 1]: [Description of feature 1].
- [Feature 2]: [Description of feature 2].
- [Feature 3]: [Description of feature 3].

Usage:
-------
[Provide a brief example or explanation of how to use the module.]

Dependencies:
-------------
[List any external libraries or modules required for this module to function.]

Author:
-------
[Your Name or Organization]

Date:
-----
[Date of creation or last modification]

"""

# Module: diskUsage

Description
-----------
This module collects disk usage information for mounted filesystems and prints a JSON array where each item describes one filesystem (filesystem, size, used, available, use_percentage, mounted_on).

Metadata
--------
- Name: `diskUsage`
- Version: `1.0`
- Type: `tool`
- Author: Nolhan B.D.
- Main entry: `main.sh`

Prerequisites
-------------
- The `df` command must be available in the system PATH. If `df` is missing, the module exits with a non-zero code and prints an error JSON.
- The script sources the logging helper `../../utils/logger.sh` to write info/error logs. Check `bash-app/logs/app.log` or the configured logger destination.

Output format
-------------
The script prints a JSON array to stdout. Each element has the structure:

{
  "filesystem": "<value>",
  "size": "<value>",
  "used": "<value>",
  "available": "<value>",
  "use_percentage": "<value>",
  "mounted_on": "<value>"
}

The expected keys and types are declared in `module.json` (strings). Example output:

```
[{"filesystem": "/dev/sda1", "size": "50G", "used": "20G", "available": "28G", "use_percentage": "42%", "mounted_on": "/"}, {"filesystem": "tmpfs", "size": "2G", "used": "0G", "available": "2G", "use_percentage": "0%", "mounted_on": "/run"}]
```

Implementation details
----------------------
- The script checks for `df` availability and logs start/finish via `log_info` and errors via `log_error` from the shared logger.
- It runs `df -h` and parses output lines (skipping a header that matches the French `Sys. de fichiers` string). It extracts fields using `awk` by positional indices to populate: `filesystem`, `size`, `used`, `available`, `use_percentage`, `mounted_on` for each line.
- The script builds a JSON array by concatenating per-line JSON objects and removing the trailing comma before closing the array.
- Exit codes:
  - 0: success (JSON array printed to stdout)
  - 1: critical error (e.g. `df` not available). Example error output:
    `{"error": "df command is not available"}`

Limitations and edge cases
+--------------------------
- Parsing depends on the exact output format of `df`. Column positions and header text can vary by locale or distribution (the script currently skips a header containing "Sys. de fichiers" which is language-dependent). This makes parsing fragile on systems using different locales or when `df` outFait la même chose pour les moduleput wraps columns.
- Filesystem names or mount points that contain spaces may break the simple whitespace-based `awk` extraction. Consider using `df -P` (POSIX output) or parsing with more robust logic.
- Values are returned as strings (per `module.json`). Convert them to numbers where appropriate on the consumer side, and strip percent signs if needed for numeric calculations.

Usage
-----
From the module directory:

```bash
cd bash-app/modules/diskUsage
./main.sh
```

The module may also be invoked by the application's main runner if it executes the `main` specified in `module.json`.

Examples
--------
- Successful run (stdout contains JSON array):

```
$ ./main.sh
[{"filesystem": "/dev/sda1", "size": "50G", "used": "20G", "available": "28G", "use_percentage": "42%", "mounted_on": "/"}]
```

- Run when `df` is missing:

```
$ ./main.sh
{"error": "df command is not available"}
```

Logs
----
Events are logged via `utils/logger.sh`. Check `bash-app/logs/app.log` (or your logger destination) for start/finish and errors.

Troubleshooting
---------------
- If you get the error JSON indicating `df` is missing, install the `coreutils`/`util-linux`/`procps` packages as appropriate for your distribution (usually `df` is part of the coreutils or util-linux package).
  - Debian/Ubuntu: `sudo apt install coreutils` (or ensure `util-linux` is installed)
  - RedHat/CentOS/Fedora: `sudo dnf install util-linux` or similar
- If mount points or filesystem names include spaces or columns appear shifted, try `df -P` (POSIX output) or adjust parsing logic to handle fields safely.

Recommended improvements
+------------------------
- Use `df -P` to ensure a stable column layout or parse `/proc/mounts` combined with `statvfs`-style queries for robust programmatic access.
- Normalize numeric outputs (strip units and percent signs, and return numeric JSON types) if consumers need to perform arithmetic.

Contact
-------
For questions or changes, contact the author listed in `module.json` (Nolhan B.D.).

License
-------
See the main project license if present, or add an appropriate license here.