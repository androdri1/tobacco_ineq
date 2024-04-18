# Genetic Matching for the smoking budget inequalities paper
# Sekhon, Jasjeet S. 2011. "Multivariate and Propensity Score Matching Software with Automated Balance Optimization: The Matching package for R." Journal of Statistical Software. 42(7): 1-52. 
# Paul Rodriguez-Lesmes (2021/07/16)

#library("snow") # Parallel
library(haven)
library(Matching)

rm(list = ls())

if ( Sys.getenv("HOME")=="/home/paul.rodriguez") {
  mainF="/dataeco01/economia/usuarios/paul.rodriguez/tobacoineq/"
}
if (Sys.getenv("USERNAME")=="andro") {
  mainF="C:/Users/andro/Dropbox/tabaco/tabacoDrive/tobacco-health-inequalities/procesamiento/"
}
if (Sys.getenv("USERNAME")=="paul.rodriguez") {
  mainF="D:/Paul.Rodriguez/Dropbox/tabaco/tabacoDrive/tobacco-health-inequalities/procesamiento/"
}


ECV <- read_dta(paste(mainF,"derived/ECVrepeat_preMatch.dta",sep=""))

sink(paste(mainF,"derived/logR.txt",sep=""))

i=1
resGM=vector(mode = "list", length = 20)
resMa=vector(mode = "list", length = 20)
resBa=vector(mode = "list", length = 20)
datos=vector(mode = "list", length = 20)


for (anio in c(1997,2003,2008,2011) ) {
  #cl <- makeCluster(c("musil", "quetelet", "quetelet"), type = "SOCK")
  for (sm in c(0,1)) {
    
    if (anio==2011 & sm==1) { # No se hace matching de los fumadores de 2011 con ellos mismos
      break
    }
    
    for (qui in c(1,2,3,4,5)) {   
      #For testing...
      #anio=1997
      #qui=1
      #sm=0
  
      #cat("year=",anio," quint=",qui," sm=",sm)
      # Data from ECV smokers of year 2011 ......
      XR  = subset(ECV,subset= (year==2011 & smokers==1 & quint==qui )
                   ,select=c(total_indiv,zona,edad,female,kids_adults,ed_1,ed_2,ed_3))
      IdR = subset(ECV,subset= (year==2011 & smokers==1 & quint==qui)
                   ,select=c(id))
      TrR = data.frame( data2011S=array(1L, nrow(IdR) )  )
      
      # Data from ECV smokers/no-smokers of year ano ......
      X =subset(ECV,subset= (year==anio & quint==qui & smokers==sm) ,select=c(total_indiv,zona,edad,female,kids_adults,ed_1,ed_2,ed_3))
      Id=subset(ECV,subset= (year==anio & quint==qui & smokers==sm) ,select=c(id))
      Tr=data.frame( data2011S=array(0L, nrow(Id) )  ) 
  
      X =  rbind(XR ,X)
      Tr=  rbind(TrR,Tr)
      Id=  rbind(IdR,Id)
      datos[[i]]=c(Tr,X)
          
      # First, get the propensity score. Do genetic matching over it
      dw.pscore <- glm(data2011S ~ total_indiv+zona+edad+female+kids_adults+ed_1+ed_2+ed_3, family = binomial, data = datos[[i]] )  
      datos[[i]]$pscore = dw.pscore$fitted
      X$pscore = dw.pscore$fitted
      
      Tr=as.matrix(Tr)
      Id=as.matrix(Id)
      X =as.matrix(X)
      miRes <- GenMatch(Tr=Tr, X=X,
                        M=5, pop.size=10000) #M=1,ties=FALSE, caliper=0.25, pop.size=10000)
                   #pop.size=16, max.generations=10, wait.generations=1) #, cluster = cl
      resGM[[i]] = miRes
      resMa[[i]] = Match(Tr = Tr, X = X, Y=Id , Weight.matrix = miRes)  
      resBa[[i]] = MatchBalance(data2011S ~ total_indiv+zona+edad+female+kids_adults+ed_1+ed_2+ed_3,
                                match.out=resMa[[i]] , data=datos[[i]], nboots=500)
      summary(resBa[[i]])
      #stopCluster(cl)
      
      # Comparemos como se ve una variable, solo para referencia
      m1=sum( resMa[[i]]$mdata$X[  as.logical(resMa[[i]]$mdata$Tr ) ,"edad"]* resMa[[i]]$weights) / sum(resMa[[i]]$weights)
      m0=sum( resMa[[i]]$mdata$X[ !as.logical(resMa[[i]]$mdata$Tr ) ,"edad"]* resMa[[i]]$weights) / sum(resMa[[i]]$weights)
  
      cat("i",i," year=",anio," quint=",qui," sm=",sm,". Media 0: ",m0,", Media 1: ",m1)        
          
      i=i+1
    }
  }
}  

save.image( paste(mainF,"derived/ECVrepeat_a3.RData",sep=""))
# ======================================
load(  paste(mainF,"derived/ECVrepeat_a3.RData",sep=""))
if ( Sys.getenv("HOME")=="/home/paul.rodriguez") {
  mainF="/dataeco01/economia/proyectos/estimacion.umbrales/"
}
if (Sys.getenv("USERNAME")=="paul.rodriguez") {
  mainF="D:/Paul.Rodriguez/Dropbox/tabaco/tabacoDrive/tobacco-health-inequalities/procesamiento/"
}


# Resultados matching (balance)
#summary(resBa[[1]])


i=1
baso = data.frame(total_indiv = numeric(),zona = numeric(),edad = numeric(),female = numeric(),kids_adults = numeric(),ed_1 = numeric(),ed_2 = numeric(),ed_3 = numeric() ,
                  pscore = numeric(), weig=numeric(), Tr=numeric(),indi=numeric(),year = numeric(),quin = numeric(),stringsAsFactors = FALSE)
for (anio in c(1997,2003,2008,2011) ) {
  for (sm in c(0,1)) {
    if (anio==2011 & sm==1) { # No se hace matching de los fumadores de 2011 con ellos mismos
      break
    }
    
    for (qui in c(1,2,3,4,5)) {   
      base=data.frame(resMa[[i]]$mdata$X)
      base$Tr  =resMa[[i]]$mdata$Tr
      base$indi=resMa[[i]]$mdata$Y
      base$weig=resMa[[i]]$weights
      base$year=anio
      base$quin=qui
      base$smoker=sm
      
      baso = rbind(baso, base )
      
      i=i+1
    }
  }
}

write_dta(baso, paste(mainF,"derived/ECV_pesosAfterMatchingSmokers.dta",sep="") , version=14)

sink()
