"""
Module Documentation
---------------------

This module provides functionality for [briefly describe the purpose of the module].
It includes [list the main features or components of the module].

Classes:
- [ClassName]: [Brief description of the class and its purpose].

Functions:
- [FunctionName]: [Brief description of the function and its purpose].

Usage:
------
[Provide an example or explanation of how to use the module, if applicable.]

Dependencies:
-------------
[List any external libraries or modules required for this module to function.]

Author:
-------
[Your Name or Author's Name]

Date:
-----
[Date of creation or last modification]

"""

# Module: memoryUsage

Description
-----------
This module collects system memory and swap usage and calculates a global score based on memory usage percentage. It prints a JSON object containing three keys: `memory` (detailed memory usage), `swap` (detailed swap usage), and `score` (an integer score).

Metadata
--------
- Name: `memoryUsage`
- Version: `1.0`
- Type: `tool`
- Author: Nolhan B.D.
- Main entry: `main.sh`

Prerequisites
-------------
- The `free` command must be available in the system PATH. If `free` is missing, the module exits with a non-zero code and prints an error JSON.
- The script sources the logging helper `../../utils/logger.sh` to write info/error logs. Check `bash-app/logs/app.log` or the configured logger destination.

Output format
-------------
The script prints a JSON object to stdout with this structure:

{
  "memory": {
    "total": "<value>",
    "used": "<value>",
    "free": "<value>",
    "shared": "<value>",
    "buff_cache": "<value>",
    "available": "<value>",
    "used_percentage": <value>
  },
  "swap": {
    "total": "<value>",
    "used": "<value>",
    "free": "<value>"
  },
  "score": <value>
}

The expected keys and types are declared in `module.json`. Example output:

```
{
  "memory": {
    "total": "15G", "used": "4G", "free": "9G", "shared": "0G", "buff_cache": "2G", "available": "11G", "used_percentage": 27
  },
  "swap": {
    "total": "2G", "used": "0G", "free": "2G"
  },
  "score": 4
}
```

Implementation details
----------------------
- The script checks for `free` availability and logs start/finish via `log_info` and errors via `log_error` from the shared logger.
- It runs `free -h` and parses the `Mem:` line to extract `total`, `used`, `free`, `shared`, `buff_cache`, `available`, and calculates `used_percentage` as `(used / total) * 100`.
- It also parses the `Échange:` (French for "Swap:") line to extract swap `total`, `used`, and `free` fields. The parsed values are assembled into JSON objects for `memory` and `swap`, then combined into the final JSON printed to stdout.
- The script calculates a `score` based on `used_percentage` thresholds:
  - <20%: 5
  - 20-39%: 4
  - 40-59%: 3
  - 60-79%: 2
  - >=80%: 1
- Exit codes:
  - 0: success (JSON object printed to stdout)
  - 1: critical error (e.g. `free` not available). Example error output:
    `{"error": "free command is not available"}`

Limitations and edge cases
--------------------------
- The script's parsing depends on the output format and language of `free`. It currently expects the memory line to contain `Mem:` and the swap line to match `Échange:` (French). On systems using different locales or language settings the script may fail to find the expected lines. Consider normalizing locale or matching on English `Mem:` / `Swap:` as needed.
- The script uses simple whitespace-based `awk` extraction; if `free` output formatting differs or includes extra columns, indexes may need adjustment.
- Values are returned as strings (per `module.json`). Convert them to numbers where needed on the consumer side (and strip units like `G` or `M` for arithmetic).

Usage
-----
From the module directory:

```bash
cd bash-app/modules/memoryUsage
./main.sh
```

The module may also be invoked by the application's main runner if it executes the `main` specified in `module.json`.

Examples
--------
- Successful run (stdout contains JSON):

```
$ ./main.sh
{
  "memory": {
    "total": "15G", "used": "4G", "free": "9G", "shared": "0G", "buff_cache": "2G", "available": "11G", "used_percentage": 27
  },
  "swap": {
    "total": "2G", "used": "0G", "free": "2G"
  },
  "score": 4
}
```

- Run when `free` is missing:

```
$ ./main.sh
{"error": "free command is not available"}
```

Logs
----
Events are logged via `utils/logger.sh`. Check `bash-app/logs/app.log` (or your logger destination) for start/finish and errors.

Troubleshooting
---------------
- If you get the error JSON indicating `free` is missing, install the `procps` (or equivalent) package that provides `free`:
  - Debian/Ubuntu: `sudo apt install procps`
  - RedHat/CentOS/Fedora: `sudo dnf install procps-ng` or `sudo yum install procps-ng`
- If values are missing or incorrect, inspect the raw output of `free -h` to confirm the expected line labels and field positions, and adjust parsing logic or locale settings accordingly.

Recommended improvements
------------------------
- Use a locale-insensitive parsing strategy (e.g. match numeric fields by position in `free -b` or parse `/proc/meminfo` directly for robust values).
- Normalize and return numeric JSON types (strip units and convert to bytes) if consumers need to perform calculations.

Contact
-------
For questions or changes, contact the author listed in `module.json` (Nolhan B.D.).

License
-------
See the main project license if present, or add an appropriate license here.