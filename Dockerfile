FROM rocker/shiny:latest

# Installation des packages R nécessaires
RUN R -e "install.packages(c('shiny', 'readxl', 'dplyr'), repos='https://cloud.r-project.org')"

# Supprimer l'application exemple de Shiny Server
RUN rm -rf /srv/shiny-server/*

# Copier l'application
COPY app/ /srv/shiny-server/

# Donner les permissions nécessaires
RUN chown -R shiny:shiny /srv/shiny-server

# Port utilisé par Shiny Server
EXPOSE 3838

# Lancer Shiny Server
CMD ["/usr/bin/shiny-server"]
