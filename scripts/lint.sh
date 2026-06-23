#!/usr/bin/env bash
set -euo pipefail

REPO_ROOT="$(cd "$(dirname "${BASH_SOURCE[0]}")/.." && pwd)"
cd "${REPO_ROOT}"

echo "==> Helm lint"
if ! command -v helm >/dev/null 2>&1; then
  echo "WARNING: helm not found — skipping Helm lint (install helm or run in CI)"
else
  find . -name Chart.yaml -not -path './lib/*' | while read -r chart; do
    dir="$(dirname "${chart}")"
    echo "  lint: ${dir}"
    if grep -q '^dependencies:' "${chart}" 2>/dev/null; then
      helm dependency update "${dir}" >/dev/null 2>&1 || true
    fi
    helm lint "${dir}"
  done

  echo "==> Render platform application generator"
  helm template test apps/platform/chart \
    -f clusters/kind-local/k8s-features.yaml \
    --namespace argocd >/dev/null
fi

echo "==> YAML syntax check (yq or python)"
if command -v yq >/dev/null 2>&1; then
  find . \( -name '*.yaml' -o -name '*.yml' \) \
    -not -path './**/charts/*' \
    -not -path './**/templates/*' \
    -not -path './.git/*' | while read -r f; do
    yq eval '.' "${f}" >/dev/null
  done
else
  python3 - <<'PY'
import pathlib, sys
try:
    import yaml
except ImportError:
    print("Skipping YAML validation: PyYAML not installed")
    sys.exit(0)
root = pathlib.Path(".")
skip = {".git", "charts", "templates"}
for pattern in ("*.yaml", "*.yml"):
    for f in root.rglob(pattern):
        if skip.intersection(f.parts):
            continue
        with open(f) as fh:
            list(yaml.safe_load_all(fh))
print("YAML syntax OK (python)")
PY
fi

echo "All lint checks passed."
