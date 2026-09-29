# Simulation Results

## 1. Overview

The design was tested using a Verilog testbench
in Questa Simulator.

The testbench generates 64-sample sine waves at
four target frequencies.

## 2. Test Cases

| Test | Input Frequency | Expected Channel |
|------|-----------------|------------------|
| 1 | 250 Hz | 0 |
| 2 | 1000 Hz | 1 |
| 3 | 2500 Hz | 2 |
| 4 | 4500 Hz | 3 |

## 3. Results

| Input Frequency | Detected Channel | Result |
|-----------------|------------------|--------|
| 250 Hz | 0 | PASS |
| 1000 Hz | 1 | PASS |
| 2500 Hz | 2 | PASS |
| 4500 Hz | 3 | PASS |

## 4. Conclusion

All four test cases passed in the reported simulation.

The analyzer correctly identified the expected
dominant frequency channel for each tested input.

## 5. Future Improvements

- Test mixed-frequency input signals.
- Evaluate fixed-point precision and overflow.
- Optimize resource utilization.
- Validate timing constraints.
- Implement the design on an FPGA board.
