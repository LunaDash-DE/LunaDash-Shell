# LunaDash Shell

This repository contains LunaDash's Quickshell/QML desktop interface. It can be installed separately from the LunaDash compositor and desktop services. The integration repository downloads a pinned revision during its normal install and supplies the C++ desktop services, translations, assets, and Quickshell runtime.

## Install

Run the installer directly from a clone:

```sh
git clone https://github.com/LunaDash-DE/LunaDash-Shell.git
cd LunaDash-Shell
./install.sh
```

By default, the files are installed to `~/.local/share/lunadash/shell`. Choose a system prefix with `sudo ./install.sh --prefix /usr`. To install the current `main` branch without first cloning it, run:

```sh
curl -fsSL https://raw.githubusercontent.com/LunaDash-DE/LunaDash-Shell/main/install.sh | bash
```

The installer copies only QML, JavaScript, `qmldir`, and UI asset files. It does not install Quickshell or LunaDash's native services. Both are runtime requirements supplied separately.

A Shell commit does not update an installed integration checkout automatically. LunaDash pins the exact Shell commit in its `dev` branch and adopts updates through its install/package configuration.
