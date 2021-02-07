# Lessons in reverse-engineering the Prolific.co undocumented API
# Lucas Reddinger <jlr@lucasreddinger.com>

rm(list=ls())

library("httr")
library("jsonlite")
library("stringr")

# You need to supply a valid authentication hash
# Log into Prolific and capture an AJAX request
myAuthHash = "d96f63887a554e429292e7ff9c3a4eb2"

fileName <- "nationality_us.request.json"
json.good <- readChar(fileName, file.info(fileName)$size)

r1 <- POST("https://www.prolific.co/api/v1/eligibility-count/", 
          add_headers(authorization = paste("Bearer", myAuthHash)), 
          content_type_json(), body = json.good)
fromJSON(rawToChar(r1$content))$count
# [1] 36037

# This works as expected, returning a count of 36037 participants with US nationality.

# Can we convert our JSON to R objects, then convert the R objects back to JSON,
# while obtaining the same expected result? Let's try it.

data <- fromJSON(json.good)

json.new <- toJSON(data)

r2 <- POST("https://www.prolific.co/api/v1/eligibility-count/", 
          add_headers(authorization = paste("Bearer", myAuthHash)), 
          content_type_json(), body = json.new)

fromJSON(rawToChar(r2$content))$count
# NULL

# No. We do not obtain the same result. What is the difference between json.good
# and json.new? The difference is that {"study_type":"SINGLE", ...
# has now become {"study_type":["SINGLE"], ...
# and Prolific's API is sensitive to this. So let's make Prolific's API happy.

json.new <- toJSON(data)

json.new <- str_replace(json.new, fixed('[\"SINGLE\"]'), '\"SINGLE\"')

r3 <- POST("https://www.prolific.co/api/v1/eligibility-count/", 
          add_headers(authorization = paste("Bearer", myAuthHash)), 
          content_type_json(), body = json.new)

fromJSON(rawToChar(r3$content))$count
# [1] 36037

# Now we obtain the expected result.
