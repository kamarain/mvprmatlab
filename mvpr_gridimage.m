%MVPR_GRIDIMAGE Plot a set of images into a bigger image as grid
%
% [img] = mvpr_gridimage(imgSz_,grids_,imgs_)
%
% This function returns img of size imgSz_, which is divided to
% grids_ grid horizontally and vertically and images listed in
% imgs_ are loaded and plotted to the grid.
%
% Inputs:
%  imgSz_  - Image size in [columns rows]
%  grids_  - [N M] N horizontal (columns) and M vertical (rows)
%            grid
%  imgs_   - Cell array (imgs_{1}, imgs_{2}, ...) of images to be
%            plotted on the grid (horizontal first) (may contain
%            empty entries, which are not plotted)
%
% <Optional>
%  'emph'      - If set to one of categories, then this will be
%                emphasised (DEFAULT: 0 (i.e., none)).
%  'gridImage' - If this is given (already existing grid image), then
%                it only updated (e.g. 'emph' for emphasising one of
%                them)
%
% Outputs:
%  img     - Output image
%
% Authors:
%   Joni Kamarainen, MVPR in 2010
%
% Project:
%   VisiQ
%
% References:
%
% -
%
% See also .
%
function [img] = mvpr_gridimage(imgSz_,grids_,imgs_,varargin)

conf = struct('emph', 0, 'gridImage',[]);
conf = mvpr_getargs(conf, varargin);

if (isempty(conf.gridImage) == false)
    img = conf.gridImage;
else
    img = uint8(zeros(imgSz_(2),imgSz_(1),3));
end;

gridLeftUpX = 1:round(imgSz_(1)/grids_(1)):imgSz_(1)-round(imgSz_(1)/grids_(1))+1;
gridLeftUpY = 1:round(imgSz_(2)/grids_(2)):imgSz_(2)-round(imgSz_(2)/grids_(2))+1;
gridRightBottomX = imgSz_(1)+1-gridLeftUpX;
gridRightBottomX = gridRightBottomX(end:-1:1);
gridRightBottomY = imgSz_(2)+1-gridLeftUpY;
gridRightBottomY = gridRightBottomY(end:-1:1);

for yInd = 1:grids_(2)
    for xInd = 1:grids_(1)
        szX = gridRightBottomX(xInd)-gridLeftUpX(xInd)+1;
        szY = gridRightBottomY(yInd)-gridLeftUpY(yInd)+1;
        if ((length(imgs_) >= (yInd-1)*grids_(1)+xInd) || ~isempty(conf.gridImage))
            if (isempty(conf.gridImage))
                if (isempty(imgs_{(yInd-1)*grids_(1)+xInd}))
                    continue;
                end;
            end;
            if (isempty(conf.gridImage))
                newImg = imread(imgs_{(yInd-1)*grids_(1)+xInd});
                %szX = gridRightBottomX(xInd)-gridLeftUpX(xInd)+1;
                %szY = gridRightBottomY(yInd)-gridLeftUpY(yInd)+1;
                if (szY/size(newImg,1) <= szX/size(newImg,2))
                    newImg = imresize(newImg,[szY NaN]);
                else
                    newImg = imresize(newImg,[NaN szX]);
                end
                % re-computed correct ones
                newszX = size(newImg,2);
                newszY = size(newImg,1);
                
                if size(newImg,3) == 1
                    newImg = repmat(newImg,[1 1 3]);
                end;
                img(gridLeftUpY(yInd):gridLeftUpY(yInd)+newszY-1,...
                    gridLeftUpX(xInd):gridLeftUpX(xInd)+newszX-1,:)=...
                    newImg;
                imshow(img);
            end;

            if ( ((yInd-1)*grids_(1)+xInd) == conf.emph)
                emphDim = 1; % RED
            else
                emphDim = 2; % GREEN
            end;
            % Draw borders vertical left
            img(gridLeftUpY(yInd):gridLeftUpY(yInd)+szY-1,...
                gridLeftUpX(xInd):gridLeftUpX(xInd)+3,1:3)=0;
            img(gridLeftUpY(yInd):gridLeftUpY(yInd)+szY-1,...
                gridLeftUpX(xInd):gridLeftUpX(xInd)+3,emphDim)=255;
            % Draw borders vertical right
            img(gridLeftUpY(yInd):gridLeftUpY(yInd)+szY-1,...
                gridLeftUpX(xInd)+szX-3:gridLeftUpX(xInd)+szX,1:3)=0;
            img(gridLeftUpY(yInd):gridLeftUpY(yInd)+szY-1,...
                gridLeftUpX(xInd)+szX-3:gridLeftUpX(xInd)+szX,emphDim)=255;
            % Draw borders horizontal up
            img(gridLeftUpY(yInd):gridLeftUpY(yInd)+3,...
                gridLeftUpX(xInd):gridLeftUpX(xInd)+szX-1,1:3)=0;
            img(gridLeftUpY(yInd):gridLeftUpY(yInd)+3,...
                gridLeftUpX(xInd):gridLeftUpX(xInd)+szX-1,emphDim)=255;
            % Draw borders horizontal down
            img(gridLeftUpY(yInd)+szY-3:gridLeftUpY(yInd)+szY,...
                gridLeftUpX(xInd):gridLeftUpX(xInd)+szX-1,1:3)=0;
            img(gridLeftUpY(yInd)+szY-3:gridLeftUpY(yInd)+szY,...
                gridLeftUpX(xInd):gridLeftUpX(xInd)+szX-1,emphDim)=255;
        end;
    end;
end;