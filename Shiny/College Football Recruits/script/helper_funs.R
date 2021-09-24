# Load packages
library(gt)



# Function to create stars for gt table
# This function comes from Thomas Mock's article: https://themockup.blog/posts/2020-10-31-embedding-custom-features-in-gt-tables/

rating_stars <- function(rating, max_rating = 5) {
  rounded_rating <- floor(rating + 0.5)  # always round up
  
  stars <- lapply(seq_len(max_rating), function(i) {
    if (i <= rounded_rating) fontawesome::fa("star", fill= 'orange') else fontawesome::fa("star", fill= "grey")
  })
  
  label <- sprintf("%s out of %s", rating, max_rating)
  
  div_out <- div(title = label, "aria-label" = label, role = "img", stars)
  
  as.character(div_out) %>%
    gt::html()
}