#' Run the ER injury explorer Shiny app
#'
#' Launches the Shiny application bundled with this package.
#'
#' @return No return value. This function is called for its side effect of
#'   starting a Shiny app.
#' @export
run_app <- function() {
  app_dir <- system.file("app", package = "ErInjuryExplorer")

  if (app_dir == "") {
    stop("Could not find the Shiny app directory.", call. = FALSE)
  }

  shiny::runApp(app_dir, display.mode = "normal")
}
