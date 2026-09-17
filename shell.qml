//@ pragma UseQApplication
import Quickshell
import "widgets/statusbar"

ShellRoot {
    Variants {
        model: Quickshell.screens
        StatusBar {}
    }
}
