function pathloss = cal_pathloss(d2d_tr, d2d_rc, freq, antenna_gain, pathloss_exponent)
%% calculate distances between users and basestations.
dist_users = abs(d2d_tr-d2d_rc);

% Get unit pathloss from free space propagation model
lambda = physconst('LightSpeed')/(freq*1e+9);
unit_pathloss = 10*log10(((4*pi)/lambda)^2/antenna_gain);

% Pathloss and shadowing
path_loss = unit_pathloss + 10*pathloss_exponent*log10(dist_users);
shadowing = 10*log10(abs(4*normrnd(0,1,size(d2d_tr))));
pathloss = path_loss + shadowing;
end