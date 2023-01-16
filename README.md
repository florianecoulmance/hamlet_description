# Code repository for: *A review of 263 years of taxonomic research on Hypoplectrus (Perciformes: Serranidae), with a redescription of Hypoplectrus affinis (Poey, 1861)*

This repository contains the original bioinformatic analysis behind the paper *A review of 263 years of taxonomic research on Hypoplectrus (Perciformes: Serranidae), with a redescription of Hypoplectrus affinis (Poey, 1861)* by Puebla, Coulmance, Estapé, Estapé and Robertson.<br> 
It covers all steps of genotyping and phylogeny based on raw sequencing data to the final plotting of the figures used within the publication.<br>

## Setup

In this folder, you will need all necessary files and subfolders to be able to run the different pipelines.
The folder tree is:<br> 

```
.
├── R
├── figures
├── metadata
├── genotyping.sh
├── dxy.sh
├── pdist.sh
├── phylogeny.sh

```

All the output files and figures will be created by the various pipelines.<br> 
All figures presented in the paper will be found in the ```figures/``` folder.<br> 

All necessary code for each of these pipelines is found in folders ```R/```<br> 
The pipelines are all the files finishing by ```.sh``` in the root folder.<br> 
