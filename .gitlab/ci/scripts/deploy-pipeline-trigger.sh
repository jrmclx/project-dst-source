#!/bin/sh

# curl -v -X POST \
#      --fail \
#      -F token=glptt-qDzBT-QHsP_B5z26_sSx \
#      -F "ref=dev" \
#      -F "variables[UPDATED_TAG]=fc7f1054" \
#      -F "variables[UPDATED_IMAGENAME]=frontend" \
#      https://gitlab.com/api/v4/projects/77089053/trigger/pipeline

curl -v -X POST \
     --fail \
     --form "token=glptt-qDzBT-QHsP_B5z26_sSx" \
     --form "ref=dev" \
     --form "variables[UPDATED_IMAGENAME]=frontend" \
     --form "variables[UPDATED_TAG]=adc48abe" \
     --url "https://gitlab.com/api/v4/projects/77089053/trigger/pipeline"


# curl \
#   --header "PRIVATE-TOKEN: glpat-lelE-fW4Kns28vo3CCs1qm86MQp1OmhpaDNuCw.01.120y5zubh" \
#   --url "https://gitlab.com/api/v4/projects/77089053/pipelines/2229025020/"