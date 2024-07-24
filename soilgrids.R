# Soilgrids data - https://soilgrids.org

# This is more complicated

library(tibble)
coords <- tribble(
  ~place,  ~lon,         ~lat,
  "JGCRI",    -76.92238, 38.97160,
  "Thompson", -97.84862, 55.74706,
  "Fes",      -5.01007,  34.03614,
  "Lima",     -77.03086, -12.04545
)
coords$ID <- seq_len(nrow(coords))


# ---------------------------------------------------------
# Step 1 - download desired and use gdal to make a geoTIFF
# See https://gdal.org/index.html

# If needed, install gdal using Homebrew: "brew install gdal"

# download clay 15-30 cm and SOC 0-30 cm
# gdal_translate -of GTiff -co "TILED=YES" -co "COMPRESS=DEFLATE" -co "PREDICTOR=2" -co "BIGTIFF=YES" "/vsicurl?max_retry=3&retry_delay=1&list_dir=no&url=https://files.isric.org/soilgrids/latest/data/clay/clay_15-30cm_mean.vrt" "clay_15-30cm_mean.tif"
# gdal_translate -of GTiff -co "TILED=YES" -co "COMPRESS=DEFLATE" -co "PREDICTOR=2" -co "BIGTIFF=YES" "/vsicurl?max_retry=3&retry_delay=1&list_dir=no&url=https://files.isric.org/soilgrids/latest/data//ocs/ocs_0-30cm_mean.vrt" "ocs_0-30cm_mean.tif"

# Available data are here:
# https://files.isric.org/soilgrids/latest/data/

# The resulting global geoTIFF files are large: ~2 GB each for the 250m data

# ---------------------------------------------------------
# Step 2: extract in R

# This uses the older raster package
# I have not yet rewritten this for terra and sp
library(raster)
ocs <- raster("./soilgrids_data/ocs_0-30cm_mean.tif")
x_points <- SpatialPoints(coords[2:3],
                          proj4string = CRS("+proj=longlat +datum=WGS84"))
x_points <- spTransform(x_points, projection(ocs))
print(extract(ocs, x_points, buffer = 1000, fun = mean))

# This returns NA for Lima -- not sure why
