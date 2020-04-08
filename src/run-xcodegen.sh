#!/bin/bash

spec="project-with-codesign.yml"

if [[ -z "${PQRS_ORG_CODE_SIGN_IDENTITY:-}" ]]; then
  spec="project-without-codesign.yml"
fi

echo "Use $spec"
xcodegen generate --spec $spec
