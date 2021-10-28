#!/usr/bin/env Rscript
# by: Floriane Coulmance: 14/10/2021
# usage:
# Rscript 
# -------------------------------------------------------------------------------------------------------------------
#
# -------------------------------------------------------------------------------------------------------------------


# Clear the work space
rm(list = ls())

# libraries -----------------------
library(GenomicOriginsScripts)
library(hypoimg)
library(hypogen)
library(ape)
library(ggtree)
library(ggplot2)
library(ggpubr)
library(ggtext)
library(tidygraph)
library(ggraph)
library(patchwork)

# arguments -----------------------
# args <- commandArgs(trailingOnly = FALSE)
# args = args[6]
# tree_hypo_file <- as.character(args[1])

tree_hypo_coi <- "/Users/fco/Desktop/PhD/HAMLET_DESCRIPTION_PAPER/hamlet_description/coi_filterd.raxml.support"

tree_hypo_file <- "/Users/fco/Desktop/PhD/HAMLET_DESCRIPTION_PAPER/hamlet_description/snp_filterd_0.33_mac2_5kb_nhp.raxml.support"


# library(tidyverse)
# library(ggtree)
# 
# tree <- read.tree(text = "(((A, B), (C, D)), E);")
# 
# tree_grouped <- groupClade(tree, .node = c(8, 9), group_name =  "clade")
# 
# clade_label <- c( '0' = "none", '1' = "AB", '2' = "CD")

# ggtree(tr = tree_grouped, aes(color = clade_label[clade])) +
#   geom_tiplab() +
#   geom_nodelab(aes(label = node), color =  "red")
# 

raxml_tree <- read.tree(tree_hypo_file) 
raxml_coi <- read.tree(tree_hypo_coi)

raxml_tree_rooted <- root(phy = raxml_tree, outgroup = "PL17_160floflo")
raxml_coi_rooted <- root(phy = raxml_coi, outgroup = "PL17_160floflo")

# g1 <- ggtree(raxml_coi_rooted, branch.length = "none") + geom_text2(aes(subset=!isTip, label=node), hjust=-.3, size = 1) + geom_tiplab(size=2)
# viewClade(g1+geom_tiplab(), node=66)

clr_neutral <- rgb(.6, .6, .6)
lyout <- 'circular'

raxml_tree_rooted_grouped <- groupClade(raxml_tree_rooted,
                                        .node = c(67, 49, 53, 52),
                                        group_name =  "clade")

clade2spec <- c( `0` = "none", `1` = "nig", `2` = "pue", `3` = "uni", `4` = "gum")

raxml_data <- ggtree(raxml_tree_rooted_grouped, layout = lyout) %>%
   .$data %>%
    mutate(spec = ifelse(isTip, str_sub(label, -6, -4), "ungrouped"),
          support = as.numeric(label),
          support_class = cut(support, c(0,50,70,90,100)) %>%
                          as.character() %>% factor(levels = c("(0,50]", "(50,70]", "(70,90]", "(90,100]")),
          label = case_when(
            endsWith(label, "nigpan") ~ "nigricans",
            endsWith(label, "unipan") ~ "unicolor",
            endsWith(label, "puepan") ~ "puella",
            endsWith(label, "abepan") ~ "aberrans",
            endsWith(label, "gumpan") ~ "gummiguta",
            endsWith(label, "tanpan") ~ "affinis",
            endsWith(label, "floflo") ~ "floridae"))

coi_data <- ggtree(raxml_coi_rooted, branch.length = "none", layout = lyout) %>%
  .$data %>%
  mutate(spec = ifelse(isTip, str_sub(label, -6, -4), "ungrouped"),
         support = as.numeric(label),
         clade = case_when(
           endsWith(spec,"ungrouped") ~ 0,
           endsWith(spec,"nig") ~ 1,
           endsWith(spec,"pue") ~ 2,
           endsWith(spec,"uni") ~ 3,
           endsWith(spec,"gum") ~ 4,
           endsWith(spec,"abe") ~ 0,
           endsWith(spec,"flo") ~ 0,
           endsWith(spec,"tan") ~ 0),
         support_class = cut(support, c(0,50,70,90,100)) %>%
           as.character() %>% factor(levels = c("(0,50]", "(50,70]", "(70,90]", "(90,100]")),
         label = case_when(
           endsWith(label, "nigpan") ~ "nigricans",
           endsWith(label, "unipan") ~ "unicolor",
           endsWith(label, "puepan") ~ "puella",
           endsWith(label, "abepan") ~ "aberrans",
           endsWith(label, "gumpan") ~ "gummiguta",
           endsWith(label, "tanpan") ~ "affinis",
           endsWith(label, "floflo") ~ "floridae")
  )


lab2spec <- function(label) {
  x <- stringr::str_sub(label, start = 0, end = 3) %>% stringr::str_remove(., 
                                                                           "[0-9.]{1,3}$") %>% stringr::str_remove(., " ")
  ifelse(x == "", "ungrouped", x)
  
}


logos_spec <- c(abe = "<img src='/Users/fco/Desktop/PhD/1_CHAPTER1/0_IMAGES/after_python/logos/H_aberrans.l.cairo.png' width='70' /><br>*H. aberrans*",
                chl = "<img src='/Users/fco/Desktop/PhD/1_CHAPTER1/0_IMAGES/after_python/logos/H_chlorurus.l.cairo.png' width='70' /><br>*H. chlorurus*",
                flo = "<img src='/Users/fco/Desktop/PhD/1_CHAPTER1/0_IMAGES/after_python/logos/H_floridae.l.cairo.png' width='70' /><br>*H. floridae*",
                gem = "<img src='/Users/fco/Desktop/PhD/1_CHAPTER1/0_IMAGES/after_python/logos/H_gemma.l.cairo.png' width='70' /><br>*H. gemma*",
                gum = "<img src='/Users/fco/Desktop/PhD/1_CHAPTER1/0_IMAGES/after_python/logos/H_gumigutta.l.cairo.png' width='70' /><br>*H. gummiguta*",
                gut = "<img src='/Users/fco/Desktop/PhD/1_CHAPTER1/0_IMAGES/after_python/logos/H_guttavarius.l.cairo.png' width='70' /><br>*H. guttavarius*",
                ind = "<img src='/Users/fco/Desktop/PhD/1_CHAPTER1/0_IMAGES/after_python/logos/H_indigo.l.cairo.png' width='70' /><br>*H. indigo*",
                may = "<img src='/Users/fco/Desktop/PhD/1_CHAPTER1/0_IMAGES/after_python/logos/H_maya.l.cairo.png' width='70' /><br>*H. maya*",
                nig = "<img src='/Users/fco/Desktop/PhD/1_CHAPTER1/0_IMAGES/after_python/logos/H_nigricans.l.cairo.png' width='70' /><br>*H. nigricans*",
                pue = "<img src='/Users/fco/Desktop/PhD/1_CHAPTER1/0_IMAGES/after_python/logos/H_puella.l.cairo.png' width='70' /><br>*H. puella*",
                ran = "<img src='/Users/fco/Desktop/PhD/1_CHAPTER1/0_IMAGES/after_python/logos/H_randallorum.l.cairo.png' width='70' /><br>*H. randallorum*",
                aff = "<img src='/Users/fco/Desktop/PhD/1_CHAPTER1/0_IMAGES/after_python/logos/H_tan.l.cairo.png' width='70' /><br>*H. affinis*",
                uni = "<img src='/Users/fco/Desktop/PhD/1_CHAPTER1/0_IMAGES/after_python/logos/H_unicolor.l.cairo.png' width='70' /><br>*H. unicolor*",
                ungrouped = "*not a clade*")

p_tree <- (open_tree(
    ggtree(raxml_data, layout = lyout,
           aes(color = ifelse(clade == 0,
                              lab2spec(label),
                              clade2spec[as.character(clade)])), size = .55) %>%
      ggtree::rotate(44), 180))  +
  # geom_tippoint(size = .2) +
  geom_tiplab2(aes(color = lab2spec(label), label = label),
               size = 2.5,
               hjust = -.1) + 
  ggtree::geom_treescale(width = .03,
                         linesize = .2,
                         x=0.04,
                         # offset = -0.000001,
                         fontsize = GenomicOriginsScripts::plot_text_size / ggplot2:::.pt,
                         color = clr_neutral) +
  # xlim(c(-.2,.2)) +
  ggtree::geom_nodepoint(aes(fill = support_class,
                             size = support_class),
                         shape = 21#, linewidth = 3
  ) +
  scale_color_manual(values = c(ungrouped = clr_neutral,
                                abe = "#000000", 
                                gum = "#E69F00",
                                nig = "#009E73",
                                pue = "#F0E442",
                                aff = "#0072B2",
                                uni = "#CC79A7",
                                flo = "#ABA7C4"),
                     labels = logos_spec,
                     guide = "none") +
  scale_fill_manual(values = c(`(0,50]` = "transparent",
                               `(50,70]` = "white",
                               `(70,90]` = "gray",
                               `(90,100]` = "black"),
                    drop = FALSE,
                    guide = "none") +
  scale_size_manual(values = c(`(0,50]` = 0.8,
                               `(50,70]` = 1.6,
                               `(70,90]` = 1.6,
                               `(90,100]` = 1.6),
                    na.value = 0,
                    drop = FALSE,
                    guide = "none")+
  guides(color = guide_legend(title = "Species", title.position = "top", ncol = 4, keyheight = unit(9,"pt")),
         fill = guide_legend(title = "Node Support Class", title.position = "top", ncol = 2,keyheight = unit(9,"pt")),
         size = guide_legend(title = "Node Support Class", title.position = "top", ncol = 2,keyheight = unit(9,"pt"))) +
  theme_void(base_size = GenomicOriginsScripts::plot_text_size_small) +
  theme()


y_sep <- .005
x_shift <- -.003
p1 <- ggplot() +
  coord_equal(xlim = c(-0.1, 1.3),
              ylim = c(-.01, .54),
              expand = 0) +
  annotation_custom(grob = ggplotGrob(p_tree + theme(legend.position = "bottom", text = element_text(size=15), legend.text =  element_markdown(size = 15))),
                    ymin = -.6 + (.5 * y_sep), ymax = .6 + (.5 * y_sep),
                    xmin = -.1, xmax = 1.1) +
  # annotation_custom(grob = cowplot::get_legend(p_tree),
  #                   ymin = .25, ymax = .44,
  #                   xmin = 0, xmax = .2) +
  theme_void()




c_tree <- (open_tree(
  ggtree(coi_data, branch.length = 'none', layout = lyout, aes(color = ifelse(clade == 0,
                                                              lab2spec(label),
                                                              clade2spec[as.character(clade)])),
    size = 0.55) %>%
    ggtree::rotate(44), 180)) +
  # geom_tippoint(size = .2) +
  geom_tiplab2(aes(color = lab2spec(label), label = label),
               size = 5.5,
               hjust = -.1) + 
  ggtree::geom_treescale(width = .002,
                         linesize = .2,
                         x = -.0007, y = 100,
                         offset = -4,
                         fontsize = GenomicOriginsScripts::plot_text_size / ggplot2:::.pt,
                         color = clr_neutral) +
  # xlim(c(-.2,.2)) +
  ggtree::geom_nodepoint(aes(fill = support_class,
                             size = support_class),
                         shape = 21#, linewidth = 3
                         ) +
  scale_color_manual(values = c(ungrouped = clr_neutral,
                                abe = "#000000", 
                                gum = "#E69F00",
                                nig = "#009E73",
                                pue = "#F0E442",
                                aff = "#0072B2",
                                uni = "#CC79A7",
                                flo = "#ABA7C4"),
                     guide = "none") +
  scale_fill_manual(values = c(`(0,50]` = "transparent",
                               `(50,70]` = "white",
                               `(70,90]` = "gray",
                               `(90,100]` = "black"),
                    drop = FALSE,
                    guide = "none") +
  scale_size_manual(values = c(`(0,50]` = 0.8,
                               `(50,70]` = 1.6,
                               `(70,90]` = 1.6,
                               `(90,100]` = 1.6),
                    na.value = 0,
                    drop = FALSE,
                    guide = "none")+
  guides(color = guide_legend(title = "Species", title.position = "top", ncol = 4, keyheight = unit(9,"pt")),
         fill = guide_legend(title = "Node Support Class", title.position = "top", ncol = 2,keyheight = unit(9,"pt")),
         size = guide_legend(title = "Node Support Class", title.position = "top", ncol = 2,keyheight = unit(9,"pt"))) +
  theme_void(base_size = GenomicOriginsScripts::plot_text_size) +
  theme(legend.text = element_markdown())


y_sep <- .005
x_shift <- -.003
p2 <- ggplot() +
  coord_equal(xlim = c(-0.1, 1.3),
              ylim = c(-.01, .54),
              expand = 0) +
  annotation_custom(grob = ggplotGrob(c_tree + theme(legend.position = "none", text = element_text(size=15), legend.text =  element_markdown(size = 15))),
                    ymin = -.6 + (.5 * y_sep), ymax = .6 + (.5 * y_sep),
                    xmin = -.1, xmax = 1.1) +
  # annotation_custom(grob = cowplot::get_legend(c_tree),
  #                   ymin = 0.2, ymax = 1,
  #                   xmin = 0, xmax = .2) +
  theme_void()

p_done <- (p1 + p2) + guide_area() +
  plot_annotation(tag_levels = "a") +
  plot_layout(heights = c(0.8, 0.3),
              guides = "collect") +
  theme(text = element_text(size = GenomicOriginsScripts::plot_text_size),
        # plot.tag.position = c(0, 1),
        legend.position = "bottom",
        legend.key = element_blank(),
        legend.direction = "horizontal",
        legend.background = element_blank(),
        legend.box = "horizontal", 
        legend.text.align = 0)

hypo_save(plot = p_done,
          filename = "/Users/fco/Desktop/PhD/HAMLET_DESCRIPTION_PAPER/hamlet_description/F4.png",
          width = 21,
          height = 11,
          bg = "transparent",
          type = "cairo",
          dpi = 600,
          comment = plot_comment)

p_done
