% main_fast_pair
% Figure 2, result 1

%% constants
Pi = 250;
Pj = 125;                       % mW
freq = 1.90;                    % GHz
R = 300;                        % Cell radius
n_cue = 140;                    % Number of CUE, 20:5:60
n_d2d = 30;                     % Number of D2D links, 20 and 30
n_total = n_cue + n_d2d * 2;    % Total cellular users.
pathloss_exponent = 3.5;        % Urban area
d2d_avg_throughput = 0;         % avg throughput
G_d2d = 100 * 100;              % Gt*Gr of a D2D pair, mobile antenna gain 2dB.
G_cue = 1e4 * 100;              % Gt*Gr of a CUE to BS, BS antena gain 40dB.
BS = 0;                         % BS at the center (0,0)
th_cue_sinr = 10;
th_d2d_sinr = 10;
loops = 1000;
sum_of_sumrate = 0;
sumrate_unshared = 0;

%% Main
for x=1:loops
    q = zeros([n_d2d,n_cue]); % D2D enable flag matrix

    % Generate n_cue CUEs and n_d2d D2D links in radius R.
    cue = gen_user_ul([0,0], n_cue, R);
    [d2d_tr, d2d_rc] = gen_d2d_pair(R, n_d2d);

    % Calculate SINR of each CUE (D2D link is co-channel)
    % and get candidates table
    cue_sinr_all = zeros([n_d2d,n_cue]);
    candidates = zeros([n_d2d,n_cue]);
    for i=1:n_cue
        cue_sinr = cal_cue(cue(i), BS, freq, G_cue, pathloss_exponent, Pi, d2d_tr, Pj);
        cue_sinr_all(1:n_d2d,i) = cue_sinr;
        for j=1:n_d2d
            if cue_sinr(j) >= th_cue_sinr
               candidates(j,i) = 1; 
            end
        end
    end

    % Calculate SINR of each D2D link (CUE-BS is co-channel)
    d2d_sinr_all = zeros([n_d2d,n_cue]);
    for i=1:n_d2d
        d2d_sinr = cal_d2d(d2d_tr(i), d2d_rc(i), cue, G_d2d, freq, pathloss_exponent, Pi, Pj);
        d2d_sinr_all(i,1:n_cue) = d2d_sinr;
    end

    % Find possible shares that met d2d sinr threshold
    for i=1:n_d2d
        for j=1:n_cue
           if candidates(i,j) == 1
               if d2d_sinr_all(i,j) < th_d2d_sinr
                   candidates(i,j) = 0;
               end
           end
        end
    end

    % Create a list to count selected cue and make share decision.
    cue_list = zeros([1,n_cue]);
    for i=1:n_d2d
        selections = zeros([1,2]);
        for j=1:n_cue
            if candidates(i,j) == 1
                selections = [selections; [j cue_list(j)]];
            end
        end
        s = size(selections);
        if s(1) < 2
            continue
        end
        selections(1,:) = [];
        sortrows(selections,2);
        if selections(1,2) == 0
            q(i,selections(1,1)) = 1;
            cue_list(selections(1,1)) = cue_list(selections(1,1)) + 1;
        end
    end

    % After all decisions are made (running out of d2d links),
    % Calculate overall throughput.
    % CUE sum rate
    cue_sinr_unshared = cal_cue_unshared(cue, BS, freq, G_cue, pathloss_exponent, Pi);
    unshared_rate = sum(log2(1+cue_sinr_unshared));
    cue_sinr_unshared = cue_sinr_unshared .* not(cue_list);
    cue_sinr_mix = cue_sinr_unshared + sum((q .* cue_sinr_all),1);
    cue_sumrate = sum(log2(1+cue_sinr_mix));

    % D2D sum rate
    d2d_sinr_shared = sum((q .* d2d_sinr_all),2);
    d2d_sumrate = sum(log2(1+d2d_sinr_shared));

    sum_rate = cue_sumrate + d2d_sumrate;
    sum_of_sumrate = sum_of_sumrate + sum_rate;
    sumrate_unshared = sumrate_unshared + unshared_rate;
end
avg_sumrate = sum_of_sumrate / loops
% avg_sumrate_without_d2d = sumrate_unshared / loops