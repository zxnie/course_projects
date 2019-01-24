function d2d_sinr = cal_d2d(d2d_tr, d2d_rc, cue, G_d2d, freq, pathloss_exponent, Pi, Pj)
%% D2D link throughput
% d2d pathloss
d2d_pathloss = cal_pathloss(d2d_tr, d2d_rc, freq, G_d2d, pathloss_exponent);
% d2d receive power
d2d_rp = Pj ./ (10.^(d2d_pathloss./10));

% Co-channel interference pathloss
cue2d2d_pathloss = cal_pathloss(cue, d2d_rc, freq, G_d2d, pathloss_exponent);
% Co-Channel interference receive power
cue2d2d_interference_p = Pi ./ (10.^(cue2d2d_pathloss./10));
% SINR
d2d_sinr = cal_SINR(d2d_rp, cue2d2d_interference_p);
return
% Throughput of d2d
d2d_throughput = log2(1+d2d_sinr);
end