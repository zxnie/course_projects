function cue_sinr_unshared = cal_cue_unshared(cue, BS, freq, G_cue, pathloss_exponent, Pi)
% CUE pathloss
cue_pathloss = cal_pathloss(cue, BS, freq, G_cue, pathloss_exponent);
% BS receive power
cue_rp = Pi ./ (10.^(cue_pathloss./10));
% SINR
cue_sinr_unshared = cal_SINR(cue_rp, zeros(size(cue)));
end