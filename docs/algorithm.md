# Goertzel Algorithm

## 1. Introduction

The Goertzel algorithm is a digital signal processing
technique used to detect specific frequency components
in a sampled signal.

In this project, four Goertzel channels analyze the
input audio samples to identify the dominant frequency.

## 2. Target Frequencies

| Channel | Frequency |
|---------|-----------|
| 0       | 250 Hz    |
| 1       | 1000 Hz   |
| 2       | 2500 Hz   |
| 3       | 4500 Hz   |

## 3. Sampling Configuration

| Parameter | Value |
|-----------|-------|
| Sampling Frequency | 16 kHz |
| Sample Count | 64 |
| Frequency Resolution | 250 Hz |

Frequency resolution:

Resolution = Sampling Frequency / Sample Count

Resolution = 16000 / 64 = 250 Hz

## 4. Goertzel Recurrence

The recurrence relation is:

s[n] = x[n] + 2cos(ω)s[n-1] - s[n-2]

where:

- x[n] is the input sample
- s[n-1] is the previous state
- s[n-2] is the state before the previous one
- ω = 2πf/Fs

## 5. Energy Calculation

The energy at the target frequency is calculated
using the Goertzel power equation:

P = s1² + s2² - 2cos(ω)s1s2

The energy values are compared to determine
the dominant frequency channel.

## 6. Dominant Channel Selection

The channel with the maximum calculated energy
is selected as the dominant frequency channel.

The output channel mapping is:

- 0 → 250 Hz
- 1 → 1000 Hz
- 2 → 2500 Hz
- 3 → 4500 Hz
