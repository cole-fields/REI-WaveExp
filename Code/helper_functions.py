import pyproj


def convert_coordinates(x, y, in_epsg, out_epsg):
    """
    Converts coordinates from one projection to another using EPSG codes.

    Args:
        x (float): The x-coordinate of the point to be converted.
        y (float): The y-coordinate of the point to be converted.
        in_epsg (int): The EPSG code of the input projection.
        out_epsg (int): The EPSG code of the output projection.

    Returns:
        A tuple containing the converted x and y coordinates.
    >>> convert_coordinates(1021928.428003, 398050.489959, 3005, 4326)
    (-125.703253, 48.598047)
    >>> convert_coordinates(1096050.279809, 471118.188193, 3005, 4326)   
    (-124.68193, 49.248361)
    """
    in_proj = pyproj.CRS.from_epsg(in_epsg)
    out_proj = pyproj.CRS.from_epsg(out_epsg)
    transformer = pyproj.Transformer.from_crs(in_proj, out_proj, always_xy=True)
    lon, lat = transformer.transform(x, y)
    return round(lon, 6), round(lat, 6)


def get_bounding_box_str(sw_coords, ne_coords):
    """
    Creates a string representing a bounding box given southwest and northeast coordinates.

    Arguments:
        - sw_coords (tuple): A tuple of x, y representing southwest coordinates.
        - ne_coords (tuple): A tuple of x, y representing northeast coordinates.

    Returns:
        A string in the format 'lon1,lon2,lat1,lat2', where lon1 is the westernmost longitude,
        lon2 is the easternmost longitude, lat1 is the southernmost latitude, and lat2 is the
        northernmost latitude.

    Note:
        The function will account for the y values being on a +-180 scale and will convert them
        into a 0 to 360 scale.
    >>> get_bounding_box_str((-125.703253, 48.598047), (-124.68193, 49.248361))
    '234.296747,235.31807,48.598047,49.248361'
    """
    lon1 = sw_coords[0]
    lon2 = ne_coords[0]
    lat1 = sw_coords[1]
    lat2 = ne_coords[1]
    if lon1 < 0:
        lon1 += 360
    if lon2 < 0:
        lon2 += 360
    if lon1 > lon2:
        lon1, lon2 = lon2, lon1
        lat1, lat2 = lat2, lat1
    return f"{round(lon1, 6)},{round(lon2, 6)},{round(lat1, 6)},{round(lat2, 6)}"
