# quickshell-config

A compact, Wisp-inspired shell for Niri. Hover the bottom centre of either screen to reveal its dock. The same surface expands upward into an application runner or power menu, with a fixed bottom edge, cubic easing, and staggered content fades. A 5 px screen frame rounds inward toward the desktop; the dock grows directly from its bottom edge.

The dock includes running applications, workspace dots and the current workspace's number/name, system tray, brightness, notifications, clock, and power. Click an application to focus it; repeated clicks cycle its windows. Application icons are grouped per output. Scroll the app strip if it overflows.

The dock and attached panels have a subtle one-pixel outline along their exposed edges. The dock has a subtle shadow and stays visible while hovered. Click the brightness icon to toggle its controls, growing upward from the dock with rounded inward joins. Brightness, notification history, and the tray open only on click, and opening one closes the others. Click the same control again or click outside to dismiss; brightness and notification history also support Escape. Notification popups and history extend from the top frame at the center of each screen; popup cards retain their existing styling and slide animations. Banners use the top layer, so Niri hides them behind fullscreen windows on that output; their normal timeout continues and notifications remain in history.

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

Geometry and animation timings live in `components/theme/ShellMetrics.qml`; the Carbonfox palette and typography are alongside it. The frame and dock reserve no desktop space. The frame is click-through; its width and inner corner radius are set by `borderWidth` and `screenRadius`. Its invisible activation strip is two pixels high and only spans the dock width. Compositor blur is disabled for shell layers in Niri; the dark tint and outline keep surfaces distinct. Brightness and notification history animate inside fixed-size Wayland windows, avoiding a compositor resize on every animation frame.

Visual reference: [Wisp](https://github.com/SumirSeth/wisp), especially its dock-to-launcher animation and launcher screenshot. The morph follows its 155 ms expansion, 135 ms collapse, 180 ms slide, 8–12 px corner radius, and separated content fades.

The attached frame and panel joins are inspired by [Caelestia](https://github.com/caelestia-dots/shell). They use two small Qt Quick Shape components, with no additional plugin dependency.
