##################
## FRONT MATTER ##
##################

## Set to your working directory
setwd("D:/Google Drive/Opioid DIB")

## Load required libraries
library(data.table)
library(haven)
library(DBI)
library(noncensus)
library(gtools)
library(zoo)
library(Hmisc)
library(arcos)
library(VIM)

## Download ARCOS data
cty <- summarized_county_annual(key = "WaPo")[,2:6] 
names(cty)[3] <- "SHIP_COUNT"

## Load CDC Wonder data
cdc <- read.csv("opioid_deaths_3yr.csv", header=TRUE, stringsAsFactors=FALSE)
cancer <- read.csv("cancer_deaths_3yr.csv", header=TRUE, stringsAsFactors=FALSE)

## Load data files to match zip to county/state
data(zip_codes)
data(counties)

## Load prepped AHRF - update pathways as needed
ahrf <- readRDS("Cleaned AHRF 11-28-20 DIB.RDS")

## Load in NPRX/PDMP - update pathways as needed
nprx <- read.csv("NPRX_PDMP.csv", header=TRUE, stringsAsFactors=FALSE)

###################
## PREP CDC DATA ##
###################

## Remove extra fields
cdc <- cdc[,c(3,4,8)]
cancer <- cancer[,c(3,4,7)]

## Remove incomplete rows
cdc <- cdc[complete.cases(cdc),]
cancer <- cancer[complete.cases(cancer),]

## Subset beginning of 3-year avg
cdc$year <- substr(cdc$year, 1, 4)
cancer$year <- substr(cancer$year, 1, 4)

## Fix county code (leading zero dropped)
names(cdc) <- c("fips","ord_deaths","year")
names(cancer) <- c("fips","cancer_deaths","year")
cdc$fips[nchar(cdc$fips)<5] <- paste("0", cdc$fips[nchar(cdc$fips)<5], sep="")
cancer$fips[nchar(cancer$fips)<5] <- paste("0", cancer$fips[nchar(cancer$fips)<5], sep="")

## Convert deaths to NA
cdc$ord_deaths[cdc$ord_deaths%in%c("Suppressed","Missing")] <- NA
cancer$cancer_deaths[cancer$cancer_deaths%in%c("Suppressed","Missing")] <- NA

#################################
## MERGE AHRF + WONDER + ARCOS ##
#################################

## Merge AHRF & mortality, cancer keeping all counties
imp <- merge(ahrf, cdc, by.x=c("f00002","yr"), by.y=c("fips","year"), all=TRUE)
imp <- merge(imp, cancer, by.x=c("f00002","yr"), by.y=c("fips","year"), all=TRUE)

## Now merge in ARCOS, keeping all counties
imp <- merge(imp, cty, by.x=c("f00002","yr"), by.y=c("countyfips","year"),all=TRUE)

## Remove counties with no population
imp <- imp[!is.na(imp$f11984) & imp$f11984!=0,]

## Convert population to numeric
imp$f11984 <- as.numeric(imp$f11984)

## Calculate crude death rates, per capita pill volume
imp$cdr_noimp <- as.numeric(imp$ord_deaths)/as.numeric(imp$f11984)*100000
imp$cancer_cdr_noimp <- as.numeric(imp$cancer_deaths)/as.numeric(imp$f11984)*100000
imp$pcpv <-imp$DOSAGE_UNIT/imp$f11984

## Remove counties that have VA regional distribution centers
imp <- imp[!(imp$f04437 %in% c("LEAVENWORTH, KS","CHARLESTON, SC")),]

## Remove PR
imp <- imp[imp$BUYER_STATE!="PR",]

## Calculate PCPV quantiles
imp$pill_quart <- cut2(imp$pcpv, g=4)

## Scale certain variables by population
imp$op_pc <- imp$op_visits/imp$f11984 ############ CHECK
imp$ip_pc <- imp$f09545/imp$f11984 
imp$pct_men <- imp$f13906/imp$f11984 * 100
imp$pct_white <- (imp$f13908+imp$f13909)/imp$f11984 * 100
imp$pct_black <- (imp$n_black)/imp$f11984 * 100
imp$pct_asian <- (imp$n_asian)/imp$f11984 * 100
imp$pct_other <- with(imp, 100 - pct_white - pct_black - pct_asian)
imp$pct_hisp <- (imp$n_hisp)/imp$f11984 * 100
imp$pct_medicare <- imp$f13191/imp$f11984 * 100
imp$arf_cdr <- imp$f12558/imp$f11984 * 100
imp$pop_density <- imp$f11984/imp$f09721 / 100
imp$pct_duals <- imp$f14206/imp$f11984 * 100
imp$pct_25t34 <- with(imp, (f06714+f06715+f06716+f06717)/f11984 * 100)
imp$pct_35t44 <- with(imp, (f06718+f06719)/f11984 * 100)
imp$pct_45t54 <- with(imp, (f06720+f06721)/f11984 * 100)
imp$pct_55t64 <- with(imp, (f06722+f06723+f06724+f06725)/f11984 * 100)
imp$pct_65t74 <- with(imp, (f06726+f06727)/f11984 * 100)
imp$pct_75t84 <- with(imp, (f11640+f11641)/f11984 * 100)
imp$pct_85plus <- with(imp, (f11642+f11643)/f11984 * 100)
imp$pct_vets <- imp$f11396/imp$f11984 * 100

## Scale healthcare professionals by 100,000 population
imp$np_pc <- imp$f14642/imp$f11984 * 100000  ############# CHECK
imp$md_lt35_pc <- imp$f04904/imp$f11984 * 100000
imp$md_35t44_pc <- imp$f04905/imp$f11984 * 100000
imp$md_45t54_pc <- imp$f04906/imp$f11984 * 100000
imp$md_55t64_pc <- imp$f04907/imp$f11984 * 100000
imp$md_65t74_pc <- imp$f12016/imp$f11984 * 100000
imp$md_75plus_pc <- imp$f12017/imp$f11984 * 100000
imp$spec_lt35_pc <- imp$f04916/imp$f11984 * 100000
imp$spec_35t44_pc <- imp$f04917/imp$f11984 * 100000
imp$spec_45t54_pc <- imp$f04918/imp$f11984 * 100000
imp$spec_55t64_pc <- imp$f04919/imp$f11984 * 100000
imp$spec_65t74_pc <- imp$f12034/imp$f11984 * 100000
imp$spec_75plus_pc <- imp$f12035/imp$f11984 * 100000
imp$dentists_lt35_pc <- imp$f10498/imp$f11984 * 100000
imp$dentists_35t44_pc <- imp$f11318/imp$f11984 * 100000
imp$dentists_45t54_pc <- imp$f11319/imp$f11984 * 100000
imp$dentists_55t64_pc <- imp$f13176/imp$f11984 * 100000
imp$dentists_65plus_pc <- imp$f10505/imp$f11984 * 100000

## Aggregate MDs and specialists per capita
imp$md_pc <- with(imp, md_lt35_pc + md_35t44_pc + md_45t54_pc + md_55t64_pc + md_65t74_pc + md_75plus_pc)
imp$spec_pc <- with(imp, spec_lt35_pc + spec_35t44_pc + spec_45t54_pc + spec_55t64_pc + spec_65t74_pc + 
	spec_75plus_pc)

## Fix small number of racial and age groups with combined percentages > 100
imp$pct_white[imp$pct_white>100&!is.na(imp$pct_white)] <- 100
imp$pct_black[imp$pct_black>100&!is.na(imp$pct_black)] <- 100
imp$pct_duals[imp$pct_duals>100&!is.na(imp$pct_duals)] <- 100
imp$pct_25t34[imp$pct_25t34>100&!is.na(imp$pct_25t34)] <- 100
imp$pct_35t44[imp$pct_35t44>100&!is.na(imp$pct_35t44)] <- 100
imp$pct_45t54[imp$pct_45t54>100&!is.na(imp$pct_45t54)] <- 100
imp$pct_55t64[imp$pct_55t64>100&!is.na(imp$pct_55t64)] <- 100
imp$pct_65t74[imp$pct_65t74>100&!is.na(imp$pct_65t74)] <- 100
imp$pct_75t84[imp$pct_75t84>100&!is.na(imp$pct_75t84)] <- 100
imp$pct_85plus[imp$pct_85plus>100&!is.na(imp$pct_85plus)] <- 100
imp$pct_85plus[imp$pct_85plus>100&!is.na(imp$pct_85plus)] <- 100

## Create combined age bins, constrained to max of 100%
imp$pct_25t44 <- with(imp, pmin(pct_25t34 + pct_35t44,100))
imp$pct_45t64 <- with(imp, pmin(pct_45t54 + pct_55t64,100))
imp$pct_65plus <- with(imp, pmin(pct_65t74 + pct_75t84 + pct_85plus,100))

## Mark states which expanded Medicaid early
imp$exp_early <- ifelse(
	imp$BUYER_STATE=="CA" & imp$yr>2010 |
	imp$BUYER_STATE=="CT" & imp$yr>2009 |
	imp$BUYER_STATE=="DC" & imp$yr>2009 |
	imp$BUYER_STATE=="MN" & imp$yr>2010 |
	imp$BUYER_STATE=="NJ" & imp$yr>2010 |
	imp$BUYER_STATE=="WA" & imp$yr>2010, 1, 0)

###################
## IMPUTE DEATHS ##
###################

## Remove records with no FIPS
imp <- imp[!is.na(imp$f00002),]

## Remove records with no population
imp <- imp[!is.na(imp$f11984),]

## Convert opioid-related deaths to numeric
imp$ord_deaths <- as.numeric(imp$ord_deaths)
imp$ord_deaths_noimp <- imp$ord_deaths

## Run Poisson model for opioid deaths
tmp.fit <- glm(ord_deaths ~ pcpv + f09781 + f11396 + f06795 + nonmetro + rural +
	hpsa_whole + hpsa_part + pct_medicare + f14045 + f08924 + f08923 + f08922 +
	f13220 + f15474 + f14587 + f14482 + np_pc + pct_duals +
	pct_men + pct_black + pct_other + pct_asian + pct_hisp + pct_medicare +
	pct_25t34 + pct_35t44 + pct_45t54 + pct_55t64 + pct_65t74 + pct_75t84 +
	pct_85plus + pop_density + np_pc + f13220 + 
	dentists_lt35_pc + dentists_35t44_pc + dentists_45t54_pc + 
	dentists_55t64_pc + dentists_65plus_pc + md_lt35_pc + md_35t44_pc + 
	md_45t54_pc + md_55t64_pc + md_65t74_pc + md_75plus_pc, 
	offset=log(f11984), 
	data=imp, family=poisson)

## Extract missing values
test <- imp[is.na(imp$ord_deaths),]

## Extract predictions
test$ord_deaths <- predict(tmp.fit, newdata=test, type="response")

## Cap predictions at 25 (cutoff for CDC supression)
test$ord_deaths[test$ord_deaths>25] <- 25

## Replace missing values
imp$ord_deaths[is.na(imp$ord_deaths)] <- test$ord_deaths

## Scale crude opioid-related death rate per 100,000 population
imp$ord_cdr <- as.numeric(imp$ord_deaths)/as.numeric(imp$f11984)*100000
imp$ord_cdr_noimp<- as.numeric(imp$ord_deaths_noimp)/as.numeric(imp$f11984)*100000

## Convert cancer deaths to numeric
imp$cancer_deaths <- as.numeric(imp$cancer_deaths)
imp$cancer_deaths_noimp <- imp$cancer_deaths

## Run Poisson model for cancer deaths
tmp.fit2 <- glm(cancer_deaths ~ pcpv + f09781 + f11396 + f06795 + nonmetro + rural +
	hpsa_whole + hpsa_part + pct_medicare + f14045 + f08924 + f08923 + f08922 +
	f13220 + f15474 + f14587 + f14482 + np_pc + pct_duals +
	pct_men + pct_black + pct_other + pct_asian + pct_hisp + pct_medicare +
	pct_25t34 + pct_35t44 + pct_45t54 + pct_55t64 + pct_65t74 + pct_75t84 +
	pct_85plus + pop_density + np_pc + f13220 + 
	dentists_lt35_pc + dentists_35t44_pc + dentists_45t54_pc + 
	dentists_55t64_pc + dentists_65plus_pc + md_lt35_pc + md_35t44_pc + 
	md_45t54_pc + md_55t64_pc + md_65t74_pc + md_75plus_pc,
	offset=log(f11984), data=imp, family=poisson)

## Extract missing values
test <- imp[is.na(imp$cancer_deaths),]

## Extract predictions
test$cancer_deaths <- predict(tmp.fit2, newdata=test, type="response")

## Cap predictions at 25 (cutoff for CDC supression)
test$cancer_deaths[test$cancer_deaths>25] <- 25

## Replace missing values
imp$cancer_deaths[is.na(imp$cancer_deaths)] <- test$cancer_deaths

## Scale crude cancer death rate per 100,00 population
imp$cancer_cdr<- as.numeric(imp$cancer_deaths)/as.numeric(imp$f11984)*10000

#######################
## PREP NP/PDMP DATA ##
#######################

## Convert state names to abbreviations
nprx$state.abb <- setNames(state.abb, toupper(state.name))[nprx$state_name]
nprx$state.abb[is.na(nprx$state.abb)] <- "DC"

## Merge to data frame
nprx$year <- as.character(nprx$year)
imp <- merge(imp, nprx[,c(1,4:6)], by.x=c("BUYER_STATE","yr"), by.y=c("state.abb","year"))

## Remove redundant state variable
imp$BUYER_STATE <- NULL

##########################
## EXPORT ANALYTIC FILE ##
##########################

## Convert variable names to upper case
names(imp) <- toupper(names(imp))

## Export result in desired format
write.csv(imp, "Analytic File 3-31-21 DIB.csv", row.names=FALSE)
saveRDS(imp, "Analytic File 3-31-21 DIB.RDS")
write_dta(imp, "Analytic File 3-31-21 DIB.dta")