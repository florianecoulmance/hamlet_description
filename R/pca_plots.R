#!/usr/bin/env Rscript
# by: Floriane Coulmance: 05/11/2020
# usage:
# Rscript --vanilla pca_plots.R <data_path> <figure_path> <out_prefix>
# -------------------------------------------------------------------------------------------------------------------
# data_path in : $BASE_DIR/outputs/pca/<.RData file>
# figure_path in : $BASE_DIR/figures/ (/user/doau0129/work/ibd/figures)
# out_prefix
# -------------------------------------------------------------------------------------------------------------------


# Clear the work space
rm(list = ls())

# Load needed library
library(stringr)
library(stringi)
library(ggplot2)
library(ggpubr)
library(ggtext)
library(hypoimg)


# -------------------------------------------------------------------------------------------------------------------
# ARGUMENTS

# Get the arguments in variables
args = commandArgs(trailingOnly=FALSE)
args = args[6:9]
print(args)

data_path <- as.character(args[1]) # Path to PCs table
var_path <- as.character(args[2])
# data_path <- "/Users/fco/Desktop/PhD/1_CHAPTER1/1_GENETICS/all_filterd_casz1_pca.RData"
figure_path <- as.character(args[3]) # Path to the figure folder
# figure_path <- "/Users/fco/Desktop/PhD/1_CHAPTER1/1_GENETICS/figures/"
out_prefix <- as.character(args[4])
# out_prefix <- "all_filterd_casz1_pca"

# -------------------------------------------------------------------------------------------------------------------
# ANALYSIS

logos_spec <- c(abe = "<img src='/Users/fco/Desktop/PhD/1_CHAPTER1/0_IMAGES/after_python/logos/H_aberrans.l.cairo.png' width='90' /><br>*H. aberrans*",
  chl = "<img src='/Users/fco/Desktop/PhD/1_CHAPTER1/0_IMAGES/after_python/logos/H_chlorurus.l.cairo.png' width='90' /><br>*H. chlorurus*",
  flo = "<img src='/Users/fco/Desktop/PhD/1_CHAPTER1/0_IMAGES/after_python/logos/H_floridae.l.cairo.png' width='90' /><br>*H. floridae*",
  gem = "<img src='/Users/fco/Desktop/PhD/1_CHAPTER1/0_IMAGES/after_python/logos/H_gemma.l.cairo.png' width='90' /><br>*H. gemma*",
  gum = "<img src='/Users/fco/Desktop/PhD/1_CHAPTER1/0_IMAGES/after_python/logos/H_gumigutta.l.cairo.png' width='90' /><br>*H. gummiguta*",
  gut = "<img src='/Users/fco/Desktop/PhD/1_CHAPTER1/0_IMAGES/after_python/logos/H_guttavarius.l.cairo.png' width='90' /><br>*H. guttavarius*",
  ind = "<img src='/Users/fco/Desktop/PhD/1_CHAPTER1/0_IMAGES/after_python/logos/H_indigo.l.cairo.png' width='90' /><br>*H. indigo*",
  may = "<img src='/Users/fco/Desktop/PhD/1_CHAPTER1/0_IMAGES/after_python/logos/H_maya.l.cairo.png' width='90' /><br>*H. maya*",
  nig = "<img src='/Users/fco/Desktop/PhD/1_CHAPTER1/0_IMAGES/after_python/logos/H_nigricans.l.cairo.png' width='90' /><br>*H. nigricans*",
  pue = "<img src='/Users/fco/Desktop/PhD/1_CHAPTER1/0_IMAGES/after_python/logos/H_puella.l.cairo.png' width='90' /><br>*H. puella*",
  ran = "<img src='/Users/fco/Desktop/PhD/1_CHAPTER1/0_IMAGES/after_python/logos/H_randallorum.l.cairo.png' width='90' /><br>*H. randallorum*",
  tan = "<img src='/Users/fco/Desktop/PhD/1_CHAPTER1/0_IMAGES/after_python/logos/H_tan.l.cairo.png' width='90' /><br>*H. affinis*",
  uni = "<img src='/Users/fco/Desktop/PhD/1_CHAPTER1/0_IMAGES/after_python/logos/H_unicolor.l.cairo.png' width='90' /><br>*H. unicolor*")

logos_loc <- c(bel = "<img src='/Users/fco/Desktop/PhD/1_CHAPTER1/0_IMAGES/after_python/logos/belize.png' width='30' /><br>Belize",
               boc = "<img src='/Users/fco/Desktop/PhD/1_CHAPTER1/0_IMAGES/after_python/logos/pan.png' width='30' /><br>Panama",
               flo = "<img src='/Users/fco/Desktop/PhD/1_CHAPTER1/0_IMAGES/after_python/logos/us.png' width='30' /><br>USA",
               por = "<img src='/Users/fco/Desktop/PhD/1_CHAPTER1/0_IMAGES/after_python/logos/puer.png' width='30' /><br>Puerto Rico")

spec_colors <- c('#ff007f', '#00ffd8', '#17202A','#C0392B', '#27AE60','#2E86C1','#F4D03F','#8E44AD','#E67E22','#F772CB','#591402','#3F5202','#1010D4')

load(data_path)
variance <- read_tsv(var_path)
data <- data.frame(pca[["eigenvect"]])
id <- pca[["sample.id"]]
data["id"] <- id
data["geo"] <- stri_sub(data$id,-3,-1)
data["spec"] <- stri_sub(data$id,-6,-4)

# data2 <- data[!(data$geo=="flo"),]
# print(data2)


p1 <- ggplot(data,aes(x=X1,y=X2,color=spec)) + geom_point(aes(shape=geo)) + xlab("PC1") + ylab("PC2")
p1 <- p1 + scale_color_manual(values=spec_colors,
                            labels = logos_spec) +
  scale_shape_manual(values = c(16,17,15,3),
                            labels = logos_loc) +
  theme(legend.position="bottom",legend.title=element_blank(),legend.box = "vertical",legend.text =  element_markdown(size = 6)) +
  guides(color = guide_legend(nrow = 1))


p2 <- ggplot(data,aes(x=X1,y=X2,color=spec)) + geom_point(size = 3) + 
      labs(x = paste0("PC1, var =  ", format(round(variance$variation[1], 1), nsmall = 1), " %") , y = paste0("PC2, var = ", format(round(variance$variation[2], 1), nsmall = 1), " %"))
p2 <- p2 + scale_color_manual(values=spec_colors,
                              labels = logos_spec) +
  theme(legend.position="bottom",legend.title=element_blank(),legend.box = "vertical",legend.text =  element_markdown(size = 20),
        panel.background = element_blank(), panel.border = element_rect(colour = "black", fill=NA, size=1),
        text = element_text(size=30), legend.key=element_blank()) +
  guides(color = guide_legend(nrow = 1))


p3 <- ggplot(data,aes(x=X1,y=X3,color=spec)) + geom_point(size = 3) + 
      labs(x = paste0("PC1, var =  ", format(round(variance$variation[1], 1), nsmall = 1), " %") , y = paste0("PC3, var = ", format(round(variance$variation[3], 1), nsmall = 1), " %"))
p3 <- p3 + scale_color_manual(values=spec_colors,
                              labels = logos_spec) +
  theme(legend.position="bottom",legend.title=element_blank(),legend.box = "vertical",legend.text =  element_markdown(size = 20),
        panel.background = element_blank(), panel.border = element_rect(colour = "black", fill=NA, size=1),
        text = element_text(size=30), legend.key=element_blank()) +
  guides(color = guide_legend(nrow = 1))


p4 <- ggplot(data,aes(x=X2,y=X3,color=spec)) + geom_point(size = 3) +
      labs(x = paste0("PC2, var =  ", format(round(variance$variation[2], 1), nsmall = 1), " %") , y = paste0("PC3, var = ", format(round(variance$variation[3], 1), nsmall = 1), " %"))
p4 <- p4 + scale_color_manual(values=spec_colors,
                              labels = logos_spec) +
  theme(legend.position="bottom",legend.title=element_blank(),legend.box = "vertical",legend.text =  element_markdown(size = 20),
        panel.background = element_blank(), panel.border = element_rect(colour = "black", fill=NA, size=1),
        text = element_text(size=30), legend.key=element_blank()) +
  guides(color = guide_legend(nrow = 1))

#p2 <- p1 + xlim(-0.1, 0.2) + ylim(-0.03,0.075) + theme(legend.position="none")

#p3 <- p1 + xlim(-0.1, -0.025) + ylim(-0.008,0) + theme(legend.position="none")

#p4 <- p1 + xlim(0, 0.2) + ylim(-0.03,-0.010) + theme(legend.position="none")

f <- ggarrange(p2, p3, p4, common.legend = TRUE, legend="bottom",ncol = 3, nrow = 1, labels = c("A", "B", "C"))

hypo_save(filename = paste0(figure_path,out_prefix,".pdf"),
          plot = p1,
          width = 10,
          height = 10)

hypo_save(filename = paste0(figure_path,out_prefix,"_no_floridae_PC1-2.pdf"),
          plot = p2,
          width = 15,
          height = 10)

hypo_save(filename = paste0(figure_path,out_prefix,"_no_floridae_PC1-3.pdf"),
          plot = p3,
          width = 15,
          height = 10)

hypo_save(filename = paste0(figure_path,out_prefix,"_no_floridae_PC2-3.pdf"),
          plot = p4,
          width = 15,
          height = 10)

hypo_save(filename = paste0(figure_path,out_prefix,"_no_floridae.pdf"),
          plot = f,
          width = 30,
          height = 10)