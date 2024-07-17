# SPEI

library(tibble)
coords <- tribble(
  ~place,  ~lon,         ~lat,
  "JGCRI",    -76.92238, 38.97160,
  "Thompson", -97.84862, 55.74706,
  "Fes",      -5.01007,  34.03614,
  "Lima",     -77.03086, -12.04545
)
coords$ID <- seq_len(nrow(coords))


# Documentation: https://spei.csic.es/database.html
# Data downloaded 2024-07-17

# These data are provided as netCDF files (http://en.wikipedia.org/wiki/NetCDF)
# Happily, the terra package can handle these!
# (There's also the `ncdf4` package for many other applications)
library(terra)
spei <- rast("spei_data/spei01.nc")
# Note that we've told Git to IGNORE these data files; see ".gitignore" file

# Confirm that things look good -- it's a spatial raster object,
# global half degree resolution, from January 1901 to December 2022
print(spei)

# Extract our points of interest. terra::extract() will handle making sure
# the coordinates get mapped to the correct grid cell(s) in the data
spei_coords <- terra::extract(spei, coords[2:3])
# 1465 columns! Why? Because that's 122 years * 12 months + "ID" column

# Reshape data into a more manageable form
library(tidyr)
spei_monthly <- pivot_longer(spei_coords, -ID)
spei_monthly <- separate(spei_monthly, name, into = c("spei", "entry"), convert = TRUE)
# The SPEI data don't seem to provide 'time' explicitly in the netcdf, so
# compute it from the entries
spei_monthly$year <- ceiling(spei_monthly$entry / 12) + 1900
spei_monthly$month <- (spei_monthly$entry - 1) %% 12 + 1
spei_monthly$time <- with(spei_monthly, year + (month-1) / 12)
spei_monthly <- dplyr::left_join(spei_monthly, coords, by = "ID")

# Not sure about the best way to plot this
p <- ggplot(spei_monthly, aes(time, value, color = place)) +
  geom_point(size = 0.25) + geom_smooth()
print(p)
