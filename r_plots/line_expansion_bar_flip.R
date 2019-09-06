library(dplyr)
library(readr)
library(magrittr)
library(ggplot2)
library(scales)

setwd("barplot/")

for (f in list.files(pattern="*classes.sum")){
  vn <- gsub("_classes.sum","",f)
  print(vn)
  tmp_df <- read_tsv(f,col_names = c("class","total"))
  tmp_df["species"] <- vn
  #colnames(tmp_df) <- c()
  assign(vn,tmp_df)
}

rm(vn,f,tmp_df)

dfls <- ls(pattern = "*")
dls <- list()

# List of dataframe
for (i in seq_along(dfls)){
  dls[[i]] <- get(dfls[i])
}

# Add otherTE and nonTE class
new_dls <- list()
cnt <- 1
for(df in dls){
  other_te_number <- filter(df,!df$class %in% c("LINE","SINE","DNA","LTR")) %>% select(`total`) %>% sum()
  non_te_number <- 1000000 - sum(df$total)
  # for debug
  print(df$species[1])
  print(other_te_number)
  print(non_te_number)
  # assign back to df
  df <- rbind(df,c("other_te",other_te_number,df$species[1]))
  df <- rbind(df,c("non_te",non_te_number,df$species[1]))
  new_dls[[cnt]] <- df
  cnt <- cnt + 1
}

# rbind
fulldf <- do.call(rbind,dls)
#fulldf <- do.call(rbind,new_dls)
fulldf$species <- factor(fulldf$species,levels = c("zu2","aep","oli","cir","virgen","hm105"))


# plot --------------------------------------------------------------------

library(ggpubr)
theme_set(theme_pubr())

g <- ggplot(fulldf[fulldf$class %in% c("LINE","SINE","LTR","DNA","other_te","non_te"),],aes(`class`,total))
p <- g + geom_col(aes(fill=class),position = position_dodge2(preserve = "single")) + 
  coord_flip() +
  scale_fill_manual(values = c("#7BB9FF","#D7263D","#FFDE40","#0CCE6B","#434744","#C7C9C6")) +
  theme(axis.text.x=element_text(angle=45, hjust=1,size=12)) +
  facet_grid(rows = vars(species))

ggsave("line_expansion_flip_bar.svg",width = 365,height = 712,units = "px")
