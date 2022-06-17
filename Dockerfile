FROM r-base
VOLUME . /usr/src/app
WORKDIR /usr/src/app
RUN R -e "install.packages('simmer', dependencies=TRUE, repos='http://cran.rstudio.com/')"
CMD ["Rscript", "main.R"]