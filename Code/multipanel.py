import rasterio
import os
import glob
import matplotlib.pyplot as plt
import numpy as np

# Arguments
data_dir = r'D:\Projects\REI-WaveExp\Data\hg\v1.1\spline_hrdps_clipped'
os.chdir(data_dir)
pattern = 'mx_spd*.tif'
variable = 'Max Wind Speed'
plot_name = 'mx_spd_hg'

fnames = glob.glob(pattern)
order = ['360', '45', '90', '135', '180', '225', '270', '315']
ordered_paths = []

raster_paths = [os.path.join(data_dir, fname) for fname in fnames]
bins = [os.path.basename(p.split('_spline')[0]).split('_')[-1] for p in raster_paths]
r_dict = dict(zip(bins, raster_paths))
for i in order:
    ordered_paths.append(r_dict.get(i))

rasters = []
nodata = np.nan

for path in ordered_paths:
    with rasterio.open(path) as src:
        nodata = src.nodata
        rasters.append(src.read(1))  # Read the first band

rasters = [np.where(r == nodata, np.nan, r) for r in rasters]

# Create a colormap that ignores NaN values
cmap = plt.cm.viridis  # You can change the colormap as needed
cmap.set_bad('none', 1.0)

fig, axes = plt.subplots(2, 4, figsize=(12, 6))  # 2 rows, 4 columns for 8 panels

for i, ax in enumerate(axes.flat):
    ax.imshow(rasters[i], cmap=cmap)  # You can change the colormap as needed
    ax.set_title(f"{variable} {order[i]}")

plt.tight_layout()
plt.savefig(f'{plot_name}.png')
