%% text extraction script
%
% Author: Yusen Fan, ysfan@umd.edu
%

close all;

% select reference image 
[filename,~] = imgetfile;

% load image into matlab
ref = imread(filename);

% select distorted image with student's input
[filename,~] = imgetfile;

% load image into matlab
disto = imread(filename);

% show reference image
figure, imshow(ref), title('reference image');
% show captured image
figure, imshow(disto), title('captured image');

% do the text extraction 
im_out = TextExtraction( ref, disto );