# install.packages("googleCloudRunner")

library(googleCloudRunner)
# cr_setup()


b1 <- cr_build("cloudbuild.yaml")

b2 <- cr_build("cloudbuild.yaml", launch_browser = FALSE)
b3 <- cr_build_wait(b2)