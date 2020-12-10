%MVPR_SG_SOLVEFILTERPARAMS  solve Gabor filter parameters
%
% [gamma, eta] = sg_solvefilterparams(k, p, m, n)
%
% This functions is intended for solving filter sharpness parameters
% gamma and eta based on other filter bank parameters according to
% the rules derived in ref. [1].
%
% Output:
%  gamma - Filter gamma value.
%  eta   - Filter eta value.
%
% Input:
%   k - spacing of filter frequencies
%   p - filter overlap
%   m - number of filter frequencies
%   n - number of filter orientations
%
% Author(s):
%    Jarmo Ilonen, MVPR
%
% Project:
%  SimpleGabor (http://www2.it.lut.fi/project/simplegabor/)
%
% Copyright:
%
%   Simple Gabor Toolbox (mvpr_sg_* ) is Copyright
%   (C) 2006-2010 by Jarmo Ilonen and Joni-Kristian Kamarainen.
%
% References:
%  [1] Ilonen, Jarmo, "Supervised local image feature detection",
%  PhD Thesis, Dept. of Information Technology, Lappeenranta
%  University of Technology, 2007.
%
% See also MVPR_SG_*.M .
%
function [gamma, eta] = mvpr_sg_solvefilterparams(k, p, m, n)


gamma=solvegamma(k,p);
eta=solveeta(n,p);



function gamma=solvegamma(k,p)

gamma=1/pi*sqrt(-log(p))*(k+1)/(k-1);



function k=solvek(gamma,p)

x=1/(gamma*pi)*sqrt(-log(p));
k=(1+x)/(1-x);



function p=solvep(gamma,k)

p=exp(- ( gamma*pi * (k-1)/(k+1))^2);


function eta=solveeta(n,p)

%ua=tan(pi/(no*2)) * fmax % exact ua
ua=pi/n/2;  % ua based on approximation

eta=1/pi*sqrt(-log(p))/(ua);


