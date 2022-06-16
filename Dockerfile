FROM r-base
COPY . /usr/local/src/myscripts
WORKDIR /usr/local/src/myscripts
RUN R -e "install.packages('simmer',dependencies=TRUE, repos='http://cran.rstudio.com/')"
RUN R -e "install.packages('simmer.plot',dependencies=TRUE, repos='http://cran.rstudio.com/')"
CMD ["Rscript", "main.R"]