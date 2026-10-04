"""Read basic Linux system information using only the standard library."""

import json
import os
import platform
import re
from pathlib import Path


def read(path):
    try:
        return Path(path).read_text().strip()
    except (OSError, UnicodeError):
        return ""


def mount_path(value):
    # mountinfo escapes whitespace and backslashes with octal sequences.
    return re.sub(r"\\([0-7]{3})", lambda match: chr(int(match[1], 8)), value)


def disks():
    mounts = []
    for line in read("/proc/self/mountinfo").splitlines():
        before, separator, after = line.partition(" - ")
        fields, filesystem = before.split(), after.split()
        if not separator or len(fields) < 6 or len(filesystem) < 2:
            continue
        mountpoint = mount_path(fields[4])
        source = mount_path(filesystem[1])
        # Keep root and local storage; skip pseudo and network filesystems.
        if mountpoint != "/" and not source.startswith("/dev/") and filesystem[0] != "zfs":
            continue
        if filesystem[0] == "squashfs":
            continue
        mounts.append((mountpoint, fields[2], source, filesystem[0]))

    result, seen = [], set()
    # Prefer the shortest mountpoint so bind mounts (e.g. /nix/store) do
    # not show the same filesystem's capacity more than once.
    for mountpoint, device, source, filesystem in sorted(mounts, key=lambda mount: len(mount[0])):
        if device in seen:
            continue
        try:
            stats = os.statvfs(mountpoint)
        except OSError:
            continue
        seen.add(device)
        result.append({
            "mountpoint": mountpoint,
            "source": source,
            "filesystem": filesystem,
            "total": stats.f_blocks * stats.f_frsize,
            "used": (stats.f_blocks - stats.f_bfree) * stats.f_frsize,
        })
    return result


def system_info():
    try:
        release = platform.freedesktop_os_release()
    except OSError:
        release = {}

    cpu = ""
    for line in read("/proc/cpuinfo").splitlines():
        key, separator, value = line.partition(":")
        if separator and key.strip() in ("model name", "Hardware", "Processor"):
            cpu = value.strip()
            break

    memory = re.search(r"^MemTotal:\s+(\d+)\s+kB", read("/proc/meminfo"), re.MULTILINE)
    uptime = read("/proc/uptime").split()
    try:
        uptime = float(uptime[0]) if uptime else None
    except ValueError:
        uptime = None

    host = " ".join(filter(None, [read("/sys/class/dmi/id/sys_vendor"), read("/sys/class/dmi/id/product_name")]))
    return {
        "os": release.get("PRETTY_NAME", "Linux"),
        "build": release.get("BUILD_ID", ""),
        "host": host or platform.node(),
        "cpu": cpu or platform.machine(),
        "memory": int(memory[1]) * 1024 if memory else None,
        "kernel": platform.release(),
        "uptime": uptime,
        "disks": disks(),
    }


if __name__ == "__main__":
    print(json.dumps(system_info()))
