# System Architecture

## 1. Overview

The Cochlea-Inspired Auditory Frequency Analyzer is a
Verilog-based digital signal processing system that identifies
the dominant frequency in an input audio signal.

The design uses four parallel Goertzel algorithm channels
to detect four target frequencies:

- 250 Hz
- 1000 Hz
- 2500 Hz
- 4500 Hz

## 2. Architecture

The system consists of the following blocks:

1. Audio Sample Input
2. Sample Capture Controller
3. Four Goertzel Processing Channels
4. Energy Calculation Unit
5. Dominant Frequency Selection Unit
6. Control FSM
7. Output Interface

## 3. Signal Flow

Audio Samples
      |
      v
Sample Capture
      |
      v
+-------------------------+
| Goertzel Processing     |
|                         |
| Channel 0: 250 Hz       |
| Channel 1: 1000 Hz      |
| Channel 2: 2500 Hz      |
| Channel 3: 4500 Hz      |
+-------------------------+
      |
      v
Energy Calculation
      |
      v
Dominant Channel Selection
      |
      v
Dominant Frequency Output

## 4. Control Unit

The FSM controls the processing sequence.

### IDLE
Waits for the start signal.

### CAPTURE
Accepts 64 valid audio samples and updates the
Goertzel processing states.

### CALC
Calculates the energy of each frequency channel
and selects the channel with the highest energy.

## 5. Output

The system provides:

- Dominant frequency channel
- Energy values for all four channels
- Done signal
- Busy signal
