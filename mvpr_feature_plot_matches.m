% [FH] = MVPR_FEATURE_PLOT_MATCHES(IMG, FRAMES, MATCHES)
%
% [fh] = mvpr_feature_plot_matches(img, frames, matches, varargin)
%      This function creates a figure with images and correspondent matches.
%      Matches between images can be aquired by giving images and frames in
%      cell format. See example.
%
% Outputs:
%  FH - Figure handle
%
% Examples:
%  [F1] = mvpr_feature_extract(I1);
%  [F2] = mvpr_feature_extract(I2);
%  [matches] = mvpr_feature_match(F1, F2);
%  mvpr_feature_plot_matches({I1 I2},{F1 F2}, matches);
%
%
% Authors:
%  Jukka Lankinen
%
% Project:
%  -
%
% References:
%  -
%
function fh = mvpr_feature_plot_matches(img, frames, matches, varargin)

% Parse input arguments
conf = struct();
conf = mvpr_getargs(conf,varargin);

% validatate input
if ~iscell(img) % not a cell -> only one image
	img = {img};
	frames = {frames};
	matches = matches;
end
if size(img,2) > 2
	error('Too many input images');
end

% If there are 2 images
if size(img, 2) == 2 
	if size(matches, 1) < 2
		error('Not enough matching points');
	end
	if size(img{2},1) > size(img{1},1)
		sizeY = size(img{2},1);
	else
		sizeY = size(img{1},1);
	end
	sizeX = (size(img{1},2) + size(img{2},2));
	sizeZ = size(img{1},3);
	
	mImg = zeros(sizeY, sizeX, sizeZ);
	
	mImg(1:size(img{1},1), 1:size(img{1},2),1:sizeZ) = img{1};
	mImg(1:size(img{2},1), size(img{1},2):(size(img{1},2)-1+size(img{2},2)),:) = img{2};
	mImg = uint8(mImg);
else
	% Create image
	mImg = img{1};	
end

% Plot image
% Create figure
fh = figure();
imshow(mImg);
hold on;
% Plot frames
frames{1} = convert_frames(frames{1});
vl_plotframe( frames{1}(:,matches(1,:)) );

% second image
if size(img, 2) == 2 
	
	% convert
	frames{2} = convert_frames(frames{2});
	% move points
	fs = frames{2}(:,matches(2,:));
	fs(1,:) = fs(1,:) + size(img{1},2);
	
	% plot frames
	vl_plotframe(fs);
	
	for i = 1:size(matches,2)
		line = [frames{1}(1,matches(1,i)) frames{1}(2,matches(1,i)); ...
	        size(img{1},2)+frames{2}(1,matches(2,i)) frames{2}(2,matches(2,i))];
		plot(line(:,1), line(:,2),'b-','MarkerSize',10,'LineWidth',3);
	end
end
drawnow;
hold off;
end

function F = convert_frames(frames)
F = frames;
for l = 1:size(F,2)
	a = F(3,l);
	b = F(4,l);
	c = F(5,l);
	
	[v e] = eig([a b;b c]);
	
	l1 = 1/sqrt(e(1));
	l2 = 1/sqrt(e(4));
	F(3,l) = l1*v(1);
	F(4,l) = l1*v(2);
	
	F(5,l) = l2*v(3);
	F(6,l) = l2*v(4);
end
%frames = F;
end % end convert_frames
