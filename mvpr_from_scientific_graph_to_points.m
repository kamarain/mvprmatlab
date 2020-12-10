% [p_img p_user p_graph p_est] = mvpr_from_scientific_graph_to_points(img_)
%
% Are you tired to try to find a method executable or make the
% existing work or just too close to the deadline that you could
% replicate the results from your enemy's paper. This is your
% solution, you just give the graph points in the image and this
% function converts them to true points:
%
% 1. Capture a high res image of the graph where the results are
% given (e.g. in gimp: -> File -> Create -> Screenshot...
% 2. Give points in the image where it is easy to estimate their
% graph values (e.g. the grid points in a Matlab plot) - p_img
% 3. Give the user (you!) estimated values of the given image
% points - p_user
% 4. Give as many points on the graph curve as you wish - p_graph
% 5. Now the system outputs your image coordinates p_graph as the
% estimated values in the given graph - p_est
%
% NOTE: This function is a bad example how to do science - rather
% ask the values from the authors or really replicate the results!!
%
% Examples:
%  [p_i p_u p_g p_e] = mvpr_from_scientific_graph_to_points(imread('resources/martinezvalstar-pami_final_fig_11.png'));
%
% Authors:
%  Joni Kamarainen
%
% Project:
%  -
%
% References:
%  -
%
function [p_img p_user p_graph p_est] = mvpr_from_scientific_graph_to_points(img_,varargin)

if nargin == 3
  disp('Coordinate points and their true values given');
  p_img = varargin{1};
  p_user = varargin{2};
else
  % Get the interpolation points
  fprintf('Give the image points for interpolation')
  p_img = mvpr_anno_imgpoints(img_,size(img_,2),size(img_,1),inf);
  
  % Get the user points
  p_user = zeros(size(p_img));
  for i_p = 1:size(p_img,1)
    gcf
    imshow(img_);
    hold on;
    plot(p_img(i_p,1),p_img(i_p,2),'rx','MarkerSize',40,'LineWidth',2);
    [p_user(i_p,1)]= input('Graph X coordinate of the point: ');
    [p_user(i_p,2)]= input('Graph Y coordinate of the point: ');
  end;
end;

% Solve the scaling of X and Y
P_x=[p_img(:,1) ones(size(p_img,1),1)]\p_user(:,1);
P_y=[p_img(:,2) ones(size(p_img,1),1)]\p_user(:,2);
  
% Get the graph points
fprintf('Give the curve points you wish to resolved')
p_graph = mvpr_anno_imgpoints(img_,size(img_,2),size(img_,1),inf);
p_est = zeros(size(p_graph));
p_est(:,1) = [p_graph(:,1) ones(size(p_graph,1),1)]*P_x;
p_est(:,2) = [p_graph(:,2) ones(size(p_graph,1),1)]*P_y;