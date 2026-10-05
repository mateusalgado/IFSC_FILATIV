"""Compara a varredura AC do Proteus com as novas telas de U1 e U2."""

import csv
from pathlib import Path

import matplotlib
matplotlib.use("Agg")
import matplotlib.pyplot as plt
import numpy as np

base = Path(__file__).resolve().parent
with (base / "LM741.DAT").open(newline="") as stream:
    data = list(csv.DictReader(stream))

frequencies = np.array([float(row["FREQ"]) for row in data])
measurements = {
    "U1": {
        "f": np.array([100, 499, 1000, 9980, 50250, 99950, 200600, 498200, 995400]),
        "ve": np.array([.532, .532, .528, .528, .516, .528, .520, .516, .528]),
        "vs": np.array([1.04, 1.04, 1.04, 1.03, 1.02, 1.02, .760, .328, .216]),
        "linear_count": 6,
        "nominal_db": 20 * np.log10(2),
        "fc": 631000,
        "color": "#155e75",
    },
    "U2": {
        "f": np.array([100, 1000, 10000, 20020, 50000, 99800, 193700, 500500]),
        "ve": np.array([.512, .496, .538, .564, .620, .496, .496, .552]),
        "vs": np.array([5.60, 5.60, 5.52, 5.40, 3.20, 1.64, .840, .348]),
        "linear_count": 3,
        "nominal_db": 20 * np.log10(11),
        "fc": 91900,
        "color": "#9a3412",
    },
}

fig, axes = plt.subplots(2, 1, figsize=(9.0, 6.5), sharex=True)
for ax, (name, values) in zip(axes, measurements.items()):
    sim_db = np.array([float(row[f"{name}(OP)"]) for row in data])
    f = values["f"]
    measured_db = 20 * np.log10(values["vs"] / values["ve"])
    n = values["linear_count"]
    color = values["color"]

    ax.semilogx(frequencies, sim_db, color=color, lw=2, label="Proteus: análise AC")
    ax.axhline(values["nominal_db"], color="#6b7280", ls=":", lw=1,
               label="ganho nominal")
    ax.axvline(values["fc"], color="#6b7280", ls="--", lw=1,
               label="corte AC simulado")
    ax.scatter(f[:n], measured_db[:n], s=40, color="#166534", zorder=3,
               label="bancada: saída senoidal")
    ax.scatter(f[n:], measured_db[n:], s=48, marker="x", lw=2,
               color="#b91c1c", zorder=3, label="bancada: saída deformada")
    ax.set_title(f"{name}: ganho nominal {2 if name == 'U1' else 11} V/V", loc="left")
    ax.set_ylabel("Ganho (dB)")
    ax.grid(True, which="both", alpha=.22)
    ax.set_xlim(80, 1.2e6)
    ax.set_ylim((-12, 10) if name == "U1" else (-7, 25))
    ax.legend(loc="lower left", fontsize=8, ncol=2)

axes[-1].set_xlabel("Frequência (Hz)")
fig.suptitle("LM741: simulação de pequenos sinais e bancada", fontsize=13, weight="bold")
fig.tight_layout()
target = base / "imgs" / "geradas" / "comparativo_bancada_simulacao_u1_u2.png"
fig.savefig(target, dpi=200, bbox_inches="tight")
print(target)

for name, values in measurements.items():
    f = values["f"]
    db = 20 * np.log10(values["vs"] / values["ve"])
    sim = np.array([float(row[f"{name}(OP)"]) for row in data])
    sim_at_f = np.interp(np.log10(f), np.log10(frequencies), sim)
    print(name, [(round(freq), round(obs, 2), round(ref, 2))
                 for freq, obs, ref in zip(f, db, sim_at_f)])
