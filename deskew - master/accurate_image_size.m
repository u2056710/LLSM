function [imagesize] = accurate_image_size(voxelSizeZ,  stackSizeX, stackSizeZ)

    imagesize = ((voxelSizeZ/87)*(stackSizeZ-1)+stackSizeX)/(104/87);
 
    
end 

