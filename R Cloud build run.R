# install.packages("googleCloudRunner")

library(googleCloudRunner)
# cr_setup()

# cr_bucket_set("watchful-ripple-320400")
# cr_region_set("us-east1")

# b1 <- cr_build("cloudbuild.yaml")
# 
# 
# 
# b2 <- cr_build("cloudbuild.yaml", launch_browser = FALSE)
# b3 <- cr_build_wait(b2)

cr_deploy_r("RBA Data v2.R")