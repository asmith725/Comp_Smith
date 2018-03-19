library(tidyverse)
library(ggplot2)

particle_count <- read_csv("~/Desktop/comp_Smith/Results/particle_count.csv")
new <- particle_count %>% separate(newSlice, c("Protein", "Time"), " ", extra = "merge")
newTime <- strtrim(new$Time)
new$Time <- newTime

aggregate(Count ~ Protein + newTime, new, mean)

ggplot(new, aes(x= newTime, y=Count, fill= Protein)) + 
  geom_bar(stat="identity", position=position_dodge(),)+ 
  ggtitle("Dmc1 and Mei5 Levels Over Time")+
  xlab("Sporulation Time")+ 
  ylab("Protein Count")

  
  