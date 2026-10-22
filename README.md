# LunaDash Shell

This repository contains LunaDash's Quickshell/QML desktop interface. The integration repository pins it as the `qml/` submodule and supplies the C++ desktop services, translations, assets, and installed Quickshell runtime.

QML changes should be validated with the integration repository's QML design/action audits and Qt/Wayland workflows. A commit here does not update a running integration checkout; review and pin the new commit in the integration repository's `dev` branch.
