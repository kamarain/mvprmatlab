%MVPR_IMREAD - read image as GRAY scale
%
% [img]= mvpr_imreadgray(fname,:) uses imread and imfinfo
% internally. All images (inc. colour) are converted to gray level
% using mvpr_imconvert.m .
%
% NOTE: Reading GPG encrypted files is done very stupidly and it
% stores decrypted files into the current directory - thus if your
% scripts keep on crashing you may need to remove this files every
% now and then!!
%
% Inputs:
%  fname   - image file name
%
% <optional>
% 'range'         - scale the (theoretical) image values to range,
%                   for example [0 1], default: empty (no
%                   scaling).
% 'type'          - the data type of the returned image, default:
%                   'single' (The type is used like a function, so
%                   it could be any function taking and returning
%                   one argument.) 
% 'gpgpassphrase' - if image is encrypted ('*.gpg') this passphrase
%                   will be used to decrypt it (executes unix "gpg"
%                   command) is used (UNRELIABLE).
%
% 'greenonly'     - if set to 1, takes only the green channel
%                   (img(:,:2)) and no any RGB2Gray used (works
%                   e.g. with the bloody face grand challenge
%                   images which are badly distorted)
%                   (UNRELIABLE).
%
% Outputs:
%  img     - gray scale image
%
% <optional>   
%  info    - the info structure returned by imfinfo
%
% Examples:
%  -
%
% Authors:
%  Joni Kamarainen, MVPR in 2009
%  Pekka Paalanen, MVPR in 2009
%
% Project:
%  -
%
% References:
%
% See also MVPR_IMCONVERT.M .
%
function [img, varargout] = mvpr_imread(fname, varargin);

conf = struct( 'range', [], 'type', 'single', 'gpgpassphrase', 'NONE','greenonly',0);
conf = mvpr_getargs(conf, varargin);
% do encryption if necessary

[fnameDir fnameName fnameExt] = fileparts(fname);
if strcmp(fnameExt,'.gpg')
  randFileName = [tempname '_' fnameName];
  decryptString = sprintf('gpg --no-mdc-warning --quiet --yes --no-options --output %s --passphrase %s --decrypt %s',...
                          randFileName, conf.gpgpassphrase, fname);
  if (system(decryptString))
    error('Encrypted (GPG) image decryption failed!');
  end;
  % Read image and info
  info = imfinfo(randFileName);
  [img, cmap] = imread(randFileName);
  delete(randFileName);
else
  % Read image and info
  info = imfinfo(fname);
  [img, cmap] = imread(fname);
end;

%info = imfinfo(fname);

if nargout > 1
	varargout{1} = info;
end

if (conf.greenonly)
  img = mvpr_imconvert(squeeze(img(:,:,2)),info.ColorType,...
                       'range',conf.range,...
                       'type',conf.type);
else
  img = mvpr_imconvert(img,info.ColorType,...
                       'range',conf.range,...
                       'type',conf.type);
end;
