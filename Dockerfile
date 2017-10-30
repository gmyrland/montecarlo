#########################
## Monte Carlo Dockerfile
#########################
#
# This file can be used to serve the Monte Carlo shiny app from a docker container.
# CAUTION: The Monte Carlo app exposes a full R session to the user. Use with care.
#
# To Build:
#   docker build -t montecarlo .
#
# To Launch:
#   docker run --rm -p 3838:3838 --name montecarlo \
#      -v `pwd`:/srv/shiny-server/:ro \
#      montecarlo
#
# You can then access the app on port 3838. Adjust as necessary.
# Also see rocker/shiny documentation at https://github.com/rocker-org/shiny.
#

FROM rocker/shiny
LABEL maintainer="Glen Myrland <glenmyrland@gmail.com>"

# Install packages
RUN apt-get update -y \
    && apt-get install -y libssl-dev libsasl2-dev

# Dependencies for pdf reporting
RUN apt-get update -y \
    && apt-get install -y texlive texlive-latex-extra

# Install required R packages
RUN Rscript -e 'update.packages(ask=FALSE)' \
            -e 'install.packages("dplyr")' \
            -e 'install.packages("shiny")' \
            -e 'install.packages("yaml")' \
            -e 'install.packages("rmarkdown")' \
            -e 'install.packages("jsonlite")' \
            -e 'install.packages("DT")' \
            -e 'install.packages("ggplot2")' \
            -e 'install.packages("knitr")' \
        && rm -rf /tmp/downloaded_packages

# For convenience and viewing logs
RUN apt-get install -y vim
