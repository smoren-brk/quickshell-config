//@ pragma UseQApplication
import Quickshell
import "components"
import "widgets/statusbar"

ShellRoot {
    Variants {
        model: Quickshell.screens
        ScreenFrame {}
    }
    Variants {
        model: Quickshell.screens
        StatusBar {}
    }
}
