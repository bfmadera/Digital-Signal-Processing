%% EXERCICIO 5 - SEL0615
% Bárbara Fernandes Madera - 11915032
%
% Este script resolve:
% 1) Processamento de imagem RGB
% 2) Compressão de áudio mantendo 5% e 1% dos coeficientes
%
% Arquivo analisado na pasta:
% - imagem.jpg
% - musica.wav

clc;
clear;
close all;

%% =========================================================
% PARTE 1 - IMAGEM RGB
% ==========================================================

% Leitura da imagem
img = imread('imagem.jpg');

% Garantia de que a imagem está em RGB
if size(img,3) ~= 3
    error('A imagem precisa ser colorida no formato RGB.');
end

% Separação dos canais
R = img(:,:,1);
G = img(:,:,2);
B = img(:,:,3);

%% 1(a) Mostrar os três canais de cor
figure;
subplot(2,2,1);
imshow(img);
title('Imagem RGB original');

subplot(2,2,2);
imshow(R);
title('Canal R');

subplot(2,2,3);
imshow(G);
title('Canal G');

subplot(2,2,4);
imshow(B);
title('Canal B');

%% 1(b) Criar duas máscaras com raios diferentes
% Aqui escolhi dois raios:
raio1 = 25;
raio2 = 45;

% Tamanho da máscara
% Usamos 2*raio + 1 para ter centro bem definido
tam1 = 2*raio1 + 1;
tam2 = 2*raio2 + 1;

% Criação das máscaras circulares
mascara1 = criarMascaraCircular(tam1, raio1);
mascara2 = criarMascaraCircular(tam2, raio2);

% Mostrar as máscaras
figure;
subplot(1,2,1);
imshow(mascara1, []);
title(['Mascara circular - raio = ', num2str(raio1)]);

subplot(1,2,2);
imshow(mascara2, []);
title(['Mascara circular - raio = ', num2str(raio2)]);

%% 1(c) Aplicar as máscaras para cada canal e reconstruir a imagem RGB filtrada
% A aplicação será feita no domínio da frequência.
% Cada canal é transformado por FFT, filtrado e reconstruído.

% Filtragem com a máscara 1
R_filtrado_1 = aplicarMascaraFrequencia(double(R), mascara1);
G_filtrado_1 = aplicarMascaraFrequencia(double(G), mascara1);
B_filtrado_1 = aplicarMascaraFrequencia(double(B), mascara1);

img_filtrada_1 = cat(3, ...
    uint8(ajustarIntervalo(R_filtrado_1)), ...
    uint8(ajustarIntervalo(G_filtrado_1)), ...
    uint8(ajustarIntervalo(B_filtrado_1)));

% Filtragem com a máscara 2
R_filtrado_2 = aplicarMascaraFrequencia(double(R), mascara2);
G_filtrado_2 = aplicarMascaraFrequencia(double(G), mascara2);
B_filtrado_2 = aplicarMascaraFrequencia(double(B), mascara2);

img_filtrada_2 = cat(3, ...
    uint8(ajustarIntervalo(R_filtrado_2)), ...
    uint8(ajustarIntervalo(G_filtrado_2)), ...
    uint8(ajustarIntervalo(B_filtrado_2)));

% Mostrar as imagens filtradas
figure;
subplot(1,3,1);
imshow(img);
title('Imagem original');

subplot(1,3,2);
imshow(img_filtrada_1);
title(['Imagem filtrada - raio = ', num2str(raio1)]);

subplot(1,3,3);
imshow(img_filtrada_2);
title(['Imagem filtrada - raio = ', num2str(raio2)]);

%% =========================================================
% PARTE 2 - AUDIO
% ==========================================================

% Leitura do áudio
[audio, fs] = audioread('musica.wav');

% Se o áudio tiver dois canais, transformar em mono para simplificar
if size(audio,2) == 2
    audio = mean(audio, 2);
end

N = length(audio);

%% FFT do áudio
X = fft(audio);

% Magnitude dos coeficientes
magX = abs(X);

%% 2(a) Compressão mantendo 5% dos coeficientes de maior magnitude
percentual1 = 0.05;
audio_5 = comprimirAudioFFT(audio, percentual1);

% Salvar
audiowrite('musica_comprimida_5porcento.wav', audio_5, fs);

%% 2(b) Compressão mantendo 1% dos coeficientes de maior magnitude
percentual2 = 0.01;
audio_1 = comprimirAudioFFT(audio, percentual2);

% Salvar
audiowrite('musica_comprimida_1porcento.wav', audio_1, fs);

%% Mostrar comparação no tempo
t = (0:N-1)/fs;

figure;
subplot(3,1,1);
plot(t, audio);
title('Audio original');
xlabel('Tempo (s)');
ylabel('Amplitude');

subplot(3,1,2);
plot(t, audio_5);
title('Audio comprimido - 5% dos coeficientes');
xlabel('Tempo (s)');
ylabel('Amplitude');

subplot(3,1,3);
plot(t, audio_1);
title('Audio comprimido - 1% dos coeficientes');
xlabel('Tempo (s)');
ylabel('Amplitude');

%% Mostrar espectros
X_5 = fft(audio_5);
X_1 = fft(audio_1);
f = (0:N-1)*(fs/N);

figure;
subplot(3,1,1);
plot(f(1:floor(N/2)), abs(X(1:floor(N/2))));
title('Espectro do audio original');
xlabel('Frequencia (Hz)');
ylabel('Magnitude');

subplot(3,1,2);
plot(f(1:floor(N/2)), abs(X_5(1:floor(N/2))));
title('Espectro do audio comprimido - 5%');
xlabel('Frequencia (Hz)');
ylabel('Magnitude');

subplot(3,1,3);
plot(f(1:floor(N/2)), abs(X_1(1:floor(N/2))));
title('Espectro do audio comprimido - 1%');
xlabel('Frequencia (Hz)');
ylabel('Magnitude');

%% Informacoes finais
fprintf('Arquivos gerados com sucesso:\n');
fprintf('- musica_comprimida_5porcento.wav\n');
fprintf('- musica_comprimida_1porcento.wav\n');

%% =========================================================
% FUNCOES LOCAIS
% ==========================================================

function mascara = criarMascaraCircular(tamanho, raio)
% Cria uma máscara circular binária

    centro = ceil(tamanho/2);
    mascara = zeros(tamanho, tamanho);

    for i = 1:tamanho
        for j = 1:tamanho
            dist = sqrt((i-centro)^2 + (j-centro)^2);
            if dist <= raio
                mascara(i,j) = 1;
            end
        end
    end
end

function img_filtrada = aplicarMascaraFrequencia(img, mascaraPequena)
% Aplica uma máscara no domínio da frequência
% A máscara pequena é centralizada e expandida para o tamanho da imagem

    [M, N] = size(img);

    % FFT e centralização
    F = fft2(img);
    Fshift = fftshift(F);

    % Criar máscara do tamanho da imagem
    mascara = zeros(M, N);

    [mMask, nMask] = size(mascaraPequena);

    iniM = floor((M - mMask)/2) + 1;
    fimM = iniM + mMask - 1;
    iniN = floor((N - nMask)/2) + 1;
    fimN = iniN + nMask - 1;

    mascara(iniM:fimM, iniN:fimN) = mascaraPequena;

    % Aplicar filtro
    Ffiltrado = Fshift .* mascara;

    % Volta para domínio da imagem
    img_filtrada = real(ifft2(ifftshift(Ffiltrado)));
end

function saida = ajustarIntervalo(img)
% Ajusta a imagem para o intervalo [0,255]

    img = img - min(img(:));
    if max(img(:)) > 0
        img = img / max(img(:));
    end
    saida = 255 * img;
end

function audio_comprimido = comprimirAudioFFT(audio, percentual)
% Mantém apenas uma porcentagem dos maiores coeficientes em magnitude

    X = fft(audio);
    N = length(X);

    % Número de coeficientes a manter
    K = round(percentual * N);

    % Ordenar magnitudes
    [~, indices] = sort(abs(X), 'descend');

    % Criar vetor zerado
    X_comp = zeros(size(X));

    % Manter apenas os K maiores coeficientes
    X_comp(indices(1:K)) = X(indices(1:K));

    % Reconstrução
    audio_comprimido = real(ifft(X_comp));

    % Normalizar para evitar clipping
    maxVal = max(abs(audio_comprimido));
    if maxVal > 0
        audio_comprimido = audio_comprimido / maxVal;
    end
end