# Appsilon-Vessel
## Connor Putnam
<!-- badges: start -->
<!-- badges: end -->

The goal of this project is to map vessel location and produce an interactive map where the user can choose which vessel they would like to track.

The code is split into six main files under the the `.R` file named `app.R`. The data needed for this project can be found in the folder labeled `Data`. There are two `.csv` files attached to this repository, `.ship.csv` and `ship_small.csv`. `ship_small.csv` is a random sample from the much larger `ship.csv` dataset. this was done because of load limits when deploying to www.shinyapps.io.

When trying out the app take a look at the `Cargo` ship `CALISTO` it moved quite a bit!

**Link to Shiny App:** https://putnamco.shinyapps.io/Ship/?_ga=2.163565119.2066894291.1612458979-305948469.1611594786

The packages needed to run this repo are as follows:

  * `tidyverse`
  * `shiny`
  * `shiny.semantic`
  * `geosphere`
  * `lubridate`
  * `shinythemes`
  * `semantic.dashboard`
  * `shinyWidgets`
  * `leaflet`
  