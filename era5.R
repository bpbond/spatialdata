# ERA5 data

# This example will be very similar to the SPEI one

library(tibble)
coords <- tribble(
  ~place,  ~lon,         ~lat,
  "JGCRI",    -76.92238, 38.97160,
  "Thompson", -97.84862, 55.74706,
  "Fes",      -5.01007,  34.03614,
  "Lima",     -77.03086, -12.04545
)
coords$ID <- seq_len(nrow(coords))

# https://cds.climate.copernicus.eu/cdsapp#!/dataset/reanalysis-era5-land-monthly-means?tab=overview
# Data downloaded 2024-07-17

# These data are provided as GRIB files (https://en.wikipedia.org/wiki/GRIB)
# Happily, the terra package can handle these!
library(terra)
era5 <- rast("era5_data/adaptor.mars.internal-1721213296.76056-28229-7-77f05425-fcb9-4bef-b7a7-f778ba8d88b6.grib")
# Note that we've told Git to IGNORE these data files; see ".gitignore" file

# Confirm that things look good -- it's a spatial raster object,
# global half degree resolution, from January 1901 to December 2022
print(era5)

# Extract our points of interest. terra::extract() will handle making sure
# the coordinates get mapped to the correct grid cell(s) in the data
era5_coords <- terra::extract(era5, coords[2:3])
# 12 columns, Jan-Dec, because I only downloaded one year (2013) of data

# Reshape data into a more manageable form
library(tidyr)
era5_monthly <- pivot_longer(era5_coords, -ID)
era5_monthly$month <- rep(1:12, times = nrow(coords))
era5_monthly <- dplyr::left_join(era5_monthly, coords, by = "ID")

# The GRIB file says that temperatures are in degrees C, but online
# documentation says it's K, which is clearly right

library(ggplot2)
p <- ggplot(era5_monthly, aes(month, value - 273.1, color = place)) +
  geom_line() + ggtitle("2013")
print(p)
