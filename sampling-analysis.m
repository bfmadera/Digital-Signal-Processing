clear;
close all;
clc;

A = 1;                  % amplitude
f0 = 60;                % frequência fundamental
P = 4;                  % número de períodos

fs_list = [480 960 1920 3840];

for k = 1:length(fs_list)

    fs = fs_list(k);    % frequência de amostragem
    Ts = 1/fs;          % período de amostragem
    T0 = 1/f0;          % período da senoide

    t_final = P*T0;     % tempo total

    N = round(t_final * fs);

    n = 0:N-1;          % índice discreto
    t = n * Ts;         % tempo discreto

    x = A*sin(2*pi*f0*t);

    figure
    stem(t,x,'filled')
    hold on
    plot(t,x,'r--','LineWidth',1.2)

    title(['Senoide discreta: f0 = ', num2str(f0), ' Hz, fs = ', num2str(fs),' Hz'])
    xlabel('Tempo discreto (s)')
    ylabel('Amplitude')
    grid on

end
