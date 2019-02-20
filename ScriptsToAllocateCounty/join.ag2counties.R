
setwd("directory with historical county shapefiles")

library('rgdal')


# 1850

# Import shapefile with county polygons
    # Note: first, in ArcMap, add fields for STCTY and AREA
        # STCTY is the concatenation of the ICPSR state and county codes, separated by a "_"
        # AREA is the total county area in US acres (use Calculate Geometry tool availabe from attribute table)
counties <- readOGR(dsn = "Historic_counties/US_county_1850_conflated.shp", layer = "US_county_1850_conflated")
ag_path <- "directory with agricultural census files"
ag <- read.csv(paste0(ag_path,"1850_STCTY.csv"),as.is=T,check.names=F,header=T)
ag2 <- merge(x=counties@data,y=ag,by="STCTY",all.x=T,sort=F)

# Calculate area-weighted ag variables
# Farms
n_farm <- ag2$FARMS / ag2$AREA_A
area_farm <- (ag2$ACIMP + ag2$ACUNIMP) / ag2$AREA_A
# Livestock
horse1 <- apply(cbind(ag2$HORSES,ag2$MULES),1,function(x){sum(x,na.rm=T)})
horse <- horse1 / ag2$AREA_A
cattle1 <- apply(cbind(ag2$COWS,ag2$OTCATTLE),1,function(x){sum(x,na.rm=T)})
cattle <- cattle1 / ag2$AREA_A
swine <- ag2$SWINE / ag2$AREA_A
sheep <- ag2$SHEEP / ag2$AREA_A
oxen <- ag2$OXEN / ag2$AREA_A
# Crops
corn <- ag2$CORN
wheat <- ag2$WHEAT
oat <- ag2$OATS
barley <- ag2$BARLEY
rye <- ag2$RYE
hay <- ag2$HAY
potato <- ag2$IRPOTATO
tobacco <- ag2$TOBACCO
rice <- ag2$RICE
cotton <- ag2$COTTON

# Add crop variables
crops <- c("corn","wheat","oat","barley","rye","potato","tobacco","rice","cotton","hay")
crops_list <- list(corn,wheat,oat,barley,rye,potato,tobacco,rice,cotton,hay)
for (i in 1:length(crops)){
  yield <- read.csv(paste0("C:/Users/Michael/Desktop/IGERT/Novelty in WI/NASS yield data/NASS_yields_",crops[i],".csv"),as.is=T,check.names=F)
  crop_unit_acre <- yield[,2]
  if (crops[i]=="potato"){
    crop_unit_acre <- crop_unit_acre * 10/6
  } else if (crops[i]=="cotton"){ #1860 and later, cotton is given in # of bales (bale = 400 lbs)
    crop_unit_acre <- crop_unit_acre * 400
  } else {temp=c()}
  if (crops[i]!="rice"){
    crop_yield <- sum(as.numeric(crop_unit_acre[grep(1900,yield[,1]):grep(1866,yield[,1])]) / length(grep(1900,yield[,1]):grep(1866,yield[,1])))
  } else {
    crop_yield <- sum(as.numeric(crop_unit_acre[grep(1900,yield[,1]):grep(1895,yield[,1])]) / length(grep(1900,yield[,1]):grep(1895,yield[,1])))
  }
  prop_crop <- (crops_list[[i]] / crop_yield) / ag2$AREA_A
  add_crop <- matrix(NA,ncol=1,nrow=nrow(counties@data))
  colnames(add_crop) <- crops[i]
  for (j in 1:nrow(counties@data)){
    if (length(which(ag2$STCTY==counties@data$STCTY[j]))>0){
      add_crop[j,1] <- prop_crop[which(ag2$STCTY==counties@data$STCTY[j])]
    } else {temp<-c()}
  }
  counties@data <- cbind(counties@data,add_crop)
}

# Add livestock variables
livestock <- c("horse","cattle","swine","sheep","oxen")
livestock_list <- list(horse,cattle,swine,sheep,oxen)
for (i in 1:length(livestock)){
  add_livestock <- matrix(NA,ncol=1,nrow=nrow(counties@data))
  colnames(add_livestock) <- livestock[i]
  for (j in 1:nrow(counties@data)){
    if (length(which(ag2$STCTY==counties@data$STCTY[j]))>0){
      add_livestock[j,1] <- livestock_list[[i]][which(ag2$STCTY==counties@data$STCTY[j])]
    } else {temp<-c()}
  }
  counties@data <- cbind(counties@data,add_livestock)
}

# Add farm variables
farms <- c("n_farm","area_farm")
farms_list <- list(n_farm,area_farm)
for (i in 1:length(farm_list)){
  add_farm <- matrix(NA,ncol=1,nrow=nrow(counties@data))
  colnames(add_farm) <- farms[i]
  for (j in 1:nrow(counties@data)){
    if (length(which(ag2$STCTY==counties@data$STCTY[j]))>0){
      add_farm[j,1] <- farms_list[[i]][which(ag2$STCTY==counties@data$STCTY[j])]
    } else {temp<-c()}
  }
  counties@data <- cbind(counties@data,add_farm)
}

# Write new county shapefile
writeOGR(counties,dsn="Historic_counties/US_county_1850_ag.shp",layer="US_county_1850_ag",driver="ESRI Shapefile",overwrite=T)


# 1890

counties <- readOGR(dsn = "Historic_counties/US_county_1890_conflated.shp", layer = "US_county_1890_conflated")
ag <- read.csv(paste0(ag_path,"1890_STCTY.csv"),as.is=T,check.names=F,header=T)
ag2 <- merge(x=counties@data,y=ag,by="STCTY",all.x=T,sort=F)

# Calculate area-weighted ag variables
# Farms
n_farm <- ag2$FARMS / ag2$AREA_A
area_farm <- (ag2$ACIMP + ag2$ACUNIMP) / ag2$AREA_A
irrigated <- ag2$IRRAC / ag2$AREA_A
# Livestock
horse1 <- apply(cbind(ag2$HORSES,ag2$MULES,ag2$ASSES),1,function(x){sum(x,na.rm=T)})
horse <- horse1 / ag2$AREA_A
cattle <- ag2$CATTLE / ag2$AREA_A
swine <- ag2$SWINE / ag2$AREA_A
sheep <- ag2$SHEEP / ag2$AREA_A
oxen <- ag2$OXEN / ag2$AREA_A
chicken <- ag2$CHICKENS / ag2$AREA_A
turkey <- ag2$TURKEYS / ag2$AREA_A
# Crops
corn <- ag2$CORNAC / ag2$AREA_A
wheat <- ag2$WHEATAC / ag2$AREA_A
oat <- ag2$OATSAC / ag2$AREA_A
barley <- ag2$BARLEYAC / ag2$AREA_A
rye <- ag2$RYEAC / ag2$AREA_A
hay <- ag2$HAYAC / ag2$AREA_A
potato <- ag2$IPOTATAC / ag2$AREA_A
tobacco <- ag2$TOBACAC / ag2$AREA_A
rice <- ag2$RICEAC / ag2$AREA_A
cotton <- ag2$COTTONAC / ag2$AREA_A
sorghum <- ag2$SSUGARAC / ag2$AREA_A
alfalfa <- ag2$ALFALFAC / ag2$AREA_A

# Add crop variables
crops <- c("corn","wheat","oat","barley","rye","potato","tobacco","rice","cotton","hay","sorghum","alfalfa")
crops_list <- list(corn,wheat,oat,barley,rye,potato,tobacco,rice,cotton,hay,sorghum,alfalfa)
for (i in 1:length(crops)){
  add_crop <- matrix(NA,ncol=1,nrow=nrow(counties@data))
  colnames(add_crop) <- crops[i]
  for (j in 1:nrow(counties@data)){
    if (length(which(ag2$STCTY==counties@data$STCTY[j]))>0){
      add_crop[j,1] <- crops_list[[i]][which(ag2$STCTY==counties@data$STCTY[j])]
    } else {temp<-c()}
  }
  counties@data <- cbind(counties@data,add_crop)
}

# Add livestock variables
livestock <- c("horse","cattle","swine","sheep","oxen","chicken","turkey")
livestock_list <- list(horse,cattle,swine,sheep,oxen,chicken,turkey)
for (i in 1:length(livestock)){
  add_livestock <- matrix(NA,ncol=1,nrow=nrow(counties@data))
  colnames(add_livestock) <- livestock[i]
  for (j in 1:nrow(counties@data)){
    if (length(which(ag2$STCTY==counties@data$STCTY[j]))>0){
      add_livestock[j,1] <- livestock_list[[i]][which(ag2$STCTY==counties@data$STCTY[j])]
    } else {temp<-c()}
  }
  counties@data <- cbind(counties@data,add_livestock)
}

# Add farm variables
farms <- c("n_farm","area_farm","irrigated")
farms_list <- list(n_farm,area_farm,irrigated)
for (i in 1:length(farm_list)){
  add_farm <- matrix(NA,ncol=1,nrow=nrow(counties@data))
  colnames(add_farm) <- farms[i]
  for (j in 1:nrow(counties@data)){
    if (length(which(ag2$STCTY==counties@data$STCTY[j]))>0){
      add_farm[j,1] <- farms_list[[i]][which(ag2$STCTY==counties@data$STCTY[j])]
    } else {temp<-c()}
  }
  counties@data <- cbind(counties@data,add_farm)
}

# Write new county shapefile
writeOGR(counties,dsn="Historic_counties/US_county_1890_ag.shp",layer="US_county_1890_ag",driver="ESRI Shapefile",overwrite=T)



# 1930

counties <- readOGR(dsn = "Historic_counties/US_county_1930_conflated.shp", layer = "US_county_1930_conflated")
ag <- read.csv(paste0(ag_path,"1930_1_STCTY.csv"),as.is=T,check.names=F,header=T)
ag2 <- merge(x=counties@data,y=ag,by="STCTY",all.x=T,sort=F)
ag3 <- read.csv(paste0(ag_path,"1930_2_STCTY.csv"),as.is=T,check.names=F,header=T)
ag4  <- merge(x=counties@data,y=ag3,by="STCTY",all.x=T,sort=F)

# Calculate area-weighted ag variables
# Farms
n_farm <- ag2$var2 / ag2$AREA_A
area_farm <- ag2$var8 / ag2$AREA_A
irrigated <- ag4$var1509 / ag2$AREA_A
area_crop <- ag2$var12 / ag2$AREA_A
area_pasture <- ag2$var16 / ag2$AREA_A
# Livestock
horse1 <- apply(cbind(ag2$var172,ag2$var182),1,function(x){sum(x,na.rm=T)})
horse <- horse1 / ag2$AREA_A
cattle <- ag2$var192 / ag2$AREA_A
swine <- ag2$var221 / ag2$AREA_A
sheep <- ag2$var889 / ag2$AREA_A
chicken <- ag2$var222 / ag2$AREA_A
turkey <- ag2$var907 / ag2$AREA_A
# Crops
corn <- ag2$var235 / ag2$AREA_A
wheat <- ag2$var245 / ag2$AREA_A
oat <- ag2$var256 / ag2$AREA_A
barley <- ag2$var261 / ag2$AREA_A
rye <- ag2$var264 / ag2$AREA_A
hay <- ag2$var276 / ag2$AREA_A
potato <- ag2$var321 / ag2$AREA_A
tobacco <- ag2$var318 / ag2$AREA_A
rice <- ag2$var273 / ag2$AREA_A
cotton <- ag2$var305 / ag2$AREA_A
sorghum1 <- apply(cbind(ag2$var315,ag2$var502,ag2$var505),1,function(x){sum(x,na.rm=T)})
sorghum <- sorghum1 / ag2$AREA_A
alfalfa1 <- apply(cbind(ag2$var287,ag2$var556),1,function(x){sum(x,na.rm=T)})
alflafa <- alfalfa1 / ag2$AREA_A
soybean1 <- apply(cbind(ag2$var486,ag2$var487),1,function(x){sum(x,na.rm=T)})
soybean <- soybean1 / ag2$AREA_A

# Add crop variables
crops <- c("corn","wheat","oat","barley","rye","potato","tobacco","rice","cotton","hay","sorghum","alfalfa","soybean")
crops_list <- list(corn,wheat,oat,barley,rye,potato,tobacco,rice,cotton,hay,sorghum,alfalfa,soybean)
for (i in 1:length(crops)){
  add_crop <- matrix(NA,ncol=1,nrow=nrow(counties@data))
  colnames(add_crop) <- crops[i]
  for (j in 1:nrow(counties@data)){
    if (length(which(ag2$STCTY==counties@data$STCTY[j]))>0){
      add_crop[j,1] <- crops_list[[i]][which(ag2$STCTY==counties@data$STCTY[j])]
    } else {temp<-c()}
  }
  counties@data <- cbind(counties@data,add_crop)
}

# Add livestock variables
livestock <- c("horse","cattle","swine","sheep","chicken","turkey")
livestock_list <- list(horse,cattle,swine,sheep,chicken,otpoultry)
for (i in 1:length(livestock)){
  add_livestock <- matrix(NA,ncol=1,nrow=nrow(counties@data))
  colnames(add_livestock) <- livestock[i]
  for (j in 1:nrow(counties@data)){
    if (length(which(ag2$STCTY==counties@data$STCTY[j]))>0){
      add_livestock[j,1] <- livestock_list[[i]][which(ag2$STCTY==counties@data$STCTY[j])]
    } else {temp<-c()}
  }
  counties@data <- cbind(counties@data,add_livestock)
}

# Add farm variables
farms <- c("n_farm","area_farm","irrigated","area_crop","area_pasture")
farms_list <- list(n_farm,area_farm,irrigated,area_crop,area_pasture)
for (i in 1:length(farms_list)){
  add_farm <- matrix(NA,ncol=1,nrow=nrow(counties@data))
  colnames(add_farm) <- farms[i]
  for (j in 1:nrow(counties@data)){
    if (length(which(ag2$STCTY==counties@data$STCTY[j]))>0){
      add_farm[j,1] <- farms_list[[i]][which(ag2$STCTY==counties@data$STCTY[j])]
    } else {temp<-c()}
  }
  counties@data <- cbind(counties@data,add_farm)
}

writeOGR(counties,dsn="Historic_counties/US_county_1930_ag.shp",layer="US_county_1930_ag",driver="ESRI Shapefile",overwrite=T)


# 1959

counties <- readOGR(dsn = "Historic_counties/US_county_1960_conflated.shp", layer = "US_county_1960_conflated")
ag <- read.csv(paste0(ag_path,"1959_1_STCTY.csv"),as.is=T,check.names=F,header=T)
ag2 <- merge(x=counties@data,y=ag,by="STCTY",all.x=T,sort=F)

# Calculate area-weighted ag variables
# Farms
n_farm <- ag2$var1 / ag2$AREA_A
area_farm <- ag2$var5 / ag2$AREA_A
irrigated <-ag2$var54  / ag2$AREA_A
area_crop <- ag2$var11 / ag2$AREA_A
area_pasture1 <- apply(cbind(ag2$var22,ag2$var38,ag2$var42,ag2$var44),1,function(x){sum(x,na.rm=T)})
area_pasture <- area_pasture1 / ag2$AREA_A
# Livestock
horse <- ag2$var747 / ag2$AREA_A
cattle1 <- apply(cbind(ag2$var716,ag2$var720),1,function(x){sum(x,na.rm=T)}) #cattle and milk cows seem to be separate
cattle <- cattle1 / ag2$AREA_A
swine <- ag2$var749 / ag2$AREA_A
sheep <- ag2$var759 / ag2$AREA_A
chicken <- ag2$var772 / ag2$AREA_A
#turkey <- ag2$var853 / ag2$AREA_A
# Crops
corn <- ag2$var875 / ag2$AREA_A
wheat <- ag2$var915 / ag2$AREA_A
oat <- ag2$var965 / ag2$AREA_A
barley <- ag2$var980 / ag2$AREA_A
rye <- ag2$var992 / ag2$AREA_A
hay <- ag2$var1151 / ag2$AREA_A #"land from which hay was cut"
potato <- ag2$var1333 / ag2$AREA_A
tobacco <- ag2$var1378 / ag2$AREA_A
rice <- ag2$var1030 / ag2$AREA_A
cotton <- ag2$var1350 / ag2$AREA_A
sorghum <- ag2$var893 / ag2$AREA_A
alfalfa1 <- apply(cbind(ag2$var1231,ag2$var1153),1,function(x){sum(x,na.rm=T)})
alflafa <- alfalfa1 / ag2$AREA_A
soybean <- ag2$var1056 / ag2$AREA_A

# Add crop variables
crops <- c("corn","wheat","oat","barley","rye","potato","tobacco","rice","cotton","hay","sorghum","alfalfa","soybean")
crops_list <- list(corn,wheat,oat,barley,rye,potato,tobacco,rice,cotton,hay,sorghum,alfalfa,soybean)
for (i in 1:length(crops)){
  add_crop <- matrix(NA,ncol=1,nrow=nrow(counties@data))
  colnames(add_crop) <- crops[i]
  for (j in 1:nrow(counties@data)){
    if (length(which(ag2$STCTY==counties@data$STCTY[j]))>0){
      add_crop[j,1] <- crops_list[[i]][which(ag2$STCTY==counties@data$STCTY[j])]
    } else {temp<-c()}
  }
  counties@data <- cbind(counties@data,add_crop)
}

# Add livestock variables
livestock <- c("horse","cattle","swine","sheep","chicken")
livestock_list <- list(horse,cattle,swine,sheep,chicken)
for (i in 1:length(livestock)){
  add_livestock <- matrix(NA,ncol=1,nrow=nrow(counties@data))
  colnames(add_livestock) <- livestock[i]
  for (j in 1:nrow(counties@data)){
    if (length(which(ag2$STCTY==counties@data$STCTY[j]))>0){
      add_livestock[j,1] <- livestock_list[[i]][which(ag2$STCTY==counties@data$STCTY[j])]
    } else {temp<-c()}
  }
  counties@data <- cbind(counties@data,add_livestock)
}

# Add farm variables
farms <- c("n_farm","area_farm","irrigated","area_crop","area_pasture")
farms_list <- list(n_farm,area_farm,irrigated,area_crop,area_pasture)
for (i in 1:length(farms_list)){
  add_farm <- matrix(NA,ncol=1,nrow=nrow(counties@data))
  colnames(add_farm) <- farms[i]
  for (j in 1:nrow(counties@data)){
    if (length(which(ag2$STCTY==counties@data$STCTY[j]))>0){
      add_farm[j,1] <- farms_list[[i]][which(ag2$STCTY==counties@data$STCTY[j])]
    } else {temp<-c()}
  }
  counties@data <- cbind(counties@data,add_farm)
}

writeOGR(counties,dsn="Historic_counties/US_county_1959_ag.shp",layer="US_county_1959_ag",driver="ESRI Shapefile",overwrite=T)


# 2012

# Import shapefile with county polygons
counties <- readOGR(dsn = "Historic_counties/US_county_2012.shp", layer = "US_county_2012")

# Note: 2012 shapefile lacks the ICPSR state and county codes, so we need to join using the GISJOIN field with an older county shapefile
# The 2000 shapefile has been altered in ArcMap to include a STCTY field
# Note: G1301570 was 1510, but should be 1570 (change made to shapefile on 4/19/2017)
# also issues with 32_1330,32_1350, 32_1370
counties2000 <- readOGR(dsn = "Historic_counties/US_county_2000_conflated.shp", layer = "US_county_2000_conflated")

# Create vectors with STCTY and GISJOIN
add1 <- matrix(NA,ncol=2,nrow=nrow(counties@data))
colnames(add1) <- c(colnames(counties2000@data[20]),"GISJOINED")
for (i in 1:nrow(counties@data)){
	if (length(which(as.character(counties2000@data$GISJOIN)==as.character(counties@data[i,20])))>0){
		add1[i,1] <- as.character(counties2000@data[which(as.character(counties2000@data$GISJOIN)==as.character(counties@data[i,20])),20])
		add1[i,2] <- as.character(counties2000@data[which(as.character(counties2000@data$GISJOIN)==as.character(counties@data[i,20])),12])
	} else {temp<-c()}
}

# Add fields to 2012 county shapefile
counties@data <- cbind(counties@data,add1)

# Import Ag Census data
ag_path <- "C:/Users/Michael/Desktop/IGERT/Novelty in WI/AgCensusData/"
ag <- read.csv(paste0(ag_path,"2012_STCTY.csv"),as.is=T,check.names=F,header=T)
ag2 <- merge(x=counties@data,y=ag,by="STCTY",all.x=T,sort=F)

# Calculate area-weighted ag variables
# Farms
n_farm <- ag2$DATA1_1 / ag2$AREA_A
area_farm <- ag2$DATA1_2 / ag2$AREA_A
irrigated <-ag2$DATA1_20  / ag2$AREA_A
area_crop <- ag2$DATA1_16 / ag2$AREA_A
area_pasture <- ag2$DATA8_124 / ag2$AREA_A #pastureland, all types
# Livestock
horse <- ag2$DATA18_2 / ag2$AREA_A
cattle <- ag2$DATA11_3 / ag2$AREA_A #also had categories for milk cows and beef cows
swine <- ag2$DATA12_3 / ag2$AREA_A
sheep <- ag2$DATA13_3 / ag2$AREA_A
chicken1 <- apply(cbind(ag2$DATA1_60,ag2$DATA1_62),1,function(x){sum(x,na.rm=T)}) #layers, and broilers/meat-type
chicken <- chicken1 / ag2$AREA_A
turkey <- ag2$DATA19_26 / ag2$AREA_A
# Crops
corn1 <- apply(cbind(ag2$DATA24_17,ag2$DATA24_28),1,function(x){sum(x,na.rm=T)})
corn <- corn1 / ag2$AREA_A #for grain and seed
wheat <- ag2$DATA24_185 / ag2$AREA_A #for grain
oat <- ag2$DATA24_72 / ag2$AREA_A #for grain
barley <- ag2$DATA24_6 / ag2$AREA_A #for grain
rye <- ag2$DATA25_225 / ag2$AREA_A #for grain
hay <- ag2$DATA1_112 / ag2$AREA_A
potato <- ag2$DATA29_242 / ag2$AREA_A
tobacco <- ag2$DATA24_169 / ag2$AREA_A
rice <- ag2$DATA24_103 / ag2$AREA_A
cotton <- ag2$DATA24_39 / ag2$AREA_A
sorghum1 <- apply(cbind(ag2$DATA1_88,ag2$DATA1_91),1,function(x){sum(x,na.rm=T)})
sorghum <- sorghum1 / ag2$AREA_A
alfalfa1 <- apply(cbind(ag2$DATA26_21,ag2$DATA26_22),1,function(x){sum(x,na.rm=T)})
alfalfa <- alfalfa1 / ag2$AREA_A
soybean <- ag2$DATA1_94 / ag2$AREA_A #for beans

# Add crop variables
crops <- c("corn","wheat","oat","barley","rye","potato","tobacco","rice","cotton","hay","sorghum","alfalfa","soybean")
crops_list <- list(corn,wheat,oat,barley,rye,potato,tobacco,rice,cotton,hay,sorghum,alfalfa,soybean)
for (i in 1:length(crops)){
  add_crop <- matrix(NA,ncol=1,nrow=nrow(counties@data))
  colnames(add_crop) <- crops[i]
  for (j in 1:nrow(counties@data)){
    if (length(which(ag2$STCTY==counties@data$STCTY[j]))>0){
      add_crop[j,1] <- crops_list[[i]][which(ag2$STCTY==counties@data$STCTY[j])]
    } else {temp<-c()}
  }
  counties@data <- cbind(counties@data,add_crop)
}

# Add livestock variables
livestock <- c("horse","cattle","swine","sheep","chicken","turkey")
livestock_list <- list(horse,cattle,swine,sheep,chicken,turkey)
for (i in 1:length(livestock)){
  add_livestock <- matrix(NA,ncol=1,nrow=nrow(counties@data))
  colnames(add_livestock) <- livestock[i]
  for (j in 1:nrow(counties@data)){
    if (length(which(ag2$STCTY==counties@data$STCTY[j]))>0){
      add_livestock[j,1] <- livestock_list[[i]][which(ag2$STCTY==counties@data$STCTY[j])]
    } else {temp<-c()}
  }
  counties@data <- cbind(counties@data,add_livestock)
}

# Add farm variables
farms <- c("n_farm","area_farm","irrigated","area_crop","area_pasture")
farms_list <- list(n_farm,area_farm,irrigated,area_crop,area_pasture)
for (i in 1:length(farms_list)){
  add_farm <- matrix(NA,ncol=1,nrow=nrow(counties@data))
  colnames(add_farm) <- farms[i]
  for (j in 1:nrow(counties@data)){
    if (length(which(ag2$STCTY==counties@data$STCTY[j]))>0){
      add_farm[j,1] <- farms_list[[i]][which(ag2$STCTY==counties@data$STCTY[j])]
    } else {temp<-c()}
  }
  counties@data <- cbind(counties@data,add_farm)
}

writeOGR(counties,dsn="Historic_counties/US_county_2012_ag.shp",layer="US_county_2012_ag",driver="ESRI Shapefile",overwrite=T)

