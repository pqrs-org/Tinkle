[![Build Status](https://github.com/pqrs-org/Tinkle/workflows/CI/badge.svg)](https://github.com/pqrs-org/Tinkle/actions)
[![License](https://img.shields.io/badge/license-Public%20Domain-blue.svg)](https://github.com/pqrs-org/Tinkle/blob/master/LICENSE.md)

# Tinkle

Tinkle is a macOS app which appends a visual effect for the focused window changes.<br/>
It helps finding the focused window when you switched it by keyboard shortcuts.

![Tinkle](docs/Tinkle.gif)

## Download

You can download from <https://tinkle.pqrs.org/>.

## Supported systems

macOS Catalina (10.15) or later.

### Required privilege

Tinkle requires accessibility features in order to detect the focused window changes.

<img src="docs/accessibility-access.png" width="350" alt="accessibility access" />

---

## For developers

### How to build

System requirements to build Tinkle:

-   macOS 10.15+
-   Xcode 11+
-   Command Line Tools for Xcode
-   [XcodeGen](https://github.com/yonaskolb/XcodeGen)
-   [create-dmg](https://github.com/sindresorhus/create-dmg)

#### Step 1: Getting source code

Clone the source from github.

```shell
git clone --depth 1 https://github.com/pqrs-org/Tinkle.git
```

#### Step 2: Building a dmg

Execute make command on the terminal.

```shell
make package
```

`Tinkle-*.dmg` will be generated.

### Playgrounds

Tinkle users Metal shader to make effects.

`playground/Metal.playground` helps you if you want to add your own effect.
