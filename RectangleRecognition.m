function [ corners ] = RectangleRecognition( im )
%% Identify the largest rectangle in the captured image.
%
%  Input: the raw image, in grayscale or rgb
%  Output: the corner coordinates of the recognized rectangle.
%  Author: Yusen Fan, ysfan@umd.edu

close all;

[~, ~, channel] = size(im);
if channel == 1
    I = im;
elseif channel == 3
    I = rgb2gray(im);
end
    
%% Median filter to filter out the contents in the file
% This would filter out lots of lines resulted from the contents
% inside the file.

%% debug %%%%%%%%%%%%%%%%%%%%%%%% different size %%%%%%%%%%%%%%%%%%%%%%%%%%
I = medfilt2(I,[20,20],'symmetric');

%%
% Extract edges.
% laplacian of gaussian or canny. %%%%%% comparison of the edge detectors. 
BW = edge(I, 'canny'); 
imshow(BW),title('Canny edges');

% Remove small edge objects
BW2 = bwareaopen(BW, 50); 
figure, imshow(BW2), title('Samll edge objects removed');


%% Hough transform to identify lines
%%%%%%%%%%%%%%%%%%%%%%%%%%% try different resolution %%%%%%%%%%%%%%%%%%%%%%
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
[H,T,R] = hough(BW2,'RhoResolution',2,'ThetaResolution',2);
H_enh = EnhancedHT(H); % enhanced hough transform

%%
% Display the Hough matrix.
figure,
imshow(imadjust(mat2gray(H)),'XData',T,'YData',R,...
      'InitialMagnification','fit');
title('Hough transform');
xlabel('\theta'), ylabel('\rho');
axis on, axis normal, hold on;
colormap(gca,hot);

% Display the enhanced hough matrix
figure;
imshow(imadjust(mat2gray(H_enh)),'XData',T,'YData',R,...
      'InitialMagnification','fit');
title('Enhanced Hough transform');
xlabel('\theta'), ylabel('\rho');
axis on, axis normal, hold on;
colormap(gca,hot);

% find the peaks in the Hough transform matrix H
% ideally, 4 peaks are needed. Use 12 for robustness.
% the higher the hough resolution, the more peaks needed.
P = houghpeaks(H, 12, 'threshold', ceil(0.3 * max(H(:))));

% plot the location of the peaks
figure, x = T(P(:,2)); y = R(P(:,1));
plot(x,y,'s','color','black'), title('Hough transform peaks');

% it is better to use enhanced hough transform.
P = houghpeaks(round(H_enh), 12, 'threshold', ceil(0.3 * max(H(:))));
figure, x = T(P(:,2)); y = R(P(:,1));
plot(x,y,'s','color','black'),title('Enhanced Hough transform peaks');

% find lines in the image using houghlines function
lines = houghlines(BW2, T, R, P, 'FillGap', 4, 'MinLength', 50);
sorted_lines = SortArrayofStruct(lines,'theta');

%% create a plot that displays the lines
figure, imshow(im), hold on
max_len = 0;
for k = 1:length(lines)
   xy = [lines(k).point1; lines(k).point2];
   % draw the line connecting point1 and point2
   plot(xy(:,1),xy(:,2),'LineWidth',2,'Color','green');

   % Plot beginnings and ends of lines
   plot(xy(1,1),xy(1,2),'x','LineWidth',2,'Color','yellow');
   plot(xy(2,1),xy(2,2),'x','LineWidth',2,'Color','red');

   % Determine the endpoints of the longest line segment
   len = norm(lines(k).point1 - lines(k).point2);
   if ( len > max_len)
      max_len = len;
      xy_long = xy;
   end
end
% % highlight the longest line segment
plot(xy_long(:,1),xy_long(:,2),'LineWidth',2,'Color','red'), title('Hough lines');


%% find largest rectangle from the above lines

corners = RecFromLines(sorted_lines);
% create a plot that displays the rectangle
figure, imshow(im), hold on
for k = [1,3]
    k1 = k+1;
    x = [corners(k,1), corners(k1,1)];
    y = [corners(k,2), corners(k1,2)];
    % draw the line connecting point1 and point2
    plot(x,y,'LineWidth',2,'Color','green');
    
    k2 = k-1;
    if k2 == 0
        k2 = 4;
    end
    x = [corners(k,1), corners(k2,1)];
    y = [corners(k,2), corners(k2,2)];
    % draw the line connecting point1 and point2
    plot(x,y,'LineWidth',2,'Color','green');

end

end


%% Additional step
% additional checks for color consistency within and outside the rectangle 
% to discriminate false positives
