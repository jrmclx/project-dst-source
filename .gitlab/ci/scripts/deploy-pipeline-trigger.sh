#!/bin/sh

# curl -v -X POST \
#      --fail \
#      -F token=glptt-qDzBT-QHsP_B5z26_sSx \
#      -F "ref=dev" \
#      -F "variables[TAG]=fc7f1054" \
#      -F "variables[IMAGENAME]=frontend" \
#      https://gitlab.com/api/v4/projects/77089053/trigger/pipeline

curl -v -X POST \
     --fail \
     -F token=glptt-qDzBT-QHsP_B5z26_sSx \
     -F "ref=dev" \
     https://gitlab.com/api/v4/projects/77089053/trigger/pipeline
