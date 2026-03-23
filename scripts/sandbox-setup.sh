#!/bin/bash
set -eo pipefail
source "$(dirname "${BASH_SOURCE[0]}")/sandbox-common.sh"

require_docker_user

SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
KIT_ROOT="$(cd "$SCRIPT_DIR/.." && pwd)"
TEMPLATE_DIR="$KIT_ROOT/sandcastle"

if [ ! -f "$TEMPLATE_DIR/Dockerfile" ]; then
  echo "Error: Missing sandcastle template Dockerfile at $TEMPLATE_DIR/Dockerfile"
  exit 1
fi

echo "Repo:    $REPO_NAME"
echo "Image:   $IMAGE"
echo "Sandbox: $SANDBOX_NAME"
echo ""

if docker image inspect "$IMAGE" >/dev/null 2>&1; then
  echo "Template image already exists, skipping build."
else
  echo "Building sandcastle template image..."
  docker build -t "$IMAGE" "$TEMPLATE_DIR"
  echo "Pushing template image to Docker Hub..."
  docker push "$IMAGE"
fi

if docker sandbox ls 2>/dev/null | grep -q "$SANDBOX_NAME"; then
  echo "Sandbox '$SANDBOX_NAME' already exists."
else
  echo "Creating sandbox '$SANDBOX_NAME'..."
  docker sandbox run \
    -t "$IMAGE" \
    claude . -- \
    --print "Setup complete. Reply with only: Sandbox initialized successfully."
fi

echo ""
echo "Sandbox setup complete."
