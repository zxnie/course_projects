function SINR = cal_SINR(receive_power, interference_power)
noise = 0.0001;
s = size(receive_power);
SINR = receive_power ./ (interference_power + kron(noise, ones(1,s(2))));
end