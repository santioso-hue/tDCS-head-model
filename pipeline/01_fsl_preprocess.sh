#!/bin/bash
# FSL Preprocessing Pipeline
# Step 1: Reorient to standard space
# Step 2: Robust FOV crop (remove neck)
# Step 3: Brain extraction (BET)
# Step 4: Tissue segmentation (FAST)
#
# Requirements: FSL installed at ~/fsl
# Usage: bash 01_fsl_preprocess.sh <T1_input.nii> <output_dir>

set -e

T1="$1"
OUT="$2"

export FSLDIR=~/fsl
export PATH=$FSLDIR/bin:$PATH
export FSLOUTPUTTYPE=NIFTI

mkdir -p "$OUT"

echo "=== Step 1: Reorient to standard ==="
fslreorient2std "$T1" "$OUT/T1w_reoriented"

echo "=== Step 2: Robust FOV (crop neck) ==="
robustfov -i "$OUT/T1w_reoriented.nii" \
          -r "$OUT/T1w_robustfov.nii" \
          -m "$OUT/T1w_roi2full.mat"

echo "=== Step 3: Brain extraction (BET) ==="
# -f 0.30 : fractional intensity threshold (tuned for this dataset)
# -R      : robust brain centre estimation
# -B      : bias field and neck cleanup
# -m      : save brain mask
bet "$OUT/T1w_robustfov.nii" "$OUT/T1w_brain" \
    -f 0.30 -R -B -m

echo "=== Step 4: Tissue segmentation (FAST) ==="
# -t 1 : T1-weighted input
# -n 3 : 3 tissue classes (CSF / GM / WM)
# -B   : bias field correction
fast -t 1 -n 3 -H 0.1 -I 4 -l 20 -B \
     -o "$OUT/T1w_fast" \
     "$OUT/T1w_brain.nii"

echo "=== Done ==="
echo "Outputs in $OUT:"
echo "  T1w_brain.nii           - skull-stripped brain"
echo "  T1w_brain_mask.nii      - binary brain mask"
echo "  T1w_fast_seg.nii        - tissue labels (1=CSF, 2=GM, 3=WM)"
echo "  T1w_fast_pve_{0,1,2}.nii - partial volume estimates"
echo "  T1w_fast_restore.nii    - bias-corrected T1"
