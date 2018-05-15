function [ im_out ] = ImageEnhance( im, corners)
%% Transform and enhance the image
%
% Input: im: grayscale or color image.
%        corners: corner coordinates of the file area.
% Output: the transformed and enhanced image
% Author: Yusen Fan, ysfan@umd.edu

%% first, change RGB to grayscale
[~, ~, channel] = size(im);
if channel == 3
    im = rgb2gray(im);
end

%% second, locate the corners, starting from the left top corner.

[~, I] = sort(corners(:,2));

if corners(I(1),1) < corners(I(2),1)
    firstIndex = I(1);
    secondIndex = I(2);
else
    firstIndex = I(2);
    secondIndex = I(1);
end
if corners(I(3),1) <= corners(I(4),1)
    thirdIndex = I(3);
    fourthIndex = I(4);
else
    thirdIndex = I(4);
    fourthIndex = I(3);
end

registeredCorners = [corners(firstIndex,:);corners(secondIndex,:);...
    corners(thirdIndex,:);corners(fourthIndex,:)];

%% then, do the perspective transform.
movingPoints = registeredCorners;
[row, col] = size(im);
fixedPoints = [1, 1; col, 1; 1, row; col, row];
tform = fitgeotrans(movingPoints,fixedPoints,'projective');

transformedI = imwarp(im,tform,'OutputView',imref2d(size(im)));
figure, imshow(im), hold on;
plot(movingPoints(:,1), movingPoints(:,2), 'ro');
figure,imshow(transformedI);

%% last, do histogram equalization to enhance the contrast.
% effect of histeq not good
% histeqI = histeq(transformedI);
% figure, imshow(histeqI);
J = adapthisteq(transformedI); % this is better 
figure, imshow(J);

im_out = J;

end

