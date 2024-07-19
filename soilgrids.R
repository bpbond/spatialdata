# Soilgrids data - https://soilgrids.org

# This is more complicated

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
clay <- raster("./soilgrids_data/clay_15-30cm_mean.tif")
x_points <- SpatialPoints(coords[2:3],
                          proj4string = CRS("+proj=longlat +datum=WGS84"))
x_points <- spTransform(x_points, projection(clay))
extract(clay, x_points, buffer = 1000, fun = mean)
