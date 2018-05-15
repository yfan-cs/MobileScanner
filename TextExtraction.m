function [ im_out ] = TextExtraction( original_RGB, distorted_RGB )
%% extract the input from captured image and put it onto the reference form.
%
% Input: original: reference form.
%        distorted_RGB: captured image with student's input.
% Output: input overlaid on reference image.
% Assumption: the input's color is blue, and the reference text is black.
% Author: Yusen Fan, ysfan@umd.edu

%% Find Matching Features Between Images
% Detect features in both images.
[~, ~, channel] = size(distorted_RGB);
if channel == 1
    distorted = distorted_RGB;
elseif channel == 3
    distorted = rgb2gray(distorted_RGB);
end
[~, ~, channel] = size(original_RGB);
if channel == 1
    original = original_RGB;
elseif channel == 3
    original = rgb2gray(original_RGB);
end

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

% put the input onto the reference form
im_out(im_out<1) = original(im_out<1);

%%
% Compare |recovered| to |original| by looking at them side-by-side in a montage.
figure, imshowpair(original,im_out,'montage')


end

%% Reference
% https://www.mathworks.com/help/images/examples/find-image-rotation-and-
% scale-using-automated-feature-matching.html
