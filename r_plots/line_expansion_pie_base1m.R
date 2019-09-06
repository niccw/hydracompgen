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
fulldf <- do.call(rbind,new_dls)
fulldf$total <- fulldf$total %>% as.numeric()

# Plot pie chart ----------------------------------------------------------

total_sum_df <- fulldf %>% group_by(species) %>% filter(`class` %in% c("LINE","SINE","DNA","LTR","other_te","non_te")) %>% summarise(all_class_total=sum(total))
total_sum_v <- setNames(as.numeric(total_sum_df$all_class_total),total_sum_df$species)
sub_df <- fulldf %>% filter(`class` %in% c("LINE","SINE","DNA","LTR","other_te","non_te"))
pie_proportion_df <- sub_df %>% mutate(perc = `total`/!!total_sum_v[sub_df$species])
pie_proportion_df$species <- factor(pie_proportion_df$species, levels = c("zu2","aep","oli","cir","virgen"))

#bp<- ggplot(df, aes(x="", y=value, fill=group)) + geom_bar(width = 1, stat = "identity")

# blank theme
blank_theme <- theme_minimal()+
  theme(
    axis.title.x = element_blank(),
    axis.title.y = element_blank(),
    axis.text = element_blank(),
    axis.ticks.x = element_blank(),
    panel.border = element_blank(),
    panel.grid=element_blank(),
    axis.ticks = element_blank(),
    plot.title=element_text(size=14, face="bold")
  )


p <- ggplot(pie_proportion_df,aes(x="",y=perc,fill=class)) + geom_bar(width = 1, stat = "identity",color="black") + 
  coord_polar("y", start=0) + 
  geom_text(aes(y =`perc`, label = percent(`perc`)), position = position_stack(vjust = 0.5)) +
  facet_grid(cols = vars(species)) +
  blank_theme + scale_fill_manual(values = c("#7BB9FF","#D7263D","#FFDE40","#0CCE6B","#434744","#C7C9C6"))
#geom_text( label = percent(pie_proportion_df$perc), size=3)
#geom_text(aes(y =`perc`, label = percent(`perc`)), position = position_stack(vjust = 0.5))
#y.breaks <- cumsum(df$time) - df$time/2

ggsave("line_expansion_pie.svg")