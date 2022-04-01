##################
## FRONT MATTER ##
##################

## Load required libraries
library(VIM)
library(gtools)
library(zoo)
library(haven)

## Set to your working directory
setwd("D:/AHRF/")

## Load AHRF - update file paths as needed
arf2018 <- readRDS("AHRF2018-2019/arf2018-2019.RDS")
arf2017 <- readRDS("AHRF2017-2018/arf2017-2018.RDS")
arf2016 <- readRDS("AHRF2016-2017/arf2016-2017.RDS")
arf2015 <- readRDS("AHRF2015-2016/DATA/arf2015-2016.RDS")
arf2014 <- readRDS("AHRF2014-2015/DATA/arf2014-2015.RDS")
arf2013 <- readRDS("AHRF2013-2014/DATA/arf2013-2014.RDS")
arf2012 <- readRDS("AHRF2012-2013/DATA/arf2012-2013.RDS")
arf2011 <- readRDS("AHRF2011-2012/arf2011-2012.RDS")
arf2009 <- readRDS("AHRF2009/arf2009-2010.RDS")
arf2008 <- readRDS("AHRF2008/arf2008-2009.RDS")
arf2007 <- readRDS("AHRF2007/arf2007-2008.RDS")
arf2006 <- readRDS("AHRF2006/arf2006-2007.RDS")

####################
## PREP AHRF DATA ##
####################

## List fields to keep
keep <- c(
	"f00002", # FIPS Code
	"f04437", # County + State abbreviation
	"f12424", # State name abbreviation
	"f00010", # County name
	"f09721", # Land area 
	"f00020", # Rurality code
	"f14587", # % employment in manufacturing
	"f09787", # HPSA code
	"f04530", # 2010 Census population
	"f08921", # Hospital Beds
	"f13214", # home health agencies
	"f13220", # Hospices
	"f11984", # population estimate
	"f15549", # total medicare enrollment, later years
	"f13254", # total medicare enrollment, early years
	"f13906", # Total males
	"f13907", # Total females
	"f13920", # Total hispanic males
	"f13921", # Total hispanic females
	"f13915", # Asian females
	"f13914", # Asian males
	"f13910", # Black males
	"f13911", # Black females
	"f13326", # Census asian pop
	"f04536", # Census hisp pop
	"f04532", # Census black pop
	"f13483", # Median age
	"f06712", # Pop male 20-24
	"f06713", # Pop female 20-24
	"f06714", # Pop male 25-29
	"f06715", # Pop female 25-29
	"f06716", # Pop male 30-34
	"f06717", # Pop female 30-34
	"f06718", # Pop male 35-44
	"f06719", # Pop female 35-44
	"f06720", # Pop male 45-54
	"f06721", # Pop female 45-54
	"f06722", # Pop male 55-59
	"f06723", # Pop female 55-59
	"f06724", # Pop male 60-64
	"f06725", # Pop female 60-64
	"f06726", # Pop male 65-74
	"f06727", # Pop female 65-74
	"f11640", # Pop male 75-84
	"f11641", # Pop female 75-84
	"f11642", # Pop male >84
	"f11643", # Pop female >84
	"f14642", # NPs with NPI
	"f14482", # % aged 25+ w/ 4+ years college
	"f09781", # per capita income
	"f13321", # % in poverty
	"f06795", # % unemployed
	"f11396", # Veteran population
	"f12558", # Total deaths
	"f14751", # % <65 w/o health insurance, pre-2014
	"f15474", # % <65 w/o health insurance, 2014+
	"f13226", # Median household income
	"f15297", # Actual per capita Medicare cost
	"f13874", # Total area in square miles
	"f12424", # State name abbreviation
	"f04538", # % Black
	"f04542", # % Hispanic
	"f14206", # Dual eligible
	"f04904", # Total MDs <35
	"f04905", # Total MDs 35-44
	"f04906", # Total MDs 45-54
	"f04907", # Total MDs 55-64
	"f12016", # Total MDs 65-74
	"f12017", # Total MDs 75+
	"f04916", # Total Specs <35
	"f04917", # Total Specs 35-44
	"f04918", # Total Specs 45-54
	"f04919", # Total Specs 55-64
	"f12034", # Total Specs 65-74
	"f12035", # Total Specs 75+
	"f04820", # Total MDs male
	"f04821", # Total MDs female
	"f10498", # Dentists <35
	"f11318", # Dentists 35-44
	"f11319", # Dentists 45-54
	"f13176", # Dentists 55-64
	"f10505", # Dentists 65+
	"f08922", # Short-term general hospital beds
	"f08923", # Long-term non-general hospital beds
	"f08924", # Long-term hospital beds
	"f14045", # Nursing home beds
	"f13191", # Eligible for Medicare
	"f13908", # White males
	"f13909", # White females
	"f09545", # Total inpatient days (all hospitals + nursing homes)
	"f09566", # OP visits ST gen hosps
	"f09567", # OP visits ST non-gen hosps
	"f09568", # OP visits LT hosps
	"f09571"  # OP visits VA hosps
)

## Subset only relevant variables
arf2018.sub <- arf2018[,substr(names(arf2018),1,6) %in% keep]
arf2017.sub <- arf2017[,substr(names(arf2017),1,6) %in% keep]
arf2016.sub <- arf2016[,substr(names(arf2016),1,6) %in% keep]
arf2015.sub <- arf2015[,substr(names(arf2015),1,6) %in% keep]
arf2014.sub <- arf2014[,substr(names(arf2014),1,6) %in% keep]
arf2013.sub <- arf2013[,substr(names(arf2013),1,6) %in% keep]
arf2012.sub <- arf2012[,substr(names(arf2012),1,6) %in% keep]
arf2011.sub <- arf2011[,substr(names(arf2011),1,6) %in% keep]
arf2009.sub <- arf2009[,substr(names(arf2009),1,6) %in% keep]
arf2008.sub <- arf2008[,substr(names(arf2008),1,6) %in% keep]
arf2007.sub <- arf2007[,substr(names(arf2007),1,6) %in% keep]
arf2006.sub <- arf2006[,substr(names(arf2006),1,6) %in% keep]

## Adjust FIPS codes to match in all years
arf2013.sub$f00002[nchar(arf2013.sub$f00002)<5] <- paste("0", arf2013.sub$f00002[nchar(arf2013.sub$f00002)<5], sep="")
arf2012.sub$f00002[nchar(arf2012.sub$f00002)<5] <- paste("0", arf2012.sub$f00002[nchar(arf2012.sub$f00002)<5], sep="")
arf2011.sub$f00002[nchar(arf2011.sub$f00002)<5] <- paste("0", arf2011.sub$f00002[nchar(arf2011.sub$f00002)<5], sep="")
arf2009.sub$f00002[nchar(arf2009.sub$f00002)<5] <- paste("0", arf2009.sub$f00002[nchar(arf2009.sub$f00002)<5], sep="")
arf2008.sub$f00002[nchar(arf2008.sub$f00002)<5] <- paste("0", arf2008.sub$f00002[nchar(arf2008.sub$f00002)<5], sep="")
arf2006.sub$f00002[nchar(arf2006.sub$f00002)<5] <- paste("0", arf2006.sub$f00002[nchar(arf2006.sub$f00002)<5], sep="") # 2007 is OK 

## Merge years
comb <- merge(arf2018.sub, arf2017.sub, by="f00002")
comb <- merge(comb, arf2016.sub, by="f00002")
comb <- merge(comb, arf2015.sub, by="f00002")
comb <- merge(comb, arf2014.sub, by="f00002")
comb <- merge(comb, arf2013.sub, by="f00002")
comb <- merge(comb, arf2012.sub, by="f00002")
comb <- merge(comb, arf2011.sub, by="f00002")
comb <- merge(comb, arf2009.sub, by="f00002")
comb <- merge(comb, arf2008.sub, by="f00002")
comb <- merge(comb, arf2007.sub, by="f00002")
comb <- merge(comb, arf2006.sub, by="f00002")

## Remove duplicated years
names(comb) <- gsub(".x", "", names(comb))
names(comb) <- gsub(".y", "", names(comb))
comb <- comb[, !duplicated(names(comb))]

## County name to upper case
comb$f04437 <- toupper(comb$f04437)

## Subset years
keep18 <- comb[,names(comb) %in% c("f00002","f04437","f0002013","f00010","f12424","f0453010","f0453810","f0454210") | substr(names(comb),7,8)=="18"]
keep17 <- comb[,names(comb) %in% c("f00002","f04437","f0002013","f00010","f12424","f0453010","f0453810","f0454210") | substr(names(comb),7,8)=="17"]
keep16 <- comb[,names(comb) %in% c("f00002","f04437","f0002013","f00010","f12424","f0453010","f0453810","f0454210") | substr(names(comb),7,8)=="16"]
keep15 <- comb[,names(comb) %in% c("f00002","f04437","f0002013","f00010","f12424","f0453010","f0453810","f0454210") | substr(names(comb),7,8)=="15"]
keep14 <- comb[,names(comb) %in% c("f00002","f04437","f0002013","f00010","f12424","f0453010","f0453810","f0454210") | substr(names(comb),7,8)=="14"]
keep13 <- comb[,names(comb) %in% c("f00002","f04437","f0002013","f00010","f12424","f0453010","f0453810","f0454210") | substr(names(comb),7,8)=="13"]
keep12 <- comb[,names(comb) %in% c("f00002","f04437","f0002013","f00010","f12424","f0453010","f0453810","f0454210") | substr(names(comb),7,8)=="12"]
keep11 <- comb[,names(comb) %in% c("f00002","f04437","f0002003","f00010","f12424","f0453010","f0453810","f0454210") | substr(names(comb),7,8)=="11"]
keep10 <- comb[,names(comb) %in% c("f00002","f04437","f0002003","f00010","f12424","f0453010","f0453810","f0454210") | substr(names(comb),7,8)=="10"]
keep09 <- comb[,names(comb) %in% c("f00002","f04437","f0002003","f00010","f12424","f0453010","f0453810","f0454210") | substr(names(comb),7,8)=="09"]
keep08 <- comb[,names(comb) %in% c("f00002","f04437","f0002003","f00010","f12424","f0453010","f0453810","f0454210") | substr(names(comb),7,8)=="08"]
keep07 <- comb[,names(comb) %in% c("f00002","f04437","f0002003","f00010","f12424","f0453010","f0453810","f0454210") | substr(names(comb),7,8)=="07"]
keep06 <- comb[,names(comb) %in% c("f00002","f04437","f0002003","f00010","f12424","f0453010","f0453810","f0454210") | substr(names(comb),7,8)=="06"]

## Assign years
keep17$yr <- 2018
keep17$yr <- 2017
keep16$yr <- 2016
keep15$yr <- 2015
keep14$yr <- 2014
keep13$yr <- 2013
keep12$yr <- 2012
keep11$yr <- 2011
keep10$yr <- 2010
keep09$yr <- 2009
keep08$yr <- 2008
keep07$yr <- 2007
keep06$yr <- 2006

## Drop year indicators in variable names
names(keep18) <- substr(names(keep18), 1, 6)
names(keep17) <- substr(names(keep17), 1, 6)
names(keep16) <- substr(names(keep16), 1, 6)
names(keep15) <- substr(names(keep15), 1, 6)
names(keep14) <- substr(names(keep14), 1, 6)
names(keep13) <- substr(names(keep13), 1, 6)
names(keep12) <- substr(names(keep12), 1, 6)
names(keep11) <- substr(names(keep11), 1, 6)
names(keep10) <- substr(names(keep10), 1, 6)
names(keep09) <- substr(names(keep09), 1, 6)
names(keep08) <- substr(names(keep08), 1, 6)
names(keep07) <- substr(names(keep07), 1, 6)
names(keep06) <- substr(names(keep06), 1, 6)

## Fix names for some census vars in 2010
keep10$f11984 <- keep10$f04530
names(keep10)[names(keep10)=="f13326"] <- "n_asian"
names(keep10)[names(keep10)=="f04536"] <- "n_hisp"
names(keep10)[names(keep10)=="f04532"] <- "n_black"
names(keep10)[names(keep10)=="f04539"] <- "n_indian"

## Smart bind, filling missing with NA
ahrf <- smartbind(keep18,keep17, keep16, keep15, keep14, keep13, keep12, keep11, keep10, keep09, keep08, keep07, keep06)

## Fix variables that change name
ahrf$f15549[is.na(ahrf$f15549)] <- ahrf$f13254[is.na(ahrf$f15549)]
ahrf$f15474[is.na(ahrf$f15474)] <- ahrf$f14751[is.na(ahrf$f15474)]
ahrf <- ahrf[,!(names(ahrf) %in% c("f13254","f14751"))] 

## Sum gendered race vars
ahrf$n_asian[is.na(ahrf$n_asian)] <- ahrf$f13914[is.na(ahrf$n_asian)]+ahrf$f13915[is.na(ahrf$n_asian)]
ahrf$n_hisp[is.na(ahrf$n_hisp)] <- ahrf$f13920[is.na(ahrf$n_hisp)]+ahrf$f13921[is.na(ahrf$n_hisp)]
ahrf$n_black[is.na(ahrf$n_black)] <- ahrf$f13911[is.na(ahrf$n_black)]+ahrf$f13910[is.na(ahrf$n_black)]
ahrf$n_indian[is.na(ahrf$n_indian)] <- ahrf$f13912[is.na(ahrf$n_indian)]+ahrf$f13913[is.na(ahrf$n_indian)]

## Order by county, year
ahrf <- ahrf[order(ahrf$f00002, ahrf$yr, decreasing=FALSE),]

## For census and other time-invariant variables, fill missing
census <- c("f06712","f06713","f06714","f06715","f06716","f06717",
	'f06718','f06719','f06720','f06721','f06721','f06722','f06723','f06724',
	'f06725','f06726','f06727','f11640','f11641','f11642','f11643','f13483',
	'f13483','f09721','f00020','f09787',"f00010")
for(i in unique(ahrf$f00002)){
	tmp <- ahrf[ahrf$f00002 == i,names(ahrf) %in% census]
	tmp <- na.locf(tmp, na.rm=FALSE)
	tmp <- na.locf(tmp, fromLast=TRUE, na.rm=FALSE)
	ahrf[ahrf$f00002 == i,names(ahrf) %in% census] <- tmp
}

## Interpolate the remaining missing
for(i in unique(ahrf$f00002)){
	tmp <- ahrf[ahrf$f00002 == i,]
	for(j in 1:ncol(tmp)){
		if(sum(is.na(tmp[,j]))>0){
			tmp[,j] <- na.approx(tmp[,j], na.rm=FALSE, rule=2)
		}
	}
	ahrf[ahrf$f00002 == i,] <- tmp
}

## Fix the rest through hotdeck
set.seed(9)
ahrf <- hotdeck(ahrf, imp_var=FALSE)

## Create some derivative variables
ahrf$hpsa_whole <- ifelse(ahrf$f09787==1, 1, 0) # Healthcare professional shortage area - whole county
ahrf$hpsa_part <- ifelse(ahrf$f09787==2,1,0) # Healthcare professional shortage area - partial county
ahrf$rural <- ifelse(ahrf$f00020 %in% c("08","09"), 1, 0) # Rural dummy
ahrf$metro <- ifelse(ahrf$f00020 %in% c("01","02","03"), 1, 0) # Metro dummy
ahrf$nonmetro <- ifelse(ahrf$rural==0 & ahrf$metro==0,1,0) # Non-metro, non-rural dummy
ahrf$op_visits <- with(ahrf, f09566 + f09567 + f09568 + f09571) # Total OP visits

## Remove census population
ahrf$f04530 <- NULL 

## Export in desired format
write.csv(ahrf, "Cleaned AHRF 3-31-21 DIB.csv", row.names=FALSE)
saveRDS(ahrf, "Cleaned AHRF 3-31-21 DIB.RDS")
write_dta(ahrf, "Cleaned AHRF 3-31-21 DIB.dta")
