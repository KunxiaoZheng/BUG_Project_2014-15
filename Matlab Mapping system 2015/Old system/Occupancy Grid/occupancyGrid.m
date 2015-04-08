% This Class defines the occupancyGrid Objects used to represent the map of
% the room. It contains the methods responsible for converting the kinect
% and 9150 data into an occupancy grid as well as methods for manipulating
% these occupancy grids. The structure of this class is ass follows:

%Class:
%                occupancyGrid
%Properties:  
%                grid
%                maxOccupancy
%Methods:
%                occupancyGrid()   
%                increaseOccupancy(...)
%                decreaseOccupancy(...)
%                buildGridFromDepthImage(...)
%                rotateSingleFrameOG(...)
%                updateMasterOG(...)
%                resetGrid(obj)


classdef occupancyGrid <handle

    properties
        grid
        maxOccupancy
    end
    
    methods
        function object = occupancyGrid()
            %This is the constructor function for this class. It assigns
            %the grid attribute to be a 400x400, 4 quadrant grid and the
            %maxOccupancy attribute to 1. 
            %maxOccupancy: is used to define the max values (+/-) of the
            %              occupancy grid.
            %grid: is where the actual occupancy grid is stored.
            
                object.grid(1:801,1:801)= 0.5;
                object.maxOccupancy = 1;
        end
        function increaseOccupancy(obj,row,column)
            %Increase an occupancyGrid object's (designated by obj) cell
            %(designated by row,column) by 0.1
            %NOTE: By changing the value from 0.1 you can effect how
            %quickly a cell gets 100% occupied
            obj.grid(row,column) = obj.grid(row,column) + 0.1;
        end
        function decreaseOccupancy(obj,row,column)
            %Decrease an occupancyGrid object's (designated by obj) cell
            %(designated by row,column) by 0.1
            %NOTE: By changing the value from 0.1 you can effect how
            %quickly a cell gets 0% occupied
            obj.grid(row,column) = obj.grid(row,column) - 0.1;
        end
        function buildGridFromDepthImage(object,averageRow)
        %This function goes through each pixel in the x-axis and uses the
        %math outlined in the final report to convert the kinect data into
        %an occupancy grid. It does this by first creating a line from the
        %origin of the grid to a given pixel and decreasing the occupancy
        %off all the cells along that line. It then increases the occupancy
        %of the cell that corresponds to the pixel.
        
        %   Ik: Is the pixel distance away from the centre line of the Kinect came
        %       to the image. (Ik is measured in cm)
        %   Jk: distance gathered from the kinect for pixel p in the kinect
        %       coordinate system (Jk is measured in cm)
            %--------------------------------------------------------------   
            %                       Initial Setup
            %--------------------------------------------------------------
            %mid stores the middle point of the occupancy grid. this used
            %to locate the origin of the room ( where the camera is
            %initiated to)
            mid = ceil((size(object.grid,2)+1)/2);
            
            
            %--------------------------------------------------------------
            %                       Update Occupancy
            %--------------------------------------------------------------
            
            % Run through all pixels in the kinect data
            for p = -319:319,

                
                 %---------------------------------------------------------   
                 %                   Defining a line in space
                 %---------------------------------------------------------
                 
                 %Ik = pixel horizontal offset within the kinect coordinate system
                 %Jk = distance gathered from the kinect for pixel i in the kinect
                 %     coordinate system                 
                
                 %define Jk
                Jk = round(averageRow(1,p+320)/10);
                
                %If Jk = 0 then distance was not recorded for that pixel and we
                %cant update anything for that ray( No Data For Pixel Recorded)
                if Jk~=0

                    %Calculate Ik value and slope 
                    Ik = (p*(Jk*tand(28.75))/320);
                    slope = Jk/Ik;
                    
                    %convert Jk to access appropriate cell in the occupancy
                    %grid matrix.
                    Jk = round(mid-Jk);
                   

                    
                    %This creates the x and y values corresponding to the camera pixel
                    %ray we are looking at ( ray i ). it creates an IkArray of length
                    %Ie containing values [0,1,2,3,4,5....Ie] and JkArray of length 
                    %Je containing the values on the line correspinging to those Ix values 
                    %(JkArray = slope*IkArray)
                    if Ik ~=0
                        if Ik>0,
                            %if Ie is positive create IeArray like [0,1,2,3...Ie] 
                            IkArray = 0:1:Ik;
                            JkArray = slope.*IkArray;
                        end
                        if Ik<0,
                            %if Ie is negative create IeArray like [Ie,Ie-1,Ie-2....-2,-1,0]
                            IkArray = round(Ik):1:0;
                            JkArray = slope.*IkArray;
                        end

                        
                        
                        for i = 1:numel(IkArray)
                            IkArray(i)=IkArray(i)+mid;
                            JkArray(i)=round(mid-JkArray(i));

                            slope = round(slope);

                            %-----------------------
                            %if slope is even(This is for the aliasing issue)
                            if rem(slope,2)==0
                               e=abs(slope/2);
                            else
                               e=abs((slope-1)/2);
                            end
                            %-----------------------    
                            
                            
                            %----------------------------------------------   
                            %                Decrease Occupancy
                            %----------------------------------------------
                            for j= JkArray(i)-e:JkArray(i)+e
                                if  j>Jk && j>0 && j<mid && object.grid(j,IkArray(i))>-(object.maxOccupancy)
                                     object.decreaseOccupancy(j,IkArray(i));
                                end
                            end
                        end 
                    end
                    %------------------------------------------------------   
                    %                    Increase Occupancy
                    %------------------------------------------------------
                    %Now write the occupied cells to the occupancy grid
                    %( the distance picked up from the kinect at each pixel

                    %Set x coordinate with respect to the middle of the occupancy grid                     
                    Ik = int16(Ik+mid);
                    
                    if Jk <= 0 
                        Jk=1;
                    end
                    %increase given pixels occupancy
                    if object.grid(Jk,Ik)<object.maxOccupancy
                        object.increaseOccupancy(Jk,Ik);
                    end
                end
            end  

        %figure;imagesc(object.grid)

        end
        function [rotatedOccupancyGrid] = rotateSingleFrameOG(object,yaw)
            %Rotate the single frame occupancy grid by the yaw value and
            %then returns the rotated occupancy grid. This is used to place
            %the occupancy grid in the same orientation as the depth camera
            
            
            %calculate the mid point of the grid
            midx = ceil((size(object.grid,2)+1)/2);
            midy = ceil((size(object.grid,1)+1)/2);
            
            %Define a temporary occupancyGrid to store the rotated grid
            rotatedOccupancyGrid(1:801,1:801)= 0.5;
            
            %for each cell in the occupancy grid, rotate said cell by the
            %measured orientation by the 9150
            for i=1:size(rotatedOccupancyGrid,1)
                for j=1:size(rotatedOccupancyGrid,2)
                    
                    %rotate a given pixel
                    x=(i-midx)*cosd(yaw)+(j-midy)*sind(yaw);
                    y=-(i-midx)*sind(yaw)+(j-midy)*cosd(yaw);
                    x=round(x)+midx;
                    y=round(y)+midy;
                    
                    %Store pixel into rotatedOccupancyGrid object
                    if(x>=1 && y>=1 && x<size(object.grid,2) && y<=size(object.grid,1) && object.grid(x,y)~=0.5)
                            rotatedOccupancyGrid(i,j) = object.grid(x,y);
                    end
                end
            end

        end
        function updateMasterOG(object,object2)
            %update the occupancygrid designated by object with the values
            %that have been recorded in object2
            
            for i=1:size(object2.grid,2)
                for j=1:size(object2.grid,1)
                    if object2.grid(i,j)~=0.5
                        
                        %If given cell is greater then max occupancyGrid,
                        %assign it the max occupancy grid value
                        if object.grid(i,j)+object2.grid(i,j)>object.maxOccupancy
                            object.grid(i,j)=object.maxOccupancy;
                        end
                        %If given cell is less then max occupancyGrid,
                        %assign it the max occupancy grid value
                        if object.grid(i,j)+object2.grid(i,j)<-object.maxOccupancy
                            object.grid(i,j)=-object.maxOccupancy;
                        else
                        %if value is within range assign said value to the
                        %corresonding cell
                            object.grid(i,j)=(object.grid(i,j)+object2.grid(i,j))/2;
                        end
                    end
                end
            end
        
        end
        function resetGrid(obj)
            %Reset the occupancy grid of obj, every cell = 0.5
            for i=1:size(obj.grid,2)
                for j=1:size(obj.grid,1)
                    obj.grid(i,j)=0.5;
                end
            end
        end
        
        function [object] = UpdateFullGrid(object,object2, dispX, dispY)
            %Update FullGrid with the values from object2
            %FullGrid is bigger than object2, so give it a "row, column"
            %displacement from the center.
            %dispX=0; % + x gives displacement right, - gives left
            %dispY=0; % + y gives displacement down, - gives up
            
            dispY = -dispY; %flip dispY so that it is +up, -down (works with the displacement calculation)
            
            %calculate the mid point of the FullGrid
            fullMidx = ceil((size(object.grid,2)+1)/2);
            fullMidy = ceil((size(object.grid,1)+1)/2);
            %calculate the mid point of the object2
            objMidx = ceil((size(object2.grid,2)+1)/2);
            objMidy = ceil((size(object2.grid,1)+1)/2);
            
            
            for i=1:size(object2.grid,2)
                for j=1:size(object2.grid,1)
                    if object2.grid(i,j)~=0.5
                        
                        %If given cell is greater then max occupancyGrid,
                        %assign it the max occupancy grid value
                        if object.grid(i+dispY+(fullMidx-objMidx),j+dispX+(fullMidy-objMidy))+object2.grid(i,j)>object.maxOccupancy
                            object.grid(i+dispY+(fullMidx-objMidx),j+dispX+(fullMidy-objMidy))=object.maxOccupancy;
                        end
                        %If given cell is less then max occupancyGrid,
                        %assign it the max occupancy grid value
                        if object.grid(i+dispY+(fullMidx-objMidx),j+dispX+(fullMidy-objMidy))+object2.grid(i,j)<-object.maxOccupancy
                            object.grid(i+dispY+(fullMidx-objMidx),j+dispX+(fullMidy-objMidy))=-object.maxOccupancy;
                        else
                        %if value is within range assign said value to the
                        %corresonding cell
                            object.grid(i+dispY+(fullMidx-objMidx),j+dispX+(fullMidy-objMidy))=(object.grid(i+dispY+(fullMidx-objMidx),j+dispX+(fullMidy-objMidy))+object2.grid(i,j))/2;
                        end
                    end
                end
            end
            
        end
        function setGridSize(object,dim)
            %This is the constructor function for this class. It assigns
            %the grid attribute to be a rowxcolumn, 4 quadrant grid and the
            %maxOccupancy attribute to 1. 
            %maxOccupancy: is used to define the max values (+/-) of the
            %              occupancy grid.
            %grid: is where the actual occupancy grid is stored.
            %row=row+1;
            %column=column+1;
            
            object.grid(1:dim,1:dim)=0.5;
            object.maxOccupancy = 1;
        end
        
        function saveGrid(object, name) %dont know if this works
            %save the given grid to a matlab variable file
            save(name,object);
        end
        function loadGrid(object, name) %dont know if this works
            %load the given grid from a matlab variable file
            load(name,object);
        end
        
        function convertToImage(object)
            imageToSave=occupancyGrid;
            for i=1:size(object.grid,2)
                for j=1:size(object.grid,1)
                    imageToSave.grid(i,j) = (object.grid(i,j) + object.maxOccupancy)/2;                    
                end
            end
            cmap=colormap('jet');
            imwrite(gray2ind(imageToSave.grid),cmap,'FullGridSave.jpg','jpg');
        end
    end
end

        

