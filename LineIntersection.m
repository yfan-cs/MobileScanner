function [ P ] = LineIntersection( L1, L2)
%% Find the intersection of two lines
%
% Input: two lines denoted by two points: L = [x1, y1; x2, y2].
% Output: the intersection of two lines.
% Author: Yusen Fan, ysfan@umd.edu
%

%%
% L = [x1, y1; x2, y2];

% slope
slope = @(line) (line(2,2) - line(1,2))/(line(2,1) - line(1,1));
m1 = slope(L1);
m2 = slope(L2);

% intercepts.
if isinf(m1)
    % L1 is a vertical line
    xintersect = L1(1,1);
    yintersect = m2 * (xintersect-L2(1,1)) + L2(1,2);
elseif isinf(m2)
    % L2 is a vertical line
    xintersect = L2(1,1);
    yintersect = m1 * (xintersect-L1(1,1)) + L1(1,2);
else
    % no vertical lines
    intercept = @(line,m) line(1,2) - m*line(1,1);
    b1 = intercept(L1,m1);
    b2 = intercept(L2,m2);
    xintersect = (b2-b1)/(m1-m2);
    yintersect = m1*xintersect + b1;  
end
% the coordinate of the intersection    
P = [xintersect, yintersect];
end

