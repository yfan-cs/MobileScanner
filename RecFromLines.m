function [ corners ] = RecFromLines( lines )
%% Determine the largest rectangle surronded by the input lines
%
% Input: sorted lines according to theta
% Output: corner coordinates of the rectangle, in clockwise or
% anti-clockwise order.
% Author: Yusen Fan, ysfan@umd.edu
%

%% first, merge the same(similar) (theta,rho) pairs
unique_lines = struct([]);
% {point1, point2, theta, rho, rho_large, point1_after, point2_after}
for k = 1:length(lines)
    theta = lines(k).theta;
    rho = lines(k).rho;
    if k == 1
        unique_lines(end+1).point1 = lines(k).point1;
        unique_lines(end).point2 = lines(k).point2;
        unique_lines(end).theta = theta;
        unique_lines(end).rho = rho;
        unique_lines(end).rho_large = rho;
        unique_lines(end).point1_after = unique_lines(end).point1;
        unique_lines(end).point2_after = unique_lines(end).point2;
    else
        if abs(theta - unique_lines(end).theta) < 12 
            % similar theta, merge them together
            if rho >= unique_lines(end).rho &&...
                    rho <= unique_lines(end).rho_large
                % already existed
                continue;
            else
                % similar theta, different rho
                if rho < unique_lines(end).rho
                    unique_lines(end).rho = rho;
                    unique_lines(end).point1 = lines(k).point1;
                    unique_lines(end).point2 = lines(k).point2;
                else
                    unique_lines(end).rho_large = rho;
                    unique_lines(end).point1_after = lines(k).point1;
                    unique_lines(end).point2_after = lines(k).point2;
                end
            end
        else
            % different theta, new data point added
            unique_lines(end+1).point1 = lines(k).point1;
            unique_lines(end).point2 = lines(k).point2;
            unique_lines(end).theta = theta;
            unique_lines(end).rho = rho;
            unique_lines(end).rho_large = rho;
            unique_lines(end).point1_after = unique_lines(end).point1;
            unique_lines(end).point2_after = unique_lines(end).point2;
        end

    end 
end

if unique_lines(1).theta > 84 && unique_lines(length(unique_lines)).theta < -84
    if unique_lines(length(unique_lines)).rho < unique_lines(1).rho
        unique_lines(1).rho = unique_lines(length(unique_lines)).rho;
        unique_lines(1).point1 = unique_lines(length(unique_lines)).point1;
        unique_lines(1).point2 = unique_lines(length(unique_lines)).point2;
    end
    
    if unique_lines(length(unique_lines)).rho_large > unique_lines(1).rho_large
        unique_lines(1).rho_large = unique_lines(length(unique_lines)).rho_large;
        unique_lines(1).point1_after = unique_lines(length(unique_lines)).point1_after;
        unique_lines(1).point2_after = unique_lines(length(unique_lines)).point2_after;
    end
     
end
% second, find the orthogonal pairs:
max_area = 0; % maximum rectangle area found so far
result_indices = [-1,-1]; 

for i=1:length(unique_lines)
    for j=i+1:length(unique_lines)
        theta_diff = unique_lines(i).theta - unique_lines(j).theta;
        if (abs(theta_diff-90) < 10)
            area = abs((unique_lines(i).rho-unique_lines(i).rho_large) * ...
                (unique_lines(j).rho-unique_lines(j).rho_large));
            if area > max_area
                max_area = area;
                result_indices = [i,j];
            end
        end
    end
end

if result_indices(1) == -1 || result_indices(2) == -1
    fprintf('Not enough edges detected!!! Please increase the number of hough peaks!\n');
    return;
end
rec = unique_lines(result_indices(1));
rec(end+1) = unique_lines(result_indices(2));

% find the corners of the rectangle
L11 = [rec(1).point1(1), rec(1).point1(2); rec(1).point2(1), rec(1).point2(2)];
L12 = [rec(1).point1_after(1), rec(1).point1_after(2); rec(1).point2_after(1), rec(1).point2_after(2)];
L21 = [rec(2).point1(1), rec(2).point1(2); rec(2).point2(1), rec(2).point2(2)];
L22 = [rec(2).point1_after(1), rec(2).point1_after(2); rec(2).point2_after(1), rec(2).point2_after(2)];

corners = zeros(4,2);
corners(1,:) = LineIntersection(L11,L21);
corners(2,:) = LineIntersection(L11,L22);
corners(3,:) = LineIntersection(L12,L22);
corners(4,:) = LineIntersection(L12,L21);

end



