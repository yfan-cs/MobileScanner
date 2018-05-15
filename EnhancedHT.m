function [ H_enh ] = EnhancedHT( H )
%% Enhanced Hough Transform to merge vicinity peaks
% 
% Input: H, original hough transform matrix.
% Output: H_enh, enhanced hough transform matrix.
% Author: Yusen Fan, ysfan@umd.edu

% set the rectangle window here to be hxw, h=10, w=2
h=10;
w=2;
[nrho, ntheta] = size(H);
H_enh = H;
for rho = h/2+1:nrho-h/2
    for theta = w/2+1:ntheta-w/2
        scale = sum(sum(H(rho-h/2:rho+h/2,theta-w/2:theta+w/2)));
        if scale == 0
            continue
        else
            H_enh(rho,theta) = (h*w/scale)*H_enh(rho,theta)^2;
        end
    end
end

end
