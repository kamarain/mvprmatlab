%MVPR_DRAWCIRCLE - Draw a filled circle
%
% mask = ddb_drawcircle(mask_, centroid_, radius_, val_)
%
% This function draws a rasterized circle.
%
% Output:
%  mask        - Mask, where the circle is drawn.
%
% Input:
%  mask_      - Mask, where the circle is drawn.
%  centroid_  - Centroid.
%  radius_    - Radius.
%  val_       - Each circle point is marked with this value.
%
% Author(s):
%    Tomi Kauppi, MVPR in 2010
%    Joni Kamarainen, MVPR in 2010.
%
% Project:
%  ImageRet (http://www.it.lut.fi/project/imageret/)
%
% Copyright:
%
%   Copyright (C) by Tomi Kauppi and Joni-Kristian Kamarainen.
%
% References:
%  [1] Kauppi, T., Eye Fundus Image Analysis for Automatic
%  Detection of Diabetic Retinopathy, PhD Thesis, Department of
%  Information Technology, Lappeenranta University of Technology,
%  2010.
%
% See also DDB_MARKING2MASK.M, DDB_DRAWPOLYGON.M, DDB_DRAWELLIPSE.M
% and DDB_FLOODFILL.M .
%
function mask = mvpr_drawcircle(mask_, centroid_, radius_, val_)

imgSize = size(mask_);

if  centroid_(1) - radius_ > 1
   xmin = centroid_(1) - radius_;
else 		
   xmin = 1;
end
	
if centroid_(1) + radius_ < imgSize(2)
   xmax = centroid_(1) + radius_;
else 		
   xmax = imgSize(2);
end
	
x = xmin:xmax;

for j = 1:size(x,2)
   y_up   =  round(sqrt(radius_^2 - (x(j)-centroid_(1)).^2) + centroid_(2));
   y_down =  round(-sqrt(radius_^2 - (x(j)-centroid_(1)).^2) + centroid_(2));
   if y_up > imgSize(1)
      y_up = imgSize(1);
   end
   if y_down < 1
      y_down = 1;
   end
   mask_(y_down:y_up, x(j)) = val_;
   tmp = size(y_down:y_up,2);
end

mask = mask_;
