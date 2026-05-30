# This unexported helper keeps runtime app dependencies visible to R CMD check.
.package_imports <- function() {
  list(
    DT::datatable,
    dplyr::filter,
    forcats::fct_reorder,
    ggplot2::ggplot,
    rlang::sym,
    shiny::runApp,
    stringr::str_detect,
    tibble::tibble,
    vroom::vroom
  )
}
