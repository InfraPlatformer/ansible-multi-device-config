#!/usr/bin/env bash
set -euo pipefail

# Installs Ghidra into /opt/ghidra in the container.
VERSION="11.0"
GHIDRA_ZIP="ghidra_${VERSION}_PUBLIC_20240214.zip"
URL="https://github.com/NationalSecurityAgency/ghidra/releases/download/Ghidra_${VERSION}_PUBLIC/${GHIDRA_ZIP}"

if [[ $EUID -ne 0 ]]; then
  echo "Please run as root inside the container (sudo)." >&2
  exit 1
fi

apt-get update && apt-get install -y --no-install-recommends openjdk-17-jre && rm -rf /var/lib/apt/lists/*
mkdir -p /opt/ghidra
cd /opt/ghidra
if [[ ! -f ${GHIDRA_ZIP} ]]; then
  echo "Downloading ${GHIDRA_ZIP}..."
  wget -q "$URL"
fi
unzip -q -o "$GHIDRA_ZIP"
ln -sfn /opt/ghidra/ghidra_${VERSION}_PUBLIC /opt/ghidra/current

cat <<'EOT' >/usr/local/bin/ghidra
#!/usr/bin/env bash
exec /opt/ghidra/current/ghidraRun "$@"
EOT
chmod +x /usr/local/bin/ghidra

echo "Ghidra installed. Run: ghidra"
