%% mobile scanner script
%
% Author: Yusen Fan, ysfan@umd.edu
%

close all;

% select image 
[filename,user_canceled] = imgetfile;

% load image into matlab
image = imread(filename);

% calculate the rectangle corners
corners  = RectangleRecognition( image );

% enhance the image
im_out = ImageEnhance( image, corners);