#!/usr/bin/env bash
set -e
_SCRIPT_DIR=$( cd -- "$( dirname -- "${BASH_SOURCE[0]}" )" &> /dev/null && pwd )
TIGER_VRT="${_SCRIPT_DIR}/tiger/tiger.vrt"
TIGER_GPKG="${_SCRIPT_DIR}/tiger.gpkg"
rm "${TIGER_GPKG}"
envsubst < "${TIGER_VRT}" | \
    ogr2ogr -f GPKG \
        "${TIGER_GPKG}" \
        /vsistdin/ \
        -progress \
        -nlt PROMOTE_TO_MULTI \
        -makevalid \
        
