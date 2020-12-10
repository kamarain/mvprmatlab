% [FH] = MVPR_FEATURE_PLOT(IMG, FRAMES)
%
% [fh] = mvpr_feature_plot_matches(img, frames, varargin)
%      This function creates a figure with image and correspondent image 
%      features.
%
% Outputs:
%  FH - Figure handle
%
% Examples:
%  [F1] = mvpr_feature_extract(I1);
%  mvpr_feature_plot(I1, F1);
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
function fh = mvpr_feature_plot(img, frames, varargin)

% Parse input arguments
conf = struct();
conf = mvpr_getargs(conf,varargin);

% Use current figure
%fh = figure();
imshow(img);
hold on;

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
frames = F;
% Plot frames
fh = vl_plotframe(frames);
drawnow;
hold off;
end
