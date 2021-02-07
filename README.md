# prolific-api
Reverse-engineering prolific's undocumented REST API in R

## Lesson 00: Payload requests to `eligibility-count/`
 - URI: `https://www.prolific.co/api/v1/eligibility-count/`
 - Payload required: `{"study_type": "SINGLE", ... }`
 
 `jsonlite::toJSON()` will generate a payload of `{"study_type": ["SINGLE"], ... }`. Patch this with something like `str_replace(json.new, fixed('[\"SINGLE\"]'), '\"SINGLE\"')`! :grimacing:

