# WorldClim data

library(tibble)
coords <- tribble(
  ~place,  ~lon,         ~lat,
  "JGCRI",    -76.92238, 38.97160,
  "Thompson", -97.84862, 55.74706,
  "Fes",      -5.01007,  34.03614,
  "Lima",     -77.03086, -12.04545
)
coords$ID <- seq_len(nrow(coords))

# These data are available online but R's geodata package will download
# for us -- handy!

library(geodata)
# geodata::worldclim_global is smart enough to *cache* the data--
# it will only download if the data don't exist at the path we give it
tavg <- worldclim_global("tavg", "10", "worldclim_data/")
# Note that we've told Git to IGNORE these data files; see ".gitignore" file

# The resulting object is a spatial raster object. See ?SpatRaster
dim(tavg)
print(tavg)
plot(tavg)

# Extract our points of interest. terra::extract() will handle making sure
# the coordinates get mapped to the correct grid cell(s) in the data
library(terra)
tavg_coords <- terra::extract(tavg, coords[2:3])

# The result is a data frame with one row per coordinate and
# one column per month
class(tavg_coords)
dim(tavg_coords)
# If I want the monthly data, I would probably *reshape* these data
# In this case, let's compute MAT (mean annual temperature)
coords$MAT <- rowMeans(tavg_coords[-1]) # Why "-1"?

# Look at seasonal cycle
library(tidyr)
monthly <- pivot_longer(tavg_coords, -ID)
# Extract month number from 'name'
monthly$month <- as.numeric(gsub("wc2.1_10m_tavg_", "", monthly$name))
# ...and join with coords to get the name of each place
monthly <- dplyr::left_join(monthly, coords)

library(ggplot2)
p <- ggplot(monthly, aes(month, value, color = place)) +
  geom_line() +
  ylab("Air temperature") + ggtitle("Climatology")
print(p)

