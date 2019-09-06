library(readr)
library(dplyr)
library(tidyr)
library(ggplot2)
library(ggpubr)

setwd("orthofinder/")

o_ratio <- read_tsv("Statistics_PerSpecies_perc.csv",col_names = TRUE)
colnames(o_ratio) <- c("ratio","hvul","hvir")

o_ratio <- gather(o_ratio,species,perc,c("hvir","hvul"),factor_key = TRUE)
o_ratio$ratio <- factor(o_ratio$ratio,levels = o_ratio$ratio[1:20])

theme_set(theme_pubr())
p <- ggplot(o_ratio,aes(x=ratio,y=perc,fill=species)) +
  geom_col(position="dodge") +
  theme(axis.text.x = element_text(angle=45,hjust=1)) +
  labs(x="Number of genes per-species in orthogroup",y="Perc. of orthogroup") +
  scale_fill_manual(values=c("#28821c", "#593919"),labels = c("Hydra viridissima", "Hydra vulgaris")) 

ggsave("orthogroup_plot.svg")
