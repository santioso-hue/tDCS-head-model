#!/bin/bash
# SimNIBS charm — 5-tissue head model generation
# Produces a tetrahedral FEM mesh for tDCS simulation
#
# Requirements: SimNIBS 4.6 installed at ~/Applications/SimNIBS-4.6
# Usage: bash 02_simnibs_charm.sh <subject_id> <T1_input.nii> <output_dir>
#
# NOTE (macOS Apple Silicon): charm uses OpenMP which deadlocks on macOS
# with multiple threads. OMP_NUM_THREADS=1 and KMP_DUPLICATE_LIB_OK=TRUE
# are required. caffeinate prevents macOS from sleeping mid-run.

set -e

SUB_ID="$1"
T1="$2"
OUT_DIR="$3"

export PATH=~/Applications/SimNIBS-4.6/bin:$PATH

SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
INI="$SCRIPT_DIR/../config/charm_highquality.ini"

mkdir -p "$OUT_DIR"
cd "$OUT_DIR"

echo "=== Running SimNIBS charm ==="
echo "Subject:  $SUB_ID"
echo "T1:       $T1"
echo "Output:   $OUT_DIR"
echo "Settings: $INI"
echo ""
echo "Estimated runtime: 3-5 hours (single-threaded, macOS)"

caffeinate -i \
    env OMP_NUM_THREADS=1 KMP_DUPLICATE_LIB_OK=TRUE \
    charm "$SUB_ID" "$T1" \
    --forcerun \
    --usesettings "$INI" \
    --debug

echo ""
echo "=== Done ==="
echo "Head model: $OUT_DIR/m2m_${SUB_ID}/${SUB_ID}.msh"
echo "QC report:  $OUT_DIR/m2m_${SUB_ID}/charm_report.html"
echo ""
echo "Open QC report with:"
echo "  open $OUT_DIR/m2m_${SUB_ID}/charm_report.html"
echo ""
echo "Open 3D model with:"
echo "  ~/Applications/SimNIBS-4.6/bin/gmsh $OUT_DIR/m2m_${SUB_ID}/${SUB_ID}.msh"
