#!/usr/bin/env bash
set -e
_SCRIPT_DIR=$( cd -- "$( dirname -- "${BASH_SOURCE[0]}" )" &> /dev/null && pwd )

TIGER_BASE_URL="https://www2.census.gov/geo/tiger/TIGER2023"
TIGER_COUNTY_URL="${TIGER_BASE_URL}/COUNTY/tl_2023_us_county.zip"
TIGER_STATE_URL="${TIGER_BASE_URL}/STATE/tl_2023_us_state.zip"
TIGER_OUTDIR="${_SCRIPT_DIR}/tiger"

mkdir -p "${TIGER_OUTDIR}/county"
mkdir -p "${TIGER_OUTDIR}/state"
wget -O "${TIGER_OUTDIR}/tl_2023_us_county.zip" "${TIGER_COUNTY_URL}"
wget -O "${TIGER_OUTDIR}/tl_2023_us_state.zip" "${TIGER_STATE_URL}"
unzip "${TIGER_OUTDIR}/tl_2023_us_county.zip" -d "${TIGER_OUTDIR}/county"
unzip "${TIGER_OUTDIR}/tl_2023_us_state.zip" -d "${TIGER_OUTDIR}/state"

