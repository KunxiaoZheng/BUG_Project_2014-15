function [row,col,success] = get_cell(x,y,x_grid,y_grid)
%Function [row,col,success] = get_cell(x,y) 
% 
% Computed cell row and col indeces such that (x,y) lies within the cell
% Map(y_grid(row),x_grid(col)), where Map() is the environmental map.
% Success is returned as zero if (x,y) lies outside of the map (and
% row=col=-1), and success = 1 otherwise.
%

if ((x <= x_grid(1)) || (x >= x_grid(end)) || (y <= y_grid(1)) || y >= y_grid(end))
   success = 0;
   col = -1;
   row = -1;
else
  [~,this_row] = max(x_grid > x);
  [~,this_col] = max(y_grid > y);
  col=this_col; %took out the -1 so we would not get 0 values
  row=this_row; %
  success = 1;
end;


