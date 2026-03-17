import numpy as np
from pathlib import Path

# ===================================================
# FUNÇÃO: ler_vetor
# Objetivo:
# Ler um arquivo .txt com números separados por ';'
# e transformar esse conteúdo em um vetor NumPy.
# ===================================================
def ler_vetor(caminho_arquivo):
    # Abre o arquivo em modo leitura
    with open(caminho_arquivo, "r", encoding="utf-8") as arquivo:
        conteudo = arquivo.read()

    # Remove quebras de linha e espaços extras
    conteudo = conteudo.replace("\n", "").replace("\r", "").strip()

    # Divide o texto usando ';' como separador
    # e converte cada elemento para float
    valores = [float(v) for v in conteudo.split(";") if v.strip() != ""]

    # Retorna os valores como um array NumPy
    return np.array(valores, dtype=float)


# ===================================================
# FUNÇÃO: dft
# Objetivo:
# Implementar manualmente a Transformada Discreta de
# Fourier (DFT), conforme a fórmula vista em aula.
#
# Entrada:
#   x -> vetor do sinal no domínio do tempo
#
# Saída:
#   X -> vetor complexo com o espectro em frequência
# ===================================================
def dft(x):
    # Número de amostras do sinal
    N = len(x)

    # Cria um vetor complexo para armazenar a DFT
    X = np.zeros(N, dtype=complex)

    # Loop externo: percorre cada índice de frequência k
    for k in range(N):
        # Inicializa a soma complexa da fórmula da DFT
        soma = 0j

        # Loop interno: percorre cada amostra do sinal no tempo
        for n in range(N):
            # Fórmula da DFT:
            # X[k] = soma de x[n] * e^(-j*2*pi*k*n/N)
            soma += x[n] * np.exp(-2j * np.pi * k * n / N)

        # Armazena o valor calculado para a frequência k
        X[k] = soma

    # Retorna o vetor da DFT
    return X


# ===================================================
# FUNÇÃO: espectro_unilateral
# A partir da DFT, gerar:
#   - vetor de frequências em Hz
#   - vetor de amplitudes do espectro unilateral
#
# Entrada:
#   X  -> resultado da DFT
#   fs -> frequência de amostragem
#
# Saída:
#   freq_pos -> frequências positivas
#   amp      -> amplitudes associadas
# ===================================================
def espectro_unilateral(X, fs):
    # Número total de pontos da DFT
    N = len(X)

    # Constrói o vetor de frequências correspondente a cada índice da DFT
    # fk = k*fs/N
    freq = np.arange(N) * fs / N

    # Caso N seja par
    if N % 2 == 0:
        # Índice da metade do espectro
        metade = N // 2

        # Mantém apenas a parte positiva do espectro, incluindo Nyquist
        freq_pos = freq[:metade + 1]

        # Calcula a amplitude normalizada
        amp = np.abs(X[:metade + 1]) / N

        # Como estamos usando espectro unilateral,
        # dobramos as amplitudes internas
        # (exceto DC e Nyquist)
        amp[1:-1] *= 2

    # Caso N seja ímpar
    else:
        metade = N // 2

        # Mantém apenas a parte positiva
        freq_pos = freq[:metade + 1]

        # Calcula a amplitude normalizada
        amp = np.abs(X[:metade + 1]) / N

        # Para N ímpar, dobramos todas as amplitudes
        # exceto a componente DC
        amp[1:] *= 2

    # Retorna frequências positivas e amplitudes
    return freq_pos, amp


# ===================================================
# FUNÇÃO: encontrar_harmonicos
# Encontrar picos no espectro que representem
# frequências relevantes do sinal.
#
# Entrada:
#   freq             -> vetor de frequências
#   amp              -> vetor de amplitudes
#   limiar_relativo  -> percentual da maior amplitude
#                       usado para filtrar picos pequenos
#
# Saída:
#   índices dos picos encontrados
# ===================================================
def encontrar_harmonicos(freq, amp, limiar_relativo=0.05):
    # Se o espectro tiver menos de 3 pontos,
    # não há como verificar pico local
    if len(amp) < 3:
        return np.array([], dtype=int)

    # Ignora a componente DC (0 Hz) ao calcular o limiar
    amp_sem_dc = amp[1:] if len(amp) > 1 else amp

    # Define o valor mínimo para um pico ser considerado relevante
    limiar = limiar_relativo * np.max(amp_sem_dc)

    # Lista para armazenar os índices dos picos
    indices = []

    # Percorre o vetor de amplitudes procurando máximos locais
    for i in range(1, len(amp) - 1):
        # Um pico é aceito se:
        # 1) for maior que o vizinho anterior
        # 2) for maior ou igual ao próximo
        # 3) estiver acima do limiar mínimo
        if amp[i] > amp[i - 1] and amp[i] >= amp[i + 1] and amp[i] >= limiar:
            indices.append(i)

    # Retorna os índices encontrados como array NumPy
    return np.array(indices, dtype=int)


# ===================================================
# FUNÇÃO PRINCIPAL
# 1. Encontrar os arquivos na mesma pasta do script
# 2. Ler sinal e tempos
# 3. Calcular frequência de amostragem
# 4. Calcular a DFT
# 5. Gerar o espectro unilateral
# 6. Detectar harmônicos
# 7. Exibir resultados
# ===================================================
def main():
    # Descobre automaticamente a pasta onde está este script Python
    pasta = Path(__file__).resolve().parent

    # Monta os caminhos completos dos arquivos de entrada
    arquivo_sinal = pasta / "Sinal.txt"
    arquivo_tempo = pasta / "TimeStamp.txt"

    # Lê os dados dos arquivos
    sinal = ler_vetor(arquivo_sinal)
    tempo = ler_vetor(arquivo_tempo)

    # Verifica se os dois vetores têm o mesmo tamanho
    # Cada amostra do sinal deve ter um instante correspondente
    if len(sinal) != len(tempo):
        raise ValueError(
            f"O número de amostras é diferente: sinal={len(sinal)} e tempo={len(tempo)}"
        )

    # Número total de amostras
    N = len(sinal)

    # Calcula a diferença entre instantes consecutivos
    dt = np.diff(tempo)

    # Calcula o passo médio de amostragem
    dt_medio = np.mean(dt)

    # Frequência de amostragem: fs = 1 / dt
    fs = 1 / dt_medio

    # ----------------------------
    # Exibição inicial dos dados
    # ----------------------------
    print("=" * 50)
    print("LEITURA DOS ARQUIVOS")
    print("=" * 50)
    print(f"Arquivo do sinal: {arquivo_sinal}")
    print(f"Arquivo do tempo: {arquivo_tempo}")
    print(f"Quantidade de amostras: {N}")
    print(f"Primeiras 5 amostras do sinal: {sinal[:5]}")
    print(f"Primeiros 5 instantes: {tempo[:5]}")

    # ----------------------------
    # Exibição da frequência de amostragem
    # ----------------------------
    print("\n" + "=" * 50)
    print("FREQUÊNCIA DE AMOSTRAGEM")
    print("=" * 50)
    print(f"dt médio = {dt_medio:.12f} s")
    print(f"fs = {fs:.6f} Hz")

    # Calcula a DFT do sinal
    X = dft(sinal)

    # Gera o espectro unilateral
    freq, amp = espectro_unilateral(X, fs)

    # Procura picos no espectro
    indices_harmonicos = encontrar_harmonicos(freq, amp, limiar_relativo=0.05)

    # Remove a componente em 0 Hz, se aparecer
    indices_harmonicos = indices_harmonicos[freq[indices_harmonicos] > 0]

    # ----------------------------
    # Exibição dos harmônicos encontrados
    # ----------------------------
    print("\n" + "=" * 50)
    print("HARMÔNICOS ENCONTRADOS")
    print("=" * 50)

    # Se nenhum pico foi encontrado, encerra
    if len(indices_harmonicos) == 0:
        print("Nenhum harmônico encontrado com o limiar atual.")
        return

    # A frequência fundamental é o menor pico positivo encontrado
    indice_fundamental = indices_harmonicos[np.argmin(freq[indices_harmonicos])]

    # Frequência e amplitude da fundamental
    freq_fundamental = freq[indice_fundamental]
    amp_fundamental = amp[indice_fundamental]

    # Mostra a componente fundamental
    print(f"Frequência fundamental: {freq_fundamental:.6f} Hz")
    print(f"Amplitude fundamental:  {amp_fundamental:.6f}\n")

    # Mostra todos os harmônicos detectados
    for idx in indices_harmonicos:
        print(f"Frequência = {freq[idx]:.6f} Hz | Amplitude = {amp[idx]:.6f}")


# ===================================================
# Ponto de entrada do programa
# O código dentro de main() só será executado se este
# arquivo for rodado diretamente.
# ===================================================
if __name__ == "__main__":
    main()