library(shiny)
library(readxl)
library(dplyr)

# Lire le fichier Excel
data <- read_excel(
  "C:/Users/ugpst/Documents/OTHER FILES/dossier stagiaire2/essai Render/data -- act urg 2 -- stat depot.xlsx",
  range = "B3:E13",
  col_names = TRUE
)

# Renommer les colonnes
names(data) <- c("nom", "montant", "date", "type_paiement")

# Supprimer les lignes inutiles
data <- data[data$nom != "Solde Initial" & !is.na(data$nom), ]

# Transformer le montant en nombre
data$montant <- as.numeric(data$montant)

# Nettoyer les dates
date_texte <- trimws(as.character(data$date))
date_texte <- gsub(",", "", date_texte)
date_texte <- trimws(date_texte)

data$date <- sapply(date_texte, function(x) {
  
  if (grepl("^[0-9]+$", x)) {
    return(as.character(as.Date(
      as.numeric(x),
      origin = "1899-12-30"
    )))
  }
  
  if (grepl("^[0-9]{1,2}/[0-9]{1,2}/[0-9]{4}$", x)) {
    return(as.character(as.Date(
      x,
      format = "%d/%m/%Y"
    )))
  }
  
  if (grepl("^[0-9]{1,2}/[0-9]{1,2}/[0-9]{2}$", x)) {
    return(as.character(as.Date(
      x,
      format = "%d/%m/%y"
    )))
  }
  
  return(NA_character_)
})

data$date <- as.Date(data$date)

# Interface
ui <- fluidPage(
  
  titlePanel("Analyse de la collecte de versements"),
  
  h3("Données collectées"),
  
  tableOutput("tableau"),
  
  h3("Statistiques par type de paiement"),
  
  tableOutput("statistiques"),
  
  h3("Montant des versements"),
  
  plotOutput("graphique_montant"),
  
  h3("Nombre de versements"),
  
  plotOutput("graphique_effectif")
)

# Serveur
server <- function(input, output, session) {
  
  output$tableau <- renderTable({
    data
  })
  
  output$statistiques <- renderTable({
    
    do.call(rbind, lapply(
      split(data$montant, data$type_paiement),
      function(x) {
        data.frame(
          Type_paiement = unique(data$type_paiement[
            data$montant %in% x
          ])[1],
          Montant = sum(x),
          Effectif = length(x),
          Maximum = max(x),
          Minimum = min(x)
        )
      }
    ))
    
  })
  
  output$graphique_montant <- renderPlot({
    
    statistiques <- data %>%
      group_by(type_paiement) %>%
      summarise(Montant = sum(montant))
    
    barplot(
      statistiques$Montant,
      names.arg = statistiques$type_paiement,
      main = "Montant des versements selon le type de paiement",
      xlab = "Type de paiement",
      ylab = "Montant"
    )
  })
  
  output$graphique_effectif <- renderPlot({
    
    statistiques <- data %>%
      group_by(type_paiement) %>%
      summarise(Effectif = n())
    
    barplot(
      statistiques$Effectif,
      names.arg = statistiques$type_paiement,
      main = "Nombre de versements selon le type de paiement",
      xlab = "Type de paiement",
      ylab = "Nombre de versements"
    )
  })
}

shinyApp(ui = ui, server = server)