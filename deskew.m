%This programme is to be used for the processing of raw lattice light sheet 
% data.  This code has two main features (1) deskewing and creating maximum 
% projections of raw lattice light sheet data and (2) performing microtubule 
% track analysis using U-track (Danuser Lab).  

% INPUT: a directory containing .SLD files to be analysed 
% OUTPUT: the programme will create a folder called “Projections” in the 
% input directory, in which the deskewed and maximally projected TIFs will 
% be saved.  If you also selected U-Track analysis, the code will also create 
% a folder called “U-Track Output” in which the U-Track output will be saved.  
% This U-track output contains several files, which then need to be analysed.  

% (C) Yara Aghabi, CAMDU Warwick, March 2021
 

%% Getting Started

%ask user if they want to either:
    % deskew and max project
    % deskew and max project and U-track analysis
    list = {'deskew and max project', 'deskew, max project, and U-Track analysis'};
    [indx,tf] = listdlg('PromptString',{'Pick one option:'},'ListString', list);
    analysis_type = string(list(indx));  

    % if they didn't enter an option give an error
    if isempty(analysis_type)
    message = sprintf('You must select an option.  Try again.', analysis_type);
    uiwait(warndlg(message));
    return;
    end
    
%ask user if they would like the images to be interpolated by 2, 8, or 16
%and store answer as double in variable called interpolation
    list = {'2 (fast)', '16 (medium)', '128 (slow)'};
    [indx,tf] = listdlg('PromptString',{'Interpolate by:'},'ListString', list);
    answer = string(list(indx));
 
    interp_by = []; 

    if (answer) == '2 (fast)'
        interp_by = 2;
    end
    if (answer) == '16 (medium)'
        interp_by = 16;
    end
    if (answer) == '128 (slow)'
        interp_by = 128;
    end

    % if they didn't enter an option give an error
    if isempty(interp_by)
    message = sprintf('You must select an interpolation option.  Try again.', interp_by);
    uiwait(warndlg(message));
    return;
    end 

    
 %get input directory containing .SLD files for processing
    sample = uigetdir(pwd, 'Pick input directory');
    if sample == 0
     message = sprintf('You must select a directory.  Try again', sample);
     uiwait(warndlg(message));
     return;
    end 

    
%% Perform approrpriate function(s) based on input 

    if analysis_type == 'deskew and max project'
        deskew_and_project(sample, interp_by);
    end 
    
    if analysis_type == 'deskew, max project, and U-Track analysis'
        deskew_and_project(sample, interp_by);
        UTrack_Processing(sample);
    end
    
 %% Deskew and max-project function
    
 function [] = deskew_and_project(sample, interp_by)
    
    % create an output directory called "Projections"
    outputdir = [sample '/Projections']; 
    if ~exist(outputdir,'dir')
        mkdir(outputdir);
    end
    
    % get list of items in directory ending with .sld
    datafiles = dir([sample '/*.sld']);
    
    % iterate through each .sld file
    parfor k = 1:length(datafiles)
       
        if datafiles(k).isdir == 0   %only work on .sld files (ignore folders ending in .sld)
        
        %create subdirectory inside 'projections', for this .SLD file
        folder = datafiles(k).name
        folder = folder(1:end-4)            % exclude .sld at end of name
        sub_folder = [outputdir '/' folder]
        if ~exist(sub_folder,'dir')
            mkdir(sub_folder);
        end
        
        %get file path of .SLD file and access the file reader
        filepath = [sample '/' datafiles(k).name];  
        r = bfGetReader(filepath);                  

        %access the OME metadata and get number of series
        omeMeta = r.getMetadataStore();            
        nSeries = r.getSeriesCount();               
 
        %iterate through each of the series inside the .SLD file    
        for series = 1:nSeries
            
            %switch between series and load that series
            r.setSeries(series - 1);      
            r.getSeries();                 

            %get metadata and extract important features
            omeMeta = r.getMetadataStore();    
            stackSizeX = omeMeta.getPixelsSizeX(0).getValue();      %image width in pixels
            stackSizeY = omeMeta.getPixelsSizeY(0).getValue();      %image height in pixels
            stackSizeZ = omeMeta.getPixelsSizeZ(0).getValue();      %number of frames (Z stacks)
            timepoints = omeMeta.getPixelsSizeT(0).getValue();      %number of time-points
            series_name = omeMeta.getImageName(series-1);           %series name
            voxelSizeZ = omeMeta.getPixelsPhysicalSizeZ(0).value(ome.units.UNITS.MICROMETER); %shift size in micrometers
            voxelSizeZ = double(voxelSizeZ) * 1000; %voxel size in nm
            shift = ((voxelSizeZ/87)*10)     %calculate shift (which is used in the processing);
            TimeInterval= double(omeMeta.getPixelsTimeIncrement(0))
   
            %create another sub-directory for this series
            sub_output_dir = append(sub_folder, '/', string(series_name));
            if ~exist(sub_output_dir,'dir')
            mkdir(sub_output_dir);
            end
            
            %get the accurate image size
            accurate_image_size(voxelSizeZ,  stackSizeX, stackSizeZ);

            %iterate through each of the time-points
            for tpoint = 2:timepoints 
                      
               %print progress
               [datafiles(k).name ': Processing series ' num2str(series) ' of ' num2str(nSeries) ': Processing timepoint ' num2str(tpoint,'%02d') '/' num2str(timepoints,'%02d') ':']
        
               %Using bioformats GetPlane we can retrieve a plane given a 
               %set of (z, c, t) coordinates, which we have to linearise
               %using get.Index.  You have to use T = T-1, C=C-1, and 
               %Z=Z-1:
               T = tpoint - 1;          %get T coordinate for index
               C = 1 - 1;               %get C (channel) coordinate for index(only one!)
               %we will get the Z coordinate in the next for loop
                     
               
               %We need to store all of Z-stacks of this time-point
               %in an array to be processed later, so set up and empty array 
               %and start a count
               count = 1;               
               array = {};
 
               %iterate through all the Z-stacks 
               for Z_plane = 1:stackSizeZ
                    Z = Z_plane - 1;       %get Z coordinate for index

                    %Use the index to read in the specific plane and
                    %convet to double
                    plane = bfGetPlane(r, r.getIndex(Z, C, T) +1);     
                    plane = double(plane);

                    %add plane to array at position (count, 1)(in essence 
                    %you are appending the array) and add 1 to count
                    array{count, 1} = plane;
                    count = count + 1;
                           
               end

               %Deskew and maximally project the output using the
               %process function and save as TIF in appropriate
               %subdirectory.  
               output = process(array, stackSizeY, stackSizeX, stackSizeZ, shift, interp_by);
               
                
               newname = append(sub_output_dir, '/', string(series_name), '_T=', num2str(tpoint, '%04.f'), '.tif');
               imwrite(output, newname);
                
               %reset array and counts 
               array = {};
               count = 1;
                     
            end
        end
        end
    end
    ['DONE DESKEWING AND CREATING MAX PROJECTIONS.']
 end
    
 %% U Track Function 
    
 function  [] = UTrack_Processing(sample)
    
    %get into projections subdirectory and get list of folders inside that
    projections_dir = [sample '/Projections'];
    
    %get sub-folders
    sld_folders = dir([projections_dir]);
    sld_folders = sld_folders(~startsWith({sld_folders.name}, '.'));
    
    %make subdirectory for making movies
    output_dir = [sample, '/U-Track Output']; 
    if ~exist(output_dir,'dir')
    mkdir(output_dir);
    end
    
    %iterate through each of those folders
    parfor k = 1:length(sld_folders)
        
        sld_dir = [output_dir, '/' sld_folders(k).name];
        
        if ~exist(sld_dir,'dir')
            mkdir(sld_dir);
        end
        
        all_stacks = dir([projections_dir '/' sld_folders(k).name]);
        all_stacks = all_stacks(~startsWith({all_stacks.name}, '.'));
        
        
        %iterate through the series
        
        for n = 1:length(all_stacks)
            
            series_dir = [sld_dir, '/' all_stacks(n).name];
            
            if ~exist(series_dir,'dir')
            mkdir(series_dir);
            end
            
            imageDir = [projections_dir '/' sld_folders(k).name '/' all_stacks(n).name '/'];
            filenameBase = [all_stacks(n).name '_T='];
            f = dir([imageDir, '/*.tif']);
            nfiles = length(f(not([f.isdir])));
        
            %detect
            [movieInfo,exceptions,localMaxima,background,psfSigma] = trackdetect(imageDir, filenameBase, nfiles);
            
            %track 
            [tracksFinal,kalmanInfoLink,errFlag] = trackgeneral(movieInfo);
            
            %convert data
            [trackedFeatureInfo, trackedFeatureIndx, trackStartRow, numSegments] = convStruct2MatIgnoreMS(tracksFinal);
         
            %save data 
            savedata(series_dir, trackedFeatureInfo, trackedFeatureIndx, trackStartRow, numSegments, tracksFinal)
           
            %overlay
            first_file = append(imageDir, all_stacks(n).name, '_T=0001.tif');  
            overlayTracksMovieNew(tracksFinal, [], 1000000, 1, all_stacks(n).name, [], 0, 0, 0, [], 0, 0, [], 1, 1, first_file, series_dir, 1, 1, 'avi');
            
        end
            
    end
    
 end
   

    %% END OF SCRIPT.  