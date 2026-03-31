%% EXERCICIO 4 - 
% SEL0615 - Processamento Digital de Sinais
% Bárbara Fernandes Madera - 11915032
%
% OBSERVACAO IMPORTANTE:
% O sinal pedido tem N = 16384 amostras. A DFT direta para esse N,
% executada 30 vezes, pode demorar MUITO tempo, porque a complexidade dela é O(N^2).
% Por isso, o código possui uma chave chamada "usarBenchmarkCompleto".
% - Se usarBenchmarkCompleto = true, ele tenta executar exatamente como pede o exercício.
% - Se usarBenchmarkCompleto = false, ele faz a comparação de tempo com um N menor,
%   apenas para viabilizar a execução.
%

clc;
clear;
close all;

%% =========================
% 1) PARAMETROS DO SINAL
% ==========================
f0 = 50;                  % Frequencia fundamental do sinal (Hz)
amostrasPorCiclo = 2048;  % Numero de amostras por ciclo
numCiclos = 8;            % Numero de ciclos do sinal

fs = f0 * amostrasPorCiclo;    % Frequencia de amostragem
N = amostrasPorCiclo * numCiclos; % Numero total de amostras

t = (0:N-1) / fs;         % Vetor de tempo
x = sin(2*pi*f0*t);       % Sinal senoidal de entrada

fprintf('Frequencia de amostragem fs = %d Hz\n', fs);
fprintf('Numero total de amostras N = %d\n', N);

%% =========================
% 2) ITEM (a): PLOT DO SINAL
% ==========================
figure;
plot(t, x, 'LineWidth', 1);
grid on;
title('Sinal senoidal no dominio do tempo');
xlabel('Tempo (s)');
ylabel('Amplitude');

% Com a finalidade de se visualizar melhor o sinal, vamos dar zoom em poucos ciclos
figure;
plot(t(1:4*amostrasPorCiclo), x(1:4*amostrasPorCiclo), 'LineWidth', 1);
grid on;
title('Zoom do sinal no tempo');
xlabel('Tempo (s)');
ylabel('Amplitude');

%% ============================================
% 3) FFT RADIX-2 IMPLEMENTADA SEM USAR fft()
% =============================================
% A funcao myFFT() esta no final do script.
% Como N = 16384 = 2^14, ele e apropriado para radix-2.

X_fft_manual = myFFT(x);

% Eixo de frequencia
f_axis = (0:N-1)*(fs/N);

% Magnitude normalizada
mag_fft = abs(X_fft_manual)/N;

% Como o sinal e real, normalmente mostramos apenas metade do espectro
halfN = N/2;
f_half = f_axis(1:halfN);
mag_half = mag_fft(1:halfN);

figure;
plot(f_half, mag_half, 'LineWidth', 1);
grid on;
title('Espectro de frequencia obtido pela FFT radix-2');
xlabel('Frequencia (Hz)');
ylabel('Magnitude normalizada');
xlim([0 300]); % zoom em baixas frequencias

%% ==========================================================
% 4) COMPARACAO VISUAL COM fft() DO MATLAB 
% ==========================================================
% Serve apenas para conferir se FFT ficou correta usando a função pronta de
% fft

X_fft_matlab = fft(x);
erroFFT = max(abs(X_fft_manual - X_fft_matlab));

fprintf('\nErro maximo entre myFFT e fft do MATLAB: %.6e\n', erroFFT);

%% =========================
% 5) ITEM (b): CUSTO N log N
% ==========================
% Aqui apenas mostra-se alguns valores comparativos numericos.

custo_teorico_fft = N * log2(N);
custo_teorico_dft = N^2;

fprintf('\nCusto teorico aproximado:\n');
fprintf('FFT ~ N*log2(N) = %.2f\n', custo_teorico_fft);
fprintf('DFT ~ N^2       = %.2f\n', custo_teorico_dft);
fprintf('Razao DFT/FFT   = %.2f\n', custo_teorico_dft / custo_teorico_fft);

%% ===============================================
% 6) ITEM (c): MEDICAO DE TEMPO FFT x DFT
% ===============================================
% IMPORTANTE:
% A DFT direta para N=16384, 30 vezes, pode ser extremamente lenta.
% Por isso, deixamos uma chave para escolher:
% true  -> roda com o N completo do enunciado
% false -> roda com N reduzido apenas para benchmark viavel

usarBenchmarkCompleto = false;  % altere para true se quiser tentar o enunciado literal
numExecucoes = 30;

if usarBenchmarkCompleto
    x_bench = x;
    N_bench = length(x_bench);
    fprintf('\nBenchmark sera feito com N COMPLETO = %d\n', N_bench);
else
    % N menor para viabilizar a execucao do benchmark da DFT
    N_bench = 1024;  
    x_bench = x(1:N_bench);
    fprintf('\nBenchmark sera feito com N REDUZIDO = %d\n', N_bench);
    fprintf('Isso foi escolhido apenas para tornar a DFT executavel em tempo razoavel.\n');
end

% Verifica se N_bench e potencia de 2 para usar na FFT radix-2
if mod(log2(N_bench),1) ~= 0
    error('N_bench precisa ser potencia de 2 para a FFT radix-2.');
end

temposFFT = zeros(numExecucoes,1);
temposDFT = zeros(numExecucoes,1);

fprintf('\nIniciando benchmark...\n');

for k = 1:numExecucoes
    % Tempo da FFT manual
    tic;
    myFFT(x_bench);
    temposFFT(k) = toc;

    % Tempo da DFT manual
    tic;
    myDFT(x_bench);
    temposDFT(k) = toc;

    fprintf('Execucao %2d/%2d concluida.\n', k, numExecucoes);
end

fprintf('Benchmark concluido.\n');

%% ===============================================
% 7) ESTATISTICAS DOS TEMPOS
% ===============================================
mediaFFT = mean(temposFFT);
desvioFFT = std(temposFFT);
medianaFFT = median(temposFFT);

mediaDFT = mean(temposDFT);
desvioDFT = std(temposDFT);
medianaDFT = median(temposDFT);

fprintf('\n ESTATISTICAS DOS TEMPOS\n');
fprintf('FFT -> media = %.6f s | desvio = %.6f s | mediana = %.6f s\n', ...
    mediaFFT, desvioFFT, medianaFFT);
fprintf('DFT -> media = %.6f s | desvio = %.6f s | mediana = %.6f s\n', ...
    mediaDFT, desvioDFT, medianaDFT);
fprintf('Razao media DFT/FFT = %.2f\n', mediaDFT/mediaFFT);

%% ===============================================
% 8) GRAFICOS DOS TEMPOS
% ===============================================
figure;
plot(1:numExecucoes, temposFFT, '-o', 'LineWidth', 1);
hold on;
plot(1:numExecucoes, temposDFT, '-s', 'LineWidth', 1);
grid on;
title('Tempo de execucao por rodada');
xlabel('Execucao');
ylabel('Tempo (s)');
legend('FFT manual', 'DFT manual');
figure;
boxplot([temposFFT temposDFT], 'Labels', {'FFT manual','DFT manual'});
grid on;
title('Distribuicao estatistica dos tempos');
ylabel('Tempo (s)');

figure;
histogram(temposFFT, 10);
grid on;
title('Histograma dos tempos da FFT manual');
xlabel('Tempo (s)');
ylabel('Frequencia');

figure;
histogram(temposDFT, 10);
grid on;
title('Histograma dos tempos da DFT manual');
xlabel('Tempo (s)');
ylabel('Frequencia');

%% ===============================================
% 9) ITEM (d): COMPARACAO ENTRE TEMPO E CUSTO
% ===============================================
% Aqui foi feito um calculo auxiliar da razao teorica e experimental

razaoTeorica = (N_bench^2) / (N_bench*log2(N_bench));
razaoExperimental = mediaDFT / mediaFFT;

fprintf('\n ITEM (d)\n');
fprintf('Razao teorica aproximada (DFT/FFT) = %.2f\n', razaoTeorica);
fprintf('Razao experimental media (DFT/FFT) = %.2f\n', razaoExperimental);

%% ===============================================
% 10) ITEM (e): CALCULO DE THD
% ===============================================
% Formula:
% THD = sqrt(V2^2 + V3^2 + ... + Vn^2) / V1
%
% Como o enunciado diz que os valores ja estao normalizados em relacao
% a fundamental de 50 Hz com valor unitario, entao V1 = 1.
%
% Logo:
% THD = sqrt(V2^2 + V3^2 + ... + Vn^2)
% THD% = THD * 100

% EXEMPLO:
% Cada linha representa um sinal.
% A primeira coluna e a componente fundamental (V1 = 1),
% e as demais colunas sao os harmonicos normalizados.
%
% IMPORTANTE:
% SUBSTITUA ESTA MATRIZ PELOS VALORES DA TABELA DO ENUNCIADO.

harmonicos = [
    1   0.015  0.220  0.150  0.000  0.102  0.084  0.000;  % 6-pulse
    1   0.002  0.006  0.003  0.000  0.062  0.045  0.000;  % 12-pulse
    1   0.000  0.170  0.101  0.000  0.061  0.044  0.000;  % SFC
    1   0.012  0.336  0.016  0.000  0.087  0.012  0.000;  % DC motor
    1   0.138  0.051  0.026  0.016  0.011  0.008  0.006   % TCR
];

numSinais = size(harmonicos,1);
THD = zeros(numSinais,1);
THD_percent = zeros(numSinais,1);

for i = 1:numSinais
    V1 = harmonicos(i,1);
    harmonicos_superiores = harmonicos(i,2:end);

    THD(i) = sqrt(sum(harmonicos_superiores.^2)) / V1;
    THD_percent(i) = THD(i) * 100;
end

fprintf('\n ITEM (e): THD DOS SINAIS \n');
for i = 1:numSinais
    fprintf('Sinal %d -> THD = %.6f  | THD%% = %.2f%%\n', ...
        i, THD(i), THD_percent(i));
end

%% ===============================================
% 11) TABELA RESUMO NA JANELA DE COMANDO
% ===============================================
fprintf('\nRESUMO \n');
fprintf('Sinal gerado: senoidal de %.2f Hz\n', f0);
fprintf('Amostras por ciclo: %d\n', amostrasPorCiclo);
fprintf('Numero de ciclos: %d\n', numCiclos);
fprintf('fs = %d Hz\n', fs);
fprintf('N total = %d\n', N);

%% ==========================================================
% FUNCOES LOCAIS
% ==========================================================
% Scripts com funções locais ao final.

function X = myFFT(x)
% myFFT - Implementa a FFT radix-2 recursiva
%
% Entrada:
%   x -> vetor do sinal no tempo
%
% Saida:
%   X -> transformada do sinal
%
% A ideia da FFT radix-2 e dividir o problema em:
% - amostras de indices pares
% - amostras de indices impares
% e combinar os resultados recursivamente.

    N = length(x);

    % Caso base da recursao:
    % se o vetor tem apenas 1 elemento, a "transformada" e ele mesmo
    if N == 1
        X = x;
        return;
    end

    % Verifica se N e par
    if mod(N,2) ~= 0
        error('O tamanho do vetor deve ser potencia de 2 para FFT radix-2.');
    end

    % Separa elementos de indices pares e impares
    x_par = x(1:2:end);
    x_impar = x(2:2:end);

    % Chamada recursiva para cada metade
    X_par = myFFT(x_par);
    X_impar = myFFT(x_impar);

    % Calcula os fatores rotacionais (twiddle factors)
    k = 0:(N/2 - 1);
    W = exp(-1j*2*pi*k/N);

    % Combina os resultados
    parte_superior = X_par + W .* X_impar;
    parte_inferior = X_par - W .* X_impar;

    X = [parte_superior, parte_inferior];
end

function X = myDFT(x)
% myDFT - Implementa a DFT direta pela definicao
%
% Entrada:
%   x -> vetor do sinal no tempo
%
% Saida:
%   X -> DFT do sinal
%
% Formula:
% X(k) = somatorio de n=0 ate N-1 de x(n)*exp(-j*2*pi*k*n/N)
% Visto nos slides

    N = length(x);
    X = zeros(1,N);

    % Dois lacos: um para k e outro para n
    for k = 0:N-1
        soma = 0;
        for n = 0:N-1
            soma = soma + x(n+1) * exp(-1j*2*pi*k*n/N);
        end
        X(k+1) = soma;
    end
end