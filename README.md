[![Build Status](https://github.com/pqrs-org/Tinkle/workflows/CI/badge.svg)](https://github.com/pqrs-org/Tinkle/actions)
[![License](https://img.shields.io/badge/license-Public%20Domain-blue.svg)](https://github.com/pqrs-org/Tinkle/blob/main/LICENSE.md)

# Tinkle

Tinkle is a macOS app which appends a visual effect for the focused window changes.<br/>
It helps finding the focused window when you switched it by keyboard shortcuts.

![Tinkle](docs/Tinkle.gif)

## Download

You can download from <https://tinkle.pqrs.org/>.

## Supported systems

macOS 11 Big Sur or later.

### Required privilege

Tinkle requires accessibility features in order to detect the focused window changes.

<img src="docs/accessibility-access.png" width="350" alt="accessibility access" />

---

## For developers

### How to build

System requirements to build Tinkle:

-   macOS 11.0+
-   Xcode 13+
-   Command Line Tools for Xcode
-   [XcodeGen](https://github.com/yonaskolb/XcodeGen)
-   [create-dmg](https://github.com/sindresorhus/create-dmg)

#### Steps

1.  Get source code by executing a following command in Terminal.app.

    ```shell
    git clone --depth 1 https://github.com/pqrs-org/Tinkle.git
    cd Tinkle
    git submodule update --init --recursive --depth 1
    ```

2.  Find your codesign identity if you have one.<br />
    (Skip this step if you don't have your codesign identity.)

    ```shell
    security find-identity -p codesigning -v | grep 'Developer ID Application'
    ```

    The result is as follows.

    ```text
    1) 8D660191481C98F5C56630847A6C39D95C166F22 "Developer ID Application: Fumihiko Takayama (G43BCU2T37)"
    ```

    Your codesign identity is `8D660191481C98F5C56630847A6C39D95C166F22` in the above case.

3.  Set environment variable to use your codesign identity.<br />
    (Skip this step if you don't have your codesign identity.)

    ```shell
    export PQRS_ORG_CODE_SIGN_IDENTITY=8D660191481C98F5C56630847A6C39D95C166F22
    ```

4.  Build a package by executing a following command in Terminal.app.

    ```shell
    make package
    ```

    `Tinkle-*.dmg` will be generated.

    Note: If you don't have codesign identity, the dmg works only on your machine.

### Playgrounds

Tinkle users Metal shader to make effects.

`playground/Metal.playground` helps you if you want to add your own effect.
