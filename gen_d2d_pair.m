function [d2d_tr, d2d_rc] = gen_d2d_pair(R, n)
% Generate n pairs of D2D pairs in radius R with distance d.
d2d_rt = unifrnd(0,R,[1,n]);
% theta
user_pos_theta = unifrnd(0,2*pi,[2,n]);
% d2d_tr
d2d_tr = d2d_rt .* cos(user_pos_theta(1,:)) + d2d_rt .* sin(user_pos_theta(1,:)) .* 1i;
% d2d_rc
d = randi([5 15],1,n);
r_shift = d .* cos(user_pos_theta(2,:)) + d .* sin(user_pos_theta(2,:)) .* 1i;
d2d_rc = d2d_tr + r_shift;
end