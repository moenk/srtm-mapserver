#
# file: srtm30.R
#
# coder: moenkemt@geo.hu-berlin.de
#
# purpose: download and prepare srtm30 as WCS in MapServer
#


# list of tiles to download
srtm=c("e020n40","e020n90","e020s10","e060n40","e060n90","e060s10",
      "e100n40","e100n90","e100s10","e140n40","e140n90","e140s10",
      "w020n40","w020n90","w020s10","w060n40","w060n90","w060s10",
      "w100n40","w100n90","w100s10","w140n40","w140n90","w140s10",
      "w180n40","w180n90","w180s10");

# let's go!
setwd("~/srtm")
for (tile in srtm) {

  # combine download url
  t_url="";
  t_url[1]=paste("http://dds.cr.usgs.gov/srtm/version2_1/SRTM30/",tile,"/",tile,".dmw.zip",sep="")
  t_url[2]=paste("http://dds.cr.usgs.gov/srtm/version2_1/SRTM30/",tile,"/",tile,".dem.zip",sep="")
  t_url[3]=paste("http://dds.cr.usgs.gov/srtm/version2_1/SRTM30/",tile,"/",tile,".hdr.zip",sep="")
  t_url[4]=paste("http://dds.cr.usgs.gov/srtm/version2_1/SRTM30/",tile,"/",tile,".prj.zip",sep="")

  # comine tile filename
  t_name="";
  t_name[1]=paste(tile,".dmw.zip",sep="");
  t_name[2]=paste(tile,".dem.zip",sep="");
  t_name[3]=paste(tile,".hdr.zip",sep="");
  t_name[4]=paste(tile,".prj.zip",sep="");

  # download and unzip srtm tiles
  for (n in 1:4) {
    system(paste("wget",t_url[n],"-O",t_name[n],sep=" "));
    system(paste('unzip',t_name[n],sep=" "));
    system(paste('rm',t_name[n],sep=" "));
  }

  # load DEM
  dem=raster(paste(toupper(tile),"DEM",sep="."))
  extent(dem)
  
  # write tile file
  t_file=paste(tile,"tif",sep=".");
  writeRaster(dem,t_file,overwrite=TRUE);
  
  # add pyramid levels
  system(paste("gdaladdo","-r average",t_file,"2 4 8 16 32 64 128",sep=" "))
}

# create tile index shape for mapserver
system("gdaltindex srtm30.shp *.tif")

# clean up
system("rm *.DEM *.DMW *.HDR *.PRJ")

# and done.
