[![Build Status](https://github.com/pqrs-org/Tinkle/workflows/CI/badge.svg)](https://github.com/pqrs-org/Tinkle/actions)
[![License](https://img.shields.io/badge/license-Public%20Domain-blue.svg)](https://github.com/pqrs-org/Tinkle/blob/master/LICENSE.md)

# Tinkle

Tinkle is a macOS app which appends a visual effect for the focused window changes.<br/>
It helps finding the focused window when you switched it by keyboard shortcuts.

![Tinkle](docs/Tinkle.gif)

---

## Supported systems

macOS Catalina (10.15) or later.

### Required privilege

Tinkle requires accessibility features in order to detect the focused window changes.

<img src="docs/accessibility-access.png" width="350" alt="accessibility access" />

---

## Using a pre-built binary

Use `dist/Tinkle-xxx.dmg`

## Building from source code

Execute make command on the terminal.

```shell
make -C src
```

`src/build/Release/Tinkle.app` is a built file.
