# ErInjuryExplorer

ErInjuryExplorer is an R package containing a Shiny application for exploring
the National Electronic Injury Surveillance System (NEISS) emergency-room injury
data used in Chapter 4 of *Mastering Shiny*.

The app includes:

- a summary tab for demographics and injury variables;
- a narrative tab where users select a `body_part` and inspect all related
  patient narratives;
- an extra product-code tab for exploring common product codes associated with
  injuries.

## Installation

repository owner:

```r
install.packages("devtools")
devtools::install_github("ChenguangYang96UCR/stat209_hw4")
```

## Usage

Load the package and start the Shiny app:

```r
library(ErInjuryExplorer)
run_app()
```

On first launch, the app downloads `injuries.tsv.gz` from Hadley Wickham's
Mastering Shiny GitHub repository and stores it in a temporary cache for the R
session.

## Data Source

The data come from the NEISS extract used in *Mastering Shiny*, Chapter 4:

<https://mastering-shiny.org/basic-case-study.html>

The raw file is downloaded from:

<https://github.com/hadley/mastering-shiny/raw/main/neiss/injuries.tsv.gz>
