library(shiny)
library(dplyr)
library(forcats)
library(ggplot2)
library(stringr)
library(tibble)
library(vroom)
library(DT)

load_injuries <- function() {
  data_dir <- file.path(tempdir(), "neiss")
  data_file <- file.path(data_dir, "injuries.tsv.gz")

  if (!file.exists(data_file)) {
    dir.create(data_dir, showWarnings = FALSE, recursive = TRUE)
    download.file(
      "https://github.com/hadley/mastering-shiny/raw/main/neiss/injuries.tsv.gz",
      data_file,
      mode = "wb",
      quiet = TRUE
    )
  }

  vroom::vroom(data_file, show_col_types = FALSE, progress = FALSE)
}

injuries <- load_injuries()

top_counts <- function(data, variable, n = 12) {
  data |>
    count({{ variable }}, wt = weight, name = "estimated_injuries") |>
    arrange(desc(estimated_injuries)) |>
    slice_head(n = n)
}

summary_plot <- function(data, variable, x_label) {
  top_counts(data, {{ variable }}) |>
    mutate({{ variable }} := forcats::fct_reorder({{ variable }}, estimated_injuries)) |>
    ggplot(aes(x = estimated_injuries, y = {{ variable }})) +
    geom_col(fill = "#2C7FB8") +
    labs(x = "Estimated national injuries", y = x_label) +
    theme_minimal(base_size = 13)
}

ui <- fluidPage(
  titlePanel("Emergency Room Injury Explorer"),

  sidebarLayout(
    sidebarPanel(
      helpText("Explore the NEISS injuries data from Chapter 4 of Mastering Shiny."),
      selectInput(
        "summary_var",
        "Variable to summarize",
        choices = c(
          "Sex" = "sex",
          "Race" = "race",
          "Body part" = "body_part",
          "Diagnosis" = "diag",
          "Injury location" = "location"
        ),
        selected = "body_part"
      ),
      sliderInput(
        "age_range",
        "Age range",
        min = floor(min(injuries$age, na.rm = TRUE)),
        max = ceiling(max(injuries$age, na.rm = TRUE)),
        value = c(0, 100),
        step = 1
      )
    ),

    mainPanel(
      tabsetPanel(
        tabPanel(
          "Summaries",
          h3("Graphical summary"),
          plotOutput("summary_plot", height = 420),
          h3("Numerical summary"),
          DTOutput("summary_table")
        ),
        tabPanel(
          "Narratives by Body Part",
          fluidRow(
            column(
              5,
              selectInput(
                "body_part",
                "Choose body part",
                choices = sort(unique(injuries$body_part)),
                selected = "Head"
              )
            ),
            column(
              7,
              textInput("narrative_search", "Search narratives", value = "")
            )
          ),
          DTOutput("narrative_table")
        ),
        tabPanel(
          "Product Codes",
          h3("Most common product codes"),
          plotOutput("product_plot", height = 420),
          DTOutput("product_table")
        )
      )
    )
  )
)

server <- function(input, output, session) {
  age_filtered <- reactive({
    injuries |>
      filter(
        !is.na(age),
        age >= input$age_range[1],
        age <= input$age_range[2]
      )
  })

  summary_data <- reactive({
    variable <- rlang::sym(input$summary_var)

    age_filtered() |>
      count(!!variable, wt = weight, name = "estimated_injuries") |>
      arrange(desc(estimated_injuries)) |>
      slice_head(n = 12) |>
      rename(category = !!variable)
  })

  output$summary_plot <- renderPlot({
    summary_data() |>
      mutate(category = forcats::fct_reorder(category, estimated_injuries)) |>
      ggplot(aes(x = estimated_injuries, y = category)) +
      geom_col(fill = "#2C7FB8") +
      labs(x = "Estimated national injuries", y = NULL) +
      theme_minimal(base_size = 13)
  })

  output$summary_table <- renderDT({
    summary_data() |>
      mutate(estimated_injuries = round(estimated_injuries)) |>
      datatable(
        rownames = FALSE,
        options = list(pageLength = 12),
        colnames = c("Category", "Estimated injuries")
      )
  })

  narrative_data <- reactive({
    selected <- age_filtered() |>
      filter(body_part == input$body_part) |>
      select(trmt_date, age, sex, race, diag, location, narrative)

    search_term <- str_squish(input$narrative_search)
    if (search_term != "") {
      selected <- selected |>
        filter(str_detect(str_to_lower(narrative), fixed(str_to_lower(search_term))))
    }

    selected |>
      arrange(desc(trmt_date))
  })

  output$narrative_table <- renderDT({
    datatable(
      narrative_data(),
      rownames = FALSE,
      filter = "top",
      options = list(pageLength = 10, scrollX = TRUE)
    )
  })

  product_data <- reactive({
    age_filtered() |>
      count(prod_code, wt = weight, name = "estimated_injuries") |>
      arrange(desc(estimated_injuries)) |>
      slice_head(n = 15)
  })

  output$product_plot <- renderPlot({
    product_data() |>
      mutate(prod_code = fct_reorder(as.factor(prod_code), estimated_injuries)) |>
      ggplot(aes(x = estimated_injuries, y = prod_code)) +
      geom_col(fill = "#41AB5D") +
      labs(x = "Estimated national injuries", y = "Product code") +
      theme_minimal(base_size = 13)
  })

  output$product_table <- renderDT({
    product_data() |>
      mutate(estimated_injuries = round(estimated_injuries)) |>
      datatable(
        rownames = FALSE,
        options = list(pageLength = 15),
        colnames = c("Product code", "Estimated injuries")
      )
  })
}

shinyApp(ui, server)
