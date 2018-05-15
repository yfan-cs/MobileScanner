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

% do the text extraction 
im_out = TextExtraction( ref, disto );