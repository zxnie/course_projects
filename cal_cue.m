function cue_sinr = cal_cue(cue, BS, freq, G_cue, pathloss_exponent, Pi, d2d_tr, Pj)
%% CUE throughput
% Generate CUE
% cue = gen_user_ul([0,0], n_user, R);

% CUE pathloss
cue_pathloss = cal_pathloss(cue, BS, freq, G_cue, pathloss_exponent);
% BS receive power
cue_rp = Pi ./ (10.^(cue_pathloss./10));

% Co-channel interference pathloss
d2d2cue_pathloss = cal_pathloss(d2d_tr, BS, freq, G_cue, pathloss_exponent);
% Co-channel interference receive power
d2d2cue_interference_p = Pj ./ (10.^(d2d2cue_pathloss./10));
% SINR
cue_sinr = cal_SINR(cue_rp, d2d2cue_interference_p);
return
% Throughput of d2d
cue_throughput = log2(1+cue_sinr);
end