#!/usr/bin/env python3
"""Generates the combat toy's placeholder sounds as 16-bit mono WAVs.

Project-owned (made by this script, no third-party samples), logged in
ASSET_REGISTER.md. Placeholders only: the hum and the gunshot are the
mechanic, so the toy needs them audible, not beautiful.

Usage: python3 tools/art_src/make_toy_sounds.py [out_dir]
"""
import sys
import wave
from pathlib import Path

import numpy as np

RATE = 44100
rng = np.random.default_rng(7)


def t(seconds):
    return np.arange(int(RATE * seconds)) / RATE


def env(n, attack=0.002, decay=0.2):
    x = np.arange(n) / RATE
    a = np.clip(x / max(attack, 1e-6), 0, 1)
    return a * np.exp(-x / decay)


def lowpass(sig, alpha):
    out = np.empty_like(sig)
    acc = 0.0
    for i, v in enumerate(sig):
        acc += alpha * (v - acc)
        out[i] = acc
    return out


def noise(n):
    return rng.uniform(-1, 1, n)


def write(path, sig, gain=0.9):
    sig = sig / (np.max(np.abs(sig)) + 1e-9) * gain
    data = (sig * 32767).astype("<i2")
    with wave.open(str(path), "wb") as w:
        w.setnchannels(1)
        w.setsampwidth(2)
        w.setframerate(RATE)
        w.writeframes(data.tobytes())


def hum():
    # 4 s loop of a low machine hum: whole cycles of 55 Hz and harmonics, so
    # the loop point is seamless.
    x = t(4.0)
    s = (np.sin(2 * np.pi * 55 * x) + 0.5 * np.sin(2 * np.pi * 110 * x)
         + 0.25 * np.sin(2 * np.pi * 165 * x) + 0.12 * np.sin(2 * np.pi * 220 * x))
    s *= 1.0 + 0.08 * np.sin(2 * np.pi * 0.5 * x)
    return s


def shot_loud():
    n = int(RATE * 0.6)
    body = lowpass(noise(n), 0.35) * env(n, 0.001, 0.09)
    thump = np.sin(2 * np.pi * 70 * t(0.6)) * env(n, 0.001, 0.12)
    tail = lowpass(noise(n), 0.05) * env(n, 0.01, 0.35) * 0.5
    return body + thump + tail


def shot_quiet():
    n = int(RATE * 0.25)
    return lowpass(noise(n), 0.12) * env(n, 0.001, 0.03) + 0.4 * np.sin(2 * np.pi * 140 * t(0.25)) * env(n, 0.001, 0.04)


def melee():
    n = int(RATE * 0.25)
    whoosh = lowpass(noise(n), 0.08) * np.sin(np.pi * np.arange(n) / n) * 0.6
    thud = np.sin(2 * np.pi * 95 * t(0.25)) * env(n, 0.001, 0.05)
    return whoosh + thud


def flesh():
    n = int(RATE * 0.18)
    return lowpass(noise(n), 0.2) * env(n, 0.001, 0.04) + 0.5 * np.sin(2 * np.pi * 120 * t(0.18)) * env(n, 0.001, 0.05)


def growl():
    # The tell before a hit: a rising throaty growl, 0.5 s.
    x = t(0.5)
    f = 90 + 60 * x
    s = np.sign(np.sin(2 * np.pi * np.cumsum(f) / RATE)) * 0.4
    s = lowpass(s + 0.5 * noise(len(x)), 0.06)
    return s * np.clip(x / 0.1, 0, 1) * np.clip((0.5 - x) / 0.08, 0, 1)


def knock():
    n = int(RATE * 0.2)
    return np.sin(2 * np.pi * 180 * t(0.2)) * env(n, 0.001, 0.03) + lowpass(noise(n), 0.3) * env(n, 0.001, 0.01)


def crash():
    n = int(RATE * 0.9)
    return lowpass(noise(n), 0.25) * env(n, 0.002, 0.25) + 0.6 * np.sin(2 * np.pi * 60 * t(0.9)) * env(n, 0.002, 0.2)


def shelter_hit():
    n = int(RATE * 0.4)
    metal = (np.sin(2 * np.pi * 410 * t(0.4)) + 0.6 * np.sin(2 * np.pi * 637 * t(0.4))) * env(n, 0.001, 0.12)
    return metal * 0.6 + np.pad(knock(), (0, n - int(RATE * 0.2)))


def hurt():
    n = int(RATE * 0.3)
    return lowpass(noise(n), 0.15) * env(n, 0.001, 0.08) + np.sin(2 * np.pi * 220 * t(0.3) * (1 - 0.5 * t(0.3))) * env(n, 0.001, 0.1)


def build():
    n = int(RATE * 0.15)
    return np.sin(2 * np.pi * 330 * t(0.15)) * env(n, 0.001, 0.04) + 0.4 * knock()[:n]


def dawn():
    x = t(2.0)
    s = sum(np.sin(2 * np.pi * f * x) * (0.6 ** i) for i, f in enumerate([392, 494, 587]))
    return s * np.clip(x / 0.3, 0, 1) * np.exp(-x / 0.9)


def sting():
    x = t(2.0)
    s = sum(np.sin(2 * np.pi * f * x) for f in [110, 116.5, 164.8])
    return lowpass(s, 0.1) * np.clip(x / 0.05, 0, 1) * np.exp(-x / 0.8)


SOUNDS = {
    "hum": (hum, 0.8), "shot_loud": (shot_loud, 0.95), "shot_quiet": (shot_quiet, 0.7),
    "melee": (melee, 0.8), "flesh": (flesh, 0.7), "growl": (growl, 0.6), "knock": (knock, 0.7),
    "crash": (crash, 0.9), "shelter_hit": (shelter_hit, 0.85), "hurt": (hurt, 0.8),
    "build": (build, 0.6), "dawn": (dawn, 0.7), "sting": (sting, 0.8),
}


def main():
    out = Path(sys.argv[1] if len(sys.argv) > 1 else "assets/audio/toy")
    out.mkdir(parents=True, exist_ok=True)
    for name, (fn, gain) in SOUNDS.items():
        write(out / f"{name}.wav", fn(), gain)
        print("wrote", out / f"{name}.wav")


if __name__ == "__main__":
    main()
