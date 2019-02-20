

setwd("directory with ag county shapefiles")

library('rgdal')

years <- c(1850, 1890, 1930, 1959)

for (y in 1:length(years)){
	# Import shapefile with county polygons
	counties2012 <- readOGR(dsn = "2012_WIag.shp", layer = "2012_WIag")
	dsn <- paste0(years[y],"_WIag.shp")
	layer <- paste0(years[y],"_WIag")
	oldcounties <- readOGR(dsn=dsn,layer=layer)
	# Import intersect table
	intersect_table <- read.csv(paste0("intersect",years[y],"_2012.csv"),as.is=T,check.names=F,header=T) # Note: generated intersect_table in ArcMap using "Tabulate Intersection". The county shapefile from the older time period needs to be first (zone features to be intersected by class features).

	# Loop through each county, and create a vector of ag variable values adjusted to match 2012 counties
	adjusted_oldcounty<- matrix(NA,nrow=nrow(counties2012@data),ncol=ncol(oldcounties@data))
	colnames(adjusted_oldcounty) <- colnames(oldcounties@data)
	ag_pos <- grep("corn",colnames(oldcounties@data)) #get first column with ag variables (differs among county shapefiles)
	for (i in 1:nrow(counties2012@data)){
		STCTY <- as.character(counties2012@data$STCTY[i]) #get STCTY of 2012 county
		proportions <- intersect_table[which(intersect_table[,3]==STCTY),5] / 100 #get proportions of old counties that share area with 2012 county
		old_contributors <- intersect_table[which(intersect_table[,3]==STCTY),2] #get STCTY values of old counties contributing production values to 2012 county
	
		for (j in 1:ncol(oldcounties@data)){ #populate adjusted_oldcounty with adjusted values of each variable for this county
			if (j>(ag_pos-1)){
				old_values <- apply(array(old_contributors),1,function(x){oldcounties@data[which(as.character(oldcounties@data$STCTY)==x),j]}) #get old production values
				adjusted_oldcounty[i,j] <- sum(old_values*proportions) #get productio value for 2012 county by summing the area-weighted values from the old counties
			
			} else {
				if (length(which(as.character(oldcounties@data$STCTY)==STCTY))>0){
					adjusted_oldcounty[i,j] <- as.character(oldcounties@data[which(as.character(oldcounties@data$STCTY)==STCTY),j]) #enter values of variables that come before the ag variables
				} else {temp<-c}
			}
		}
	}

	# Ensure numbers are understood as numbers in shapefile
	adjusted_oldcounty_2 <- array(as.numeric(adjusted_oldcounty[,ag_pos])) #create vector of values for 1st ag variable
	for (k in (ag_pos+1):ncol(adjusted_oldcounty)){ #cbind vectors of ag variables after forcing them to be numeric
		adjusted_oldcounty_2 <- cbind(adjusted_oldcounty_2,as.numeric(adjusted_oldcounty[,k]))
	}
	counties2012@data <- data.frame(adjusted_oldcounty[,1:ag_pos-1],adjusted_oldcounty_2,stringsAsFactors=F)
	colnames(counties2012@data) <- colnames(adjusted_oldcounty)

	# Write new county shapefile
	dsn2 <- paste0("adjusted",dsn)
	layer2 <- paste0("adjusted",layer)
	writeOGR(counties2012,dsn=dsn2,layer=layer2,driver="ESRI Shapefile",overwrite=T)
}




