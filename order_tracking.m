close all
clear
clc

%% Load data 
[filename, pathname] = uigetfile;
cd(pathname);
load(filename);

%% Calibrate the displacement signal
proxi_async = proxi_async / sens; % Convert voltage to mm using sensor sensitivity

%% Plot the displacement and trigger signals
N = length(proxi_async); 
dt = 1/fsamp;
time = 0:dt:N*dt-dt; 

figure
subplot(2,1,1)
plot(time, proxi_async)
xlabel('Time [s]')
ylabel('Displacement [mm]')
title('Displacement')
grid on
subplot(2,1,2)
plot(time, ref)
xlabel('Time [s]')
ylabel('Voltage [V]')
title('Trigger')
grid on

%% Detect peaks in the trigger signal to segment each revolution
[peaks_vals, peaks_id] = findpeaks(ref, "MinPeakHeight", 0.1); 

%% Compute angular speed over time
t_peaks = time(peaks_id); 
deltaT = diff(t_peaks); 
ang_sp = (2 * pi) ./ deltaT; 

figure
plot(t_peaks(2:end), ang_sp)
xlabel('Time [s]')
ylabel('Angular speed [rad/s]')
title('Angular speed during the test')
grid on

%% Order tracking procedure to reconstruct displacement profile
N_revs = length(peaks_id) - 1; 
dth = 2 * pi / 360; 
Th_NEW = 0:dth:2*pi-dth; 
SIG = zeros(N_revs, length(Th_NEW)); 
N_filt = 4; 

figure 
for i = 1:N_revs 
    % Extract single revolution signal
    sig_i = proxi_async(peaks_id(i):peaks_id(i+1)-1); 
    N_i = length(sig_i); 
    T0_i = N_i / fsamp; 
    f0_i = 1 / T0_i; 
    Dth = 2 * pi / N_i; 
    Th_v = (0:Dth:2*pi-Dth); 

    % Design low-pass filter
    ord_int = 20; 
    fcut = 2.56 * ord_int * f0_i / 2; 
    [b, a] = butter(N_filt, fcut / (fsamp / 2), "low"); 

    % Apply filter with continuous state tracking
    if i == 1
        [sig_i_filt, final_state] = filter(b, a, sig_i);
        initial_state = zeros(max(length(a), length(b)) - 1, 1);
    else
        [sig_i_filt, final_state] = filter(b, a, sig_i, initial_state);
    end
    initial_state(:,1) = final_state;

    % Interpolation to normalize the number of points per revolution
    sig_int = spline(Th_v, sig_i_filt, Th_NEW);
    SIG(i, :) = sig_int;
    
    % Plot filtered and interpolated signals
    plot(Th_v, sig_i_filt)
    hold on
    plot(Th_NEW, sig_int, '--')
    legend('Filtered signal', 'Interpolated signal')
end

grid on
xlabel('Angular position [rad]')
ylabel('Displacement [mm]')
title ('All revolutions (filtered and resampled)')
axis tight

%% Compute and plot the averaged signal
figure
averaged_signal = mean(SIG);
plot(Th_NEW, averaged_signal, 'r', 'LineWidth', 2)
xlabel('Angular position [rad]')
ylabel('Displacement [mm]')
title ('Averaged displacement profile')
grid on
axis tight
