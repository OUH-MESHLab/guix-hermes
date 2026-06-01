#!/bin/sh
# Build the reproducible Hermes OCI image from the pinned guix-hermes channel.
#
# Produces a rootless-Podman image tagged
#   localhost/hermes:<guix-hermes-commit>
# consumed by the three hermes-{tutor,household,ops} containers in the
# entelequia dotfiles (entelequia/system/lib/edison-services.scm).  Keep the
# %hermes-commit pin there in sync with the commit this script tags.
#
# The image is built with `guix pack -f docker` under `guix time-machine`, so
# the bytes are pinned to channels-lock.scm: same commit in, same image out.
# No opaque Docker Hub pull — the supply-chain story is identical to a native
# `guix build hermes-agent`.
#
# Run on the deploy host (edison; rootless Podman, user rafael), e.g.:
#   ssh -p 2222 rafael@edison /path/to/build-hermes-image.sh
# or copy + run locally on edison.

set -eu

# Channel lock that pins guix-hermes (and everything else).  Override with
# CHANNELS_LOCK if your checkout lives elsewhere.
CHANNELS_LOCK="${CHANNELS_LOCK:-$HOME/.dotfiles/channels-lock.scm}"
MANIFEST="${MANIFEST:-$(CDPATH= cd -- "$(dirname -- "$0")/.." && pwd)/pack/hermes-pack-manifest.scm}"

[ -f "$CHANNELS_LOCK" ] || { echo "!! channels lock not found: $CHANNELS_LOCK" >&2; exit 1; }
[ -f "$MANIFEST" ]      || { echo "!! pack manifest not found: $MANIFEST" >&2; exit 1; }

# Derive the image tag from the locked guix-hermes commit so the pin cannot
# drift from channels-lock.scm.  Override with HERMES_COMMIT if needed.
COMMIT="${HERMES_COMMIT:-$(sed -n "/(name 'guix-hermes)/,/commit/ s/.*commit \"\\([0-9a-f]\\{7,\\}\\)\".*/\\1/p" "$CHANNELS_LOCK" | head -n1)}"
[ -n "$COMMIT" ] || { echo "!! could not read guix-hermes commit from $CHANNELS_LOCK" >&2; exit 1; }
TAG="localhost/hermes:${COMMIT}"

echo ">> Building Hermes OCI image $TAG"
echo ">> channels-lock: $CHANNELS_LOCK"
echo ">> manifest:      $MANIFEST"

if podman image exists "$TAG"; then
    echo ">> Image $TAG already present; nothing to do."
    echo ">> (Force rebuild: podman rmi $TAG && rerun.)"
    exit 0
fi

# `guix pack -f docker' prints the path of the generated image tarball on
# stdout.
#   -S /bin=bin            entry-point path bin/hermes resolves
#   -S /etc/ssl=etc/ssl    stable CA-bundle path for SSL_CERT_FILE (see manifest)
#   --entry-point=bin/hermes  image runs the wrapped `hermes' launcher; each
#                             container passes `gateway' as its command.
echo ">> guix pack (this may take a while on first build)..."
TARBALL="$(guix time-machine -C "$CHANNELS_LOCK" -- \
    pack -f docker \
         -S /bin=bin \
         -S /etc/ssl=etc/ssl \
         --entry-point=bin/hermes \
         -m "$MANIFEST")"
echo ">> Built tarball: $TARBALL"

# Load and retag to the stable localhost/hermes:<commit>.  guix names the
# loaded image after the first package + a hash; capture and retag it.
LOADED="$(podman load -i "$TARBALL" | sed -n 's/^Loaded image: *//p' | head -n1)"
[ -n "$LOADED" ] || { echo "!! podman load did not report a loaded image" >&2; exit 1; }
echo ">> Loaded: $LOADED"
podman tag "$LOADED" "$TAG"
echo ">> Tagged: $TAG"

# Smoke test: the wrapped launcher runs from the image entry-point (proves the
# closure + the store-bash shebang + the runtime-tool PATH wrap are intact).
# End-to-end TLS (the CA bundle at /etc/ssl/certs) is exercised when a gateway
# first connects to Mattermost / the LLM API at deploy time.
echo ">> Smoke test: hermes --version"
podman run --rm "$TAG" --version

echo ">> Done.  Reference this image as $TAG from edison-services.scm"
echo ">> (set %hermes-commit to \"$COMMIT\")."
