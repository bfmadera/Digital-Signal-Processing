import numpy as np
import matplotlib.pyplot as plt

# ============================================================
# EXERCÍCIO 3 - PROCESSAMENTO DIGITAL DE SINAIS
# Nome: SEU NOME
# Nº USP: SEU NUMERO USP
# ============================================================

# -----------------------------
# 1) Parâmetros do sinal
# -----------------------------
f0 = 50          # frequência fundamental (Hz)
A0 = 1.0         # amplitude da fundamental

f1 = 300         # harmônica 1 (Hz)
A1 = 0.5         # amplitude da harmônica 1

f2 = 500         # harmônica 2 (Hz)
A2 = 0.25        # amplitude da harmônica 2

amostras_por_ciclo = 128
fs = f0 * amostras_por_ciclo      # frequência de amostragem
T_total = 0.11                    # tempo total de amostragem (s)
N = int(fs * T_total)             # número de amostras
t = np.arange(N) / fs             # vetor de tempo

print("Frequência de amostragem fs =", fs, "Hz")
print("Número de amostras N =", N)
print("Resolução espectral df =", fs / N, "Hz")

# -----------------------------
# 2) Geração do sinal
# -----------------------------
x = (
    A0 * np.sin(2 * np.pi * f0 * t) +
    A1 * np.sin(2 * np.pi * f1 * t) +
    A2 * np.sin(2 * np.pi * f2 * t)
)

# -----------------------------
# 3) Funções auxiliares
# -----------------------------
def compute_spectrum(signal, fs):
    """
    Calcula espectro unilateral usando rFFT.
    Retorna:
      freqs -> vetor de frequências
      X     -> DFT unilateral complexa
      mag   -> magnitude unilateral normalizada
    """
    N = len(signal)
    X = np.fft.rfft(signal)
    freqs = np.fft.rfftfreq(N, d=1/fs)

    # magnitude unilateral normalizada
    mag = np.abs(X) / N
    if N % 2 == 0:
        mag[1:-1] *= 2
    else:
        mag[1:] *= 2

    return freqs, X, mag


def band_energy_from_dft(X, freqs, fmin, fmax, N):
    """
    Calcula a energia na banda [fmin, fmax] usando Parseval.
    Como usamos espectro unilateral, dobramos os bins internos.
    """
    mask = (freqs >= fmin) & (freqs <= fmax)

    E = 0.0
    for i in np.where(mask)[0]:
        if i == 0:
            E += (1 / N) * (np.abs(X[i]) ** 2)
        elif (N % 2 == 0) and (i == len(X) - 1):
            # bin de Nyquist (se existir)
            E += (1 / N) * (np.abs(X[i]) ** 2)
        else:
            E += (2 / N) * (np.abs(X[i]) ** 2)

    return E


def check_leakage(freqs_reais, fs, N):
    """
    Verifica se cada frequência cai exatamente em um bin da DFT.
    Se não cair, há tendência de leakage.
    """
    df = fs / N
    print("\nVerificação de leakage:")
    for f in freqs_reais:
        bin_teorico = f / df
        print(f"f = {f:6.1f} Hz -> bin = {bin_teorico:.4f}")
        if not np.isclose(bin_teorico, round(bin_teorico), atol=1e-10):
            print("  -> não cai exatamente em bin inteiro: pode haver leakage")
        else:
            print("  -> cai em bin inteiro: tendência de pico mais concentrado")


def plot_spectrum(freqs, mag, title):
    plt.figure(figsize=(10, 4))
    plt.plot(freqs, mag)
    plt.xlim(0, 1000)
    plt.xlabel("Frequência (Hz)")
    plt.ylabel("Magnitude")
    plt.title(title)
    plt.grid(True)
    plt.tight_layout()
    plt.show()


# -----------------------------
# 4) Item (a): DFT do sinal sem janela
# -----------------------------
freqs, X, mag = compute_spectrum(x, fs)
plot_spectrum(freqs, mag, "Espectro do sinal sem janela")

check_leakage([f0, f1, f2], fs, N)

# -----------------------------
# 5) Item (b): energia de 0 Hz a 1 kHz
# -----------------------------
E_sem_janela = band_energy_from_dft(X, freqs, 0, 1000, N)
print("\nEnergia na banda de 0 Hz a 1 kHz (sem janela):", E_sem_janela)

# Também podemos mostrar a energia total no tempo para comparação
E_tempo = np.sum(x**2)
print("Energia total do sinal no tempo:", E_tempo)

# -----------------------------
# 6) Item (c): DFT janelada
# -----------------------------
windows = {
    "Retangular": np.ones(N),
    "Hann": np.hanning(N),
    "Hamming": np.hamming(N),
    "Blackman": np.blackman(N)
}

energias_janelas = {}

for nome, w in windows.items():
    xw = x * w
    freqs_w, X_w, mag_w = compute_spectrum(xw, fs)
    plot_spectrum(freqs_w, mag_w, f"Espectro com janela {nome}")

    # -----------------------------
    # 7) Item (d): energia da banda 0 Hz a 1 kHz
    # -----------------------------
    E_w = band_energy_from_dft(X_w, freqs_w, 0, 1000, N)
    energias_janelas[nome] = E_w

# -----------------------------
# 8) Exibição final dos resultados
# -----------------------------
print("\n================ RESULTADOS DE ENERGIA ================")
print(f"Sem janela    : {E_sem_janela}")
for nome, E in energias_janelas.items():
    print(f"{nome:12s}: {E}")

# -----------------------------
# 9) Gráfico comparativo das energias
# -----------------------------
labels = ["Sem janela"] + list(energias_janelas.keys())
valores = [E_sem_janela] + list(energias_janelas.values())

plt.figure(figsize=(8, 4))
plt.bar(labels, valores)
plt.ylabel("Energia na banda de 0 Hz a 1 kHz")
plt.title("Comparação das energias")
plt.grid(axis="y")
plt.tight_layout()
plt.show()