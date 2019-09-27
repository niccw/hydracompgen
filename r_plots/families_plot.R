library(dplyr)
library(readr)
library(tidyr)
library(magrittr)
library(ggplot2)
library(see)

setwd("<your_path>")

# read in all families.sum
for (f in list.files(pattern="*families.sum")){
  vn <- gsub("_families.sum","",f)
  print(vn)
  tmp_df <- read_tsv(f,col_names = c("te_class","total","proportion"))
  tmp_df["species"] <- vn
  #colnames(tmp_df) <- c()
  assign(vn,tmp_df)
}
rm(vn,f,tmp_df)
# col2: abs cnt ; col3: proportion per species genome



dfls <- ls(pattern = "*")
dls <- list()
# List of dataframe
for (i in seq_along(dfls)){
  dls[[i]] <- get(dfls[i])
}

# rbind
fulldf <- do.call(rbind,dls)
fulldf$species <- factor(fulldf$species,levels = c("zu2","aep","oli","cir","virgen","hm105"))
fulldf <- tidyr::separate(fulldf,te_class,c("generalClass","superFamily"),sep="/")
# manually fill DNA general class `superFamily` with "DNA"
fulldf[fulldf$generalClass=="DNA" & is.na(fulldf$superFamily),"superFamily"] <- "DNA"

# plot by classes
fulldf_noNA <- fulldf[!is.na(fulldf$superFamily),]

#TODO: sort family by general classes (and add color code to each superfamily base on general class)
fulldf_noNA <- dplyr::arrange(fulldf_noNA,generalClass,superFamily)
fulldf_noNA$superFamily <- factor(fulldf_noNA$superFamily,levels = unique(fulldf_noNA$superFamily))
fulldf_noNA$species <- factor(fulldf_noNA$species,levels = c("virgen","cir","oli","aep","zu2","hm105"))

# plot
g <- ggplot(fulldf_noNA,aes(`superFamily`,`proportion`))
p <- g + geom_col(aes(fill=generalClass),position = position_dodge2(preserve = "single")) + 
  coord_flip() +
  #scale_fill_manual(values = c("#7BB9FF","#D7263D","#FFDE40","#0CCE6B","#434744","#C7C9C6")) +
  theme_modern(axis.text.angle = 45) +
  theme(axis.text.y=element_blank()) +
  scale_fill_material_d() +
  facet_grid(rows = vars(generalClass),cols= vars(species))


# plot only LINE
g2 <- ggplot(fulldf_noNA[fulldf_noNA$generalClass %in% c("LINE"),],aes(`superFamily`,`proportion`))
p2 <- g2 + geom_col(position = position_dodge2(preserve = "single")) + 
  coord_flip() +
  #scale_fill_manual(values = c("#7BB9FF","#D7263D","#FFDE40","#0CCE6B","#434744","#C7C9C6")) +
  theme(axis.text.x=element_text(angle=45, hjust=1,size=12),
        axis.text.y = element_text(size=10)) +
  facet_grid(rows = vars(generalClass),cols= vars(species)) +
  theme_modern(axis.text.angle = 45) +
  scale_fill_material_d() +
  labs(title="Proportion of superfamily of LINE element in Hydra")

ggsave("line_superfamily_proportion.svg",width = 269,height = 188,units = "mm")

# plot only SINE

g3 <- ggplot(fulldf_noNA[fulldf_noNA$generalClass %in% c("SINE"),],aes(`superFamily`,`proportion`))
p3 <- g3 + geom_col(position = position_dodge2(preserve = "single")) + 
  coord_flip() +
  #scale_fill_manual(values = c("#7BB9FF","#D7263D","#FFDE40","#0CCE6B","#434744","#C7C9C6")) +
  theme(axis.text.x=element_text(angle=45, hjust=1,size=12),
        axis.text.y = element_text(size=10)) +
  facet_grid(rows = vars(generalClass),cols= vars(species)) +
  theme_modern(axis.text.angle = 45) +
  scale_fill_material_d() +
  labs(title="Proportion of superfamily of SINE element in Hydra")

