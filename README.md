# Cochlea-Inspired Auditory Frequency Analyzer

## Overview

This project implements a Cochlea-Inspired Auditory Frequency Analyzer using Verilog HDL.

The system is inspired by the frequency-selective processing of the human cochlea.

It uses four parallel Goertzel frequency detection channels to identify the dominant frequency in a digital audio signal.

The design processes 64 audio samples per analysis window and detects four target frequencies:

- 250 Hz
- 1,000 Hz
- 2,500 Hz
- 4,500 Hz

The project is simulated using Questa and is intended for FPGA implementation using Intel Quartus Prime Lite.

---

## Key Features

- Four parallel Goertzel frequency detection channels
- Digital audio sample processing
- Frequency-specific energy calculation
- Dominant frequency selection
- Finite State Machine (FSM)-based control
- Fixed-point arithmetic
- Configurable sampling window
- Verilog RTL implementation
- Functional verification using a Verilog testbench

---

## System Parameters

| Parameter | Value |
|---|---|
| Sampling Frequency | 16,000 Hz |
| Samples per Window | 64 |
| Frequency Resolution | 250 Hz |
| Input Sample Width | 16 bits |
| Number of Frequency Channels | 4 |
| Target Frequencies | 250, 1,000, 2,500, 4,500 Hz |

---

## System Architecture

```text
         Digital Audio Samples
                   |
                   v
         +--------------------+
         | Input Sample       |
         | Interface          |
         +--------------------+
                   |
                   v
         +--------------------+
         | Four Parallel      |
         | Goertzel Filters   |
         +--------------------+
                   |
                   v
         +--------------------+
         | Energy Calculation |
         +--------------------+
                   |
                   v
         +--------------------+
         | Energy Comparison  |
         +--------------------+
                   |
                   v
         +--------------------+
         | Dominant Frequency |
         | Selection          |
         +--------------------+
                   |
                   v
            Dominant Channel
