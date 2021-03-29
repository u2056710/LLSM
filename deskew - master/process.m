%This function processes images by both deskewing them and maximally
%projecting them, interpolating by a certain factor depending on user input
%(interp_by)

function [output2] = process(array, high, wide, nFrames, shift, interp_by)
%process(array, stackSizeY, stackSizeZ, stackSizeZ, shift)

    shift = round((shift*interp_by)/10);
    x_orig = [1:1:wide];                       % setup vectors for interpolation - original 
    a = 1/interp_by;
    x_mod = [(1-a/2):a:(wide+a/2)];            % and 10X
    expanded = wide*interp_by + (nFrames-1)*shift;    % calculate expanded size
    output = zeros(expanded, high);            % size of projected image with 104x43.7nm pixels
    
    for i = 1:nFrames                          %iterate through each of the planes
        A = array{i, 1};                       %array contains all of the planes so extract the plane
        A = transpose(A);
        Vq = interp1(x_orig,A,x_mod,'pchip');  % interpolate each line by appropriate amount
        
        for j = 1:size(Vq, 2)                      
            
         for n = 1:(length(x_mod))
               if Vq(n, j) >= output((shift*(i-1) + n), j)
                    output ((shift*(i-1)+n), j)=Vq(n, j);
                    
                end
            end
        end
    end
    
        
 % Make pixels square again.
        
    x_mod = [1:1:expanded];                         %set up new vector for interpolated numbers
    x_final = [1:(104/(87/interp_by)):expanded];                   %create final vector for back-interpolation
    output2 = zeros(high,length(x_final));          %make emtpy array of zeros with appropriate dimensions
    
                                                
    Vq = interp1(x_mod,output,x_final,'pchip');    %and back interpolate
    output2 = transpose(Vq);                       %transpose back
 
    output2 = uint16(output2);              %convert output to 16-bit array
    
end


    
     



 







 


