"""List executable files in PATH order, using only the standard library."""

import json
import os


def executables(path=None):
    found = {}
    for directory in (os.environ.get("PATH", os.defpath) if path is None else path).split(os.pathsep):
        try:
            with os.scandir(directory or os.curdir) as entries:
                for entry in entries:
                    if entry.name not in found and entry.is_file() and os.access(entry.path, os.X_OK):
                        found[entry.name] = {"name": entry.name, "path": os.path.abspath(entry.path)}
        except OSError:
            continue
    return sorted(found.values(), key=lambda entry: entry["name"].casefold())


if __name__ == "__main__":
    print(json.dumps(executables()))
