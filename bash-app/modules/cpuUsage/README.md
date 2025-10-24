# Module: cpuUsage

Description
-----------
This module collects the system CPU usage and prints a JSON object with several measurements: user, system, nice, idle, wait, hardware_interrupts, software_interrupts, and stolen.

Metadata
--------
- Name: `cpuUsage`
- Version: `1.0`
- Type: `tool`
- Author: Nolhan B.D.
- Main entry: `main.sh`

Prerequisites
-------------
- The `top` command must be available in the system PATH. If `top` is missing, the module exits with a non-zero code and prints an error JSON.
- The script sources the logging helper `../../utils/logger.sh` to write info/error logs. Check `bash-app/logs/app.log` or the configured logger destination.

Output format
-------------
The script prints a JSON object to stdout with the following structure:

{
  "user": "<value>",
  "system": "<value>",
  "nice": "<value>",
  "idle": "<value>",
  "wait": "<value>",
  "hardware_interrupts": "<value>",
  "software_interrupts": "<value>",
  "stolen": "<value>"
}

The expected keys and types are also declared in `module.json` (strings). Example output:

```
{"user": "1.2", "system": "0.5", "nice": "0.0", "idle": "98.0", "wait": "0.1", "hardware_interrupts": "0.0", "software_interrupts": "0.0", "stolen": "0.0"}
```

Implementation details
----------------------
- The script runs `top -bn1 | grep "Cpu(s)"` to capture the CPU percentage line, then parses fields using `awk` by positional indices to populate variables: `user`, `system`, `nice`, `idle`, `wait`, `hardware_interrupts`, `software_interrupts`, and `stolen`.
- Commas are removed from parsed values with `tr -d ','`.
- The script logs start and finish using `log_info` and logs errors using `log_error` from the shared logger.
- Exit codes:
  - 0: success (JSON metrics printed to stdout)
  - 1: critical error (for example, `top` not available). In this case the script prints:
    `{"error": "top command is not available"}`

Limitations and edge cases
--------------------------
- The parsing relies on the exact output format of `top`. The order and format of `top` columns can vary across distributions, top versions or locales (for example decimal separator `,` vs `.`). This can break the positional `awk` indexes.
- For a more robust approach consider using `/proc/stat` or `mpstat` (from the `sysstat` package) which provide more stable data sources.
- Values are returned as strings (per `module.json`). Convert them to numbers where needed on the consumer side.

Usage
-----
From the module directory:

```bash
cd bash-app/modules/cpuUsage
./main.sh
```

The module may also be invoked by the application's main runner if it executes the `main` specified in `module.json`.

Examples
--------
- Successful run (stdout contains metrics JSON):

```
$ ./main.sh
{"user": "1.2", "system": "0.5", "nice": "0.0", "idle": "98.0", "wait": "0.1", "hardware_interrupts": "0.0", "software_interrupts": "0.0", "stolen": "0.0"}
```

- Run when `top` is missing:

```
$ ./main.sh
{"error": "top command is not available"}
```

Logs
----
Events are logged via `utils/logger.sh`. Check `bash-app/logs/app.log` (or your logger destination) for start/finish and errors.

Troubleshooting
---------------
- If you get the error JSON indicating `top` is missing, install `top` (usually provided by the `procps` package):

  - Debian/Ubuntu: `sudo apt install procps`
  - RedHat/CentOS/Fedora: `sudo dnf install procps-ng` or `sudo yum install procps-ng`

- If values are incorrect or empty, inspect the raw output of `top -bn1 | grep "Cpu(s)"` and adjust parsing indexes or locale settings accordingly.

Recommended improvements
------------------------
- Replace positional parsing with regex-based extraction or use `/proc/stat` to make metric collection more robust.
- Normalize numeric formats (force `.` decimal) and return numbers in JSON (not strings) if consumers need to perform calculations.

Contact
-------
For questions or changes, contact the author listed in `module.json` (Nolhan B.D.).

License
-------
See the main project license if present, or add an appropriate license here.

