# quickshell-config

A compact, Wisp-inspired shell for Niri. Hover the bottom centre of either screen to reveal its dock. The same surface expands upward into an application runner or power menu, with a fixed bottom edge, cubic easing, and staggered content fades.

The dock includes running applications, workspace dots and the current workspace's number/name, system tray, brightness, notifications, clock, and power. Click an application to focus it; repeated clicks cycle its windows. Application icons are grouped per output. Scroll the app strip if it overflows.

The borderless dock has a subtle shadow and stays visible while hovered. Click the brightness icon to toggle its controls centered above the dock. Brightness, notification history, and the tray open only on click, and opening one closes the others. Click the same control again or click outside to dismiss; brightness and notification history also support Escape. Notification popups and history appear at the top center of each screen. Banners use the top layer, so Niri hides them behind fullscreen windows on that output; their normal timeout continues and notifications remain in history.

The runner supports application search, Up/Down selection, Enter to launch, and Escape or an outside click to close. Recently launched applications rank first for the current shell session. The power menu uses the same layout and keys. Restart, shutdown, and logout require a second Enter or click; Escape first cancels confirmation, then closes the menu. Lock uses `loginctl lock-session` and requires a session locker listening for that request.

Run with Quickshell 0.3.2 or newer and the `Niri` QML module:

```sh
quickshell -p /path/to/quickshell-config
```

If your Nix `quickshell` wrapper already adds `--path` for the packaged configuration, use the underlying Quickshell binary for a local preview, or rebuild the package with this source. Passing a second `--path` to that wrapper fails.

IPC commands for compositor keybindings (target the running config with `-p /path/to/quickshell-config` when needed):

```sh
quickshell ipc call -- bar show
quickshell ipc call -- bar hide
quickshell ipc call -- bar toggle
quickshell ipc call -- launcher toggle
quickshell ipc call -- power toggle
```

`bar show` pins the dock on every output. `bar hide` dismisses menus and returns to hover behavior. `bar toggle` hides a visible dock or pins a hidden dock. Runner and power open on the focused output. All three targets accept `show`, `hide`, and `toggle`; `bar getVisible` reports whether any dock is visible. Keep `--` before the target: it prevents `show` being parsed as Quickshell's IPC inspection subcommand.

Example Niri bindings after deploying this configuration:

```kdl
binds {
    Mod+B { spawn "quickshell" "ipc" "call" "--" "bar" "toggle"; }
    Alt+Space { spawn "quickshell" "ipc" "call" "--" "launcher" "toggle"; }
    Mod+Escape { spawn "quickshell" "ipc" "call" "--" "power" "toggle"; }
}
```

Geometry and animation timings live in `components/theme/ShellMetrics.qml`; the Carbonfox palette and typography are alongside it. The dock reserves no desktop space. Its invisible activation strip is two pixels high and only spans the dock width. Rounded blur regions are supplied through Quickshell's Wayland background-effect protocol; the dark tint also works without compositor blur.

Visual reference: [Wisp](https://github.com/SumirSeth/wisp), especially its dock-to-launcher animation and launcher screenshot. The morph follows its 155 ms expansion, 135 ms collapse, 180 ms slide, 8–12 px corner radius, and separated content fades.
