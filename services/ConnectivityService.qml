pragma Singleton
import Quickshell
import Quickshell.Networking
import Quickshell.Bluetooth

Singleton {
    readonly property var wifiNetworks: {
        const connected = [];
        if (Networking.wifiEnabled && Networking.wifiHardwareEnabled) {
            for (const device of Networking.devices.values) {
                if (device.type === DeviceType.Wifi) {
                    for (const network of device.networks.values) {
                        if (network.connected)
                            connected.push(network.name);
                    }
                }
            }
        }
        return connected;
    }
    readonly property bool wifiConnected: wifiNetworks.length > 0
    readonly property string wifiStatus: wifiConnected ? wifiNetworks.join(", ") : "Off"
    readonly property bool ethernetConnected: Networking.devices.values.some(
        device => device.type === DeviceType.Wired && device.connected)
    readonly property string ethernetStatus: ethernetConnected ? "Connected" : "Off"
    readonly property bool bluetoothEnabled: Bluetooth.adapters.values.some(adapter => adapter.enabled)
    readonly property var bluetoothDevices: Bluetooth.devices.values.filter(device => device.connected)
        .map(device => device.name || device.deviceName || device.address)
    readonly property string bluetoothStatus: bluetoothDevices.length > 0
        ? bluetoothDevices.join(", ") : bluetoothEnabled ? "On" : "Off"
}
