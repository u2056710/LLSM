# LLSM Script Documentation

© Yara Aghabi, CAMDU Warwick, March 2021

camdu@warwick.ac.uk

This code is based on code written by Helena Coker (CAMDU, Warwick) and Anne Straube (CMCB, Warwick)

## 1 GENERAL INFORMATION
______________________________________________________________________________

### 1.1 Description

This programme is to be used for the processing of raw lattice light sheet data, and has two main features (1) deskewing and creating maximum projections of raw lattice light sheet data and (2) performing microtubule track analysis using U-track (Danuser Lab).  

The code takes a directory containing .SLD files to be analysed as input.  The programme will create a folder called “Projections” in the sample directory, in which the deskewed and maximally projected TIFs will be saved.  If you also selected U-Track analysis, the code will also create a folder called “U-Track Output” in which the U-Track output will be saved.  This U-track output contains several files, which then need to be analysed.  

### 1.2 License

This programme is free software: you can redistribute it and/or modify it under the terms of the GNU General Public License as published by the Free Software Foundation, either version 3 of the License, or (at your option) any later version.  You should have received a copy of the [GNU General Public License](https://www.gnu.org/licenses/) along with this programme.  

### 1.3 Requirements 

*This programme has been tested using the following configuration(s):*
Operating systems:   Windows 10 64-bit, Linux 20.04.2 LTS,  MacOS Catalina Version 10.15.7 
MATLAB version: 2020b 

This programme requires [Bio-Formats](https://www.openmicroscopy.org/bio-formats/downloads/) (Glencoe, Seattle, WA).  To run the U-track component of this programme, you will also need to Install [U-track software](https://github.com/DanuserLab/u-track) (Danuser Lab, Jaqaman Lab).  Note that in this case, you will also need to ensure that you have the requirements for U-Track, which can be found in the U-Track readme file.  

For optimal performance, the MATLAB [Parallel Computing Toolbox (PCT)](https://uk.mathworks.com/products/parallel-computing.html?requestedDomain=) must be installed.

### 1.4 Installation 

Start MATLAB 

Download the LLSM Processing Folder from [Github](https://github.com/u2056710/LLSM).  Extract all the files from the zip file that was downloaded and add the deskew-master folder to your MATLAB path using Set Path -> Add with Subfolders.  

Download the MATLAB toolbox from the Bio-Formats [downloads page](https://www.openmicroscopy.org/bio-formats/downloads/).  Unzip bfmatlab.zip and add the unzipped bfmatlab folder to your MATLAB path using Set Path -> Add with Subfolders.  

To run the U-track component of this programme, you will also need to Install [U-track software](https://github.com/DanuserLab/u-track).  Unzip u-track-master.zip and add the unzipped u-track-master folder to your MATLAB path using Set Path -> Add with Subfolders.  Ensure that you have the U-Track requirements.  




## 2 USAGE
______________________________________________________________________________

1. The main code is deskew.m.  Open deskew.m in MATLAB and run the code.  
2.  You will be prompted with a dialogue box asking you to pick one of the following options*:
	- deskew and max project 
	- deskew, max project, and U-Track analysis                   
3.  You will then be asked how you would like to carry out the processing, and you have to pick one of the following options*:
    - 2 (fast);  which will interpolate by 2 as part of the processing
    - 16 (medium); which will interpolate by 16 as part of the processing.  Takes approximately 2.3X longer than “fast”
    - 128 (slow); which will interpolate by 128 as part of the processing.  Takes approximately 14.4X longer than “fast”
4.  Finally, you will be asked to select the directory in which your .SLD files are in*.  
5.  The code will be executed.  

\* If you cancel or exit at any of these steps, the code will exit and you will get a warning dialogue box and will have to re-run the code and include appropriate input.    
 
### 3.1 Assumptions

This code assumes a pixel resolution of 104 nm, and a light sheet angle of 32.8&deg;.  

### 3.2 Suggested Usage

For optimal processing speed, we would recommend saving your images across several .SLD files.  For example, saving captures from your control condition into one .SLD file, and each of the conditions into .SLD files.  This allows the images to be processed in parallel.  

We would also recommend testing a large interpolation number (slow) and a fast interpolation number (fast) and checking the error associated with the different numbers for your purposes.   
 

