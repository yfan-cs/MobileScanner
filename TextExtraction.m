function [ im_out ] = TextExtraction( original, distorted_RGB )
%UNTITLED Summary of this function goes here
%   Detailed explanation goes here

%% Find Image Rotation and Scale Using Automated Feature Matching
% This example shows how to automatically align two images that differ by a
% rotation and a scale change.
% It utilizes feature-based techniques to automate the registration process.
%
% In this example, you will use |detectSURFFeatures| and 
% |vision.GeometricTransformEstimator| System object to recover rotation 
% angle and scale factor of a distorted image. You will then transform the 
% distorted image to recover the original image.

% Copyright 1993-2014 The MathWorks, Inc. 


%% Find Matching Features Between Images
% Detect features in both images.
distorted = rgb2gray(distorted_RGB);
ptsOriginal  = detectSURFFeatures(original);
ptsDistorted = detectSURFFeatures(distorted);

%%
% Extract feature descriptors.
[featuresOriginal,   validPtsOriginal]  = extractFeatures(original,  ptsOriginal);
[featuresDistorted, validPtsDistorted]  = extractFeatures(distorted, ptsDistorted);

%%
% Match features by using their descriptors.
indexPairs = matchFeatures(featuresOriginal, featuresDistorted);

%%
% Retrieve locations of corresponding points for each image.
matchedOriginal  = validPtsOriginal(indexPairs(:,1));
matchedDistorted = validPtsDistorted(indexPairs(:,2));

%%
% Show point matches. Notice the presence of outliers.
figure;
showMatchedFeatures(original,distorted,matchedOriginal,matchedDistorted);
title('Putatively matched points (including outliers)');

%% Estimate Transformation
% Find a transformation corresponding to the matching point pairs using the
% statistically robust M-estimator SAmple Consensus (MSAC) algorithm, which
% is a variant of the RANSAC algorithm. It removes outliers while computing
% the transformation matrix. 
[tform, inlierDistorted, inlierOriginal] = estimateGeometricTransform(...
    matchedDistorted, matchedOriginal, 'similarity');

%%
% Display matching point pairs used in the computation of the
% transformation matrix.
figure;
showMatchedFeatures(original,distorted, inlierOriginal, inlierDistorted);
title('Matching points (inliers only)');
legend('ptsOriginal','ptsDistorted');

%% Solve for Scale and Angle
% Use the geometric transform, TFORM, to recover 
% the scale and angle. Since we computed the transformation from the
% distorted to the original image, we need to compute its inverse to 
% recover the distortion.
%
%  Let sc = scale*cos(theta)
%  Let ss = scale*sin(theta)
%
%  Then, Tinv = [sc -ss  0;
%                ss  sc  0;
%                tx  ty  1]
%
%  where tx and ty are x and y translations, respectively.
%

%%
% Compute the inverse transformation matrix.
Tinv  = tform.invert.T;

ss = Tinv(2,1);
sc = Tinv(1,1);
scale_recovered = sqrt(ss*ss + sc*sc);
theta_recovered = atan2(ss,sc)*180/pi;

%%
% The recovered values should match your scale and angle values selected in
% *Step 2: Resize and Rotate the Image*.

%% Recover the Original Image
% Recover the original image by transforming the distorted image.
outputView = imref2d(size(original));

T = 100;
red_ch = distorted_RGB(:,:,1);
green_ch = distorted_RGB(:,:,2);
blue_ch = distorted_RGB(:,:,3);

mask = uint8(((red_ch < 1.1 * T) & (green_ch < 1.1 * T) & (blue_ch > T))*1);
distorted(mask<1) = 0;
im_out  = imwarp(distorted,tform,'OutputView',outputView);

im_out(im_out<1) = original(im_out<1);

%%
% Compare |recovered| to |original| by looking at them side-by-side in a montage.
figure, imshowpair(original,im_out,'montage')


end


%% Reference
% https://www.mathworks.com/help/images/examples/find-image-rotation-and-
% scale-using-automated-feature-matching.html
