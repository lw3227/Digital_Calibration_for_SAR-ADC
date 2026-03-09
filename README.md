# Digital Calibration for 16-bit SAR ADC

This repository contains a 16-bit SAR ADC digital calibration project with both MATLAB behavioral modeling and FPGA (Vivado) implementation.

## Contents

- MATLAB behavioral model and algorithm verification (including dither-based calibration and dynamic performance analysis)
- Verilog LMS digital calibration core
- Vivado project sources
- Project documentation and upload guide

## Directory Structure

- `16bit_dither_calibration/`: MATLAB scripts for ADC modeling, calibration, and FFT-based metrics
- `VDAO_test/`: Vivado project and HDL sources
- `docs/`: repository documentation

## Key Files

- `16bit_dither_calibration/test.m`: main MATLAB simulation entry
- `16bit_dither_calibration/cal_dither.m`: dither calibration routine
- `16bit_dither_calibration/calculate_dynamic_spec.m`: SNR/SNDR/ENOB/SFDR calculation
- `VDAO_test/VDAO_test.srcs/sources_1/new/LMS_cali.v`: LMS weight update module
- `VDAO_test/VDAO_test.srcs/sources_1/new/cali_top.v`: top-level integration

## Run Instructions

### MATLAB

1. Open MATLAB and change working directory to `16bit_dither_calibration/`.
2. Run `test.m`.
3. Check calibration-before/after spectrum and dynamic metrics.

### Vivado

1. Open `VDAO_test/VDAO_test.xpr`.
2. Run synthesis/implementation/simulation as needed.
3. Top module: `cali_top`.

## Notes

- Auto-generated Vivado artifacts are excluded via `.gitignore`.
- Chinese PDF reports are intentionally not tracked in this public repository.
