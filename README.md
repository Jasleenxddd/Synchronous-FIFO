# fifo-sv-verification

> A complete SystemVerilog design and constrained-random verification environment for a parameterizable Synchronous FIFO, featuring a scoreboard, functional coverage, and SVA assertions.

---

## Table of Contents

- [Overview](#overview)
- [Features](#features)
- [Project Structure](#project-structure)
- [Design Parameters](#design-parameters)
- [Verification Architecture](#verification-architecture)
- [Getting Started](#getting-started)
- [Running the Simulation](#running-the-simulation)
- [Coverage](#coverage)
  - [Functional Coverage Results](#functional-coverage-results)
  - [Cross Coverage Results](#cross-coverage-results)
  - [SVA Directive Coverage](#sva-directive-coverage)
  - [Code Coverage](#code-coverage)
- [Assertions (SVA)](#assertions-sva)
- [File Descriptions](#file-descriptions)

---

## Overview

This project implements a **parameterizable Synchronous FIFO** in SystemVerilog and verifies it using a structured, class-based testbench. The verification environment applies **constrained-random stimulus** (10,000 randomized transactions), checks correctness through a **self-checking scoreboard**, and measures completeness via **functional coverage groups**.

The design and testbench were developed as part of a *Digital Verification using SystemVerilog & UVM* course.

---

## Features

- **RTL Design**
  - Parameterizable width (`FIFO_WIDTH`, default 16-bit) and depth (`FIFO_DEPTH`, default 8 entries)
  - Synchronous read/write with active-low asynchronous reset
  - Status flags: `full`, `empty`, `almostfull`, `almostempty`
  - Error flags: `overflow`, `underflow`, `wr_ack`
  - Correct handling of simultaneous read/write edge cases

- **Verification Environment**
  - Modport-based `FIFO_if` interface (DUT, TEST, MONITOR views)
  - Constrained-random transaction class with `randomize()`
  - Dedicated monitor, scoreboard, and coverage collector components
  - 10,000-cycle random regression

- **Formal & Coverage**
  - 11 SystemVerilog Assertions (SVA) compiled under `` `ifdef SIM ``
  - Functional coverage bins for all status/error signals and corner cases

---

## Project Structure

```
fifo-sv-verification/
├── rtl/
│   ├── FIFO.sv              # Synchronous FIFO RTL implementation
│   ├── FIFO_if.sv           # Interface definition with modports
│   ├── FIFO_shared.sv       # Shared parameters / defines
│   └── shared_pkg.sv        # Package with shared type definitions
│
├── tb/
│   ├── FIFO_top.sv          # Top-level testbench instantiation
│   ├── FIFO_tb.sv           # Stimulus generator (constrained-random)
│   ├── FIFO_transaction.sv  # Transaction class (randomizable)
│   ├── FIFO_monitor.sv      # Monitor — samples DUT outputs
│   ├── FIFO_scoreboard.sv   # Self-checking scoreboard
│   └── FIFO_coverage.sv     # Functional coverage collector
│
├── sim/
│   └── run.do               # ModelSim/QuestaSim simulation script
│
├── docs/
│   ├── Project.pdf          # Project specification
│
└── README.md
```

---

## Design Parameters

| Parameter       | Default | Description                        |
|-----------------|---------|------------------------------------|
| `FIFO_WIDTH`    | 16      | Data bus width in bits             |
| `FIFO_DEPTH`    | 8       | Number of entries in the FIFO      |
| `max_fifo_addr` | 3       | Address width = `$clog2(FIFO_DEPTH)` |

---

## Verification Architecture

```
┌─────────────────────────────────────────────────────────┐
│                      FIFO_top                           │
│                                                         │
│   ┌──────────┐     ┌──────────┐     ┌───────────────┐  │
│   │ FIFO_tb  │────▶│ FIFO_if  │────▶│   FIFO (DUT)  │  │
│   │(stimulus)│     │(interface│     │  (RTL + SVA)  │  │
│   └──────────┘     │modports) │     └───────────────┘  │
│                    └─────┬────┘                         │
│                          │ MONITOR modport              │
│                    ┌─────▼──────────────────────┐       │
│                    │       FIFO_monitor          │       │
│                    └──────┬──────────┬───────────┘       │
│                           │          │                   │
│                  ┌────────▼──┐  ┌────▼──────────────┐   │
│                  │Scoreboard │  │ Coverage Collector │   │
│                  └───────────┘  └────────────────────┘   │
└─────────────────────────────────────────────────────────┘
```

---

## Getting Started

### Prerequisites

- **ModelSim** or **QuestaSim** (tested with ModelSim SE)
- Alternatively any SystemVerilog-compliant simulator (Xcelium, VCS, etc.)

### Clone the Repository

```bash
git clone https://github.com/Jasleenxddd/Synchronous-FIFO.git
cd Synchronous-FIFO
```

---

## Running the Simulation

Using the provided ModelSim script:

```bash
cd sim
vsim -do run.do
```

The script will:
1. Compile all `.sv` files with the `+define+SIM` flag (enables assertions)
2. Enable coverage collection (`+cover -covercells`)
3. Launch simulation and run all 10,000 transactions
4. Save coverage database to `FIFO_top.ucdb`

---

## Coverage

> **Total Covergroup Coverage: 100.00%** — All 162 bins covered across all coverpoints and crosses.

### Functional Coverage Results

Collected from `FIFO_coverage_pkg/FIFO_coverage/cg` over 10,000 randomized transactions.

| Coverpoint         | Covered Bins | Total Bins | Missing | Hit % | Status  |
|--------------------|:------------:|:----------:|:-------:|:-----:|---------|
| `cp_data_in`       | 64           | 64         | 0       | 100%  | ✅ Covered |
| `cp_wr_en`         | 2            | 2          | 0       | 100%  | ✅ Covered |
| `cp_rd_en`         | 2            | 2          | 0       | 100%  | ✅ Covered |
| `cp_rst`           | 2            | 2          | 0       | 100%  | ✅ Covered |
| `cp_full`          | 2            | 2          | 0       | 100%  | ✅ Covered |
| `cp_empty`         | 2            | 2          | 0       | 100%  | ✅ Covered |
| `cp_almostfull`    | 2            | 2          | 0       | 100%  | ✅ Covered |
| `cp_almostempty`   | 2            | 2          | 0       | 100%  | ✅ Covered |
| `cp_wr_ack`        | 2            | 2          | 0       | 100%  | ✅ Covered |
| `cp_overflow`      | 2            | 2          | 0       | 100%  | ✅ Covered |
| `cp_underflow`     | 2            | 2          | 0       | 100%  | ✅ Covered |

#### Bin-level Hit Counts

| Coverpoint       | bin auto[0] hits | bin auto[1] hits |
|------------------|:----------------:|:----------------:|
| `cp_wr_en`       | 5912             | 4090             |
| `cp_rd_en`       | 6972             | 3030             |
| `cp_rst`         | 287              | 9705             |
| `cp_full`        | 9092             | 910              |
| `cp_empty`       | 8670             | 1332             |
| `cp_almostfull`  | 8849             | 1153             |
| `cp_almostempty` | 8474             | 1528             |
| `cp_wr_ack`      | 6396             | 3606             |
| `cp_overflow`    | 9747             | 255              |
| `cp_underflow`   | 9753             | 249              |

---

### Cross Coverage Results

All cross-coverage scenarios between simultaneous read/write and status flags achieved **100% coverage**.

| Cross          | Bins | Covered | Missing | Hit % | Status     |
|----------------|:----:|:-------:|:-------:|:-----:|------------|
| `cross1` (wr_en × wr_ack)        | 2 | 2 | 0 | 100% | ✅ Covered |
| `cross2` (wr_en × full)          | 2 | 2 | 0 | 100% | ✅ Covered |
| `cross3` (wr_en × empty)         | 2 | 2 | 0 | 100% | ✅ Covered |
| `cross4` (wr_en × almostfull)    | 2 | 2 | 0 | 100% | ✅ Covered |
| `cross5` (wr_en × almostempty)   | 2 | 2 | 0 | 100% | ✅ Covered |
| `cross6` (wr_en × overflow)      | 2 | 2 | 0 | 100% | ✅ Covered |
| `cross7` (wr_en × underflow)     | 2 | 2 | 0 | 100% | ✅ Covered |

#### Cross Bin Hit Counts

| Cross Bin                      | Hits |
|--------------------------------|:----:|
| `wr1_rd0_ack1` / `wr0_rd1_ack0`         | 2524 / 1789 |
| `wr1_rd0_full` / `wr0_rd1_full`         | 2849 / 1789 |
| `wr1_rd0_empty` / `wr0_rd1_empty`       | 2849 / 1789 |
| `wr1_rd0_almostfull1` / `wr0_rd1_almostfull0` | 265 / 1622 |
| `wr1_rd0_almostempty0` / `wr0_rd1_almostempty1` | 2467 / 193 |
| `wr1_rd0_overflow1` / `wr0_rd1_overflow0`       | 255 / 1789 |
| `wr1_rd0_underflow0` / `wr0_rd1_underflow1`     | 2849 / 249 |

---

### SVA Directive Coverage

All 12 SVA cover properties were exercised. **Total Directive Coverage: 100.00%**

| SVA Cover Property                          | Hits   | Status     |
|---------------------------------------------|:------:|------------|
| `/FIFO_top/async_reset_coverage`            | 297    | ✅ Covered |
| `/FIFO_top/DUT/SVA_wr_ack_coverage`         | 3500   | ✅ Covered |
| `/FIFO_top/DUT/SVA_overflow_coverage`       | 245    | ✅ Covered |
| `/FIFO_top/DUT/SVA_underflow_coverage`      | 241    | ✅ Covered |
| `/FIFO_top/DUT/SVA_empty_coverage`          | 1286   | ✅ Covered |
| `/FIFO_top/DUT/SVA_full_coverage`           | 886    | ✅ Covered |
| `/FIFO_top/DUT/SVA_almostfull_coverage`     | 1116   | ✅ Covered |
| `/FIFO_top/DUT/SVA_almostempty_coverage`    | 1482   | ✅ Covered |
| `/FIFO_top/DUT/SVA_wr_ptr_coverage`         | 3500   | ✅ Covered |
| `/FIFO_top/DUT/SVA_rd_ptr_coverage`         | 2458   | ✅ Covered |
| `/FIFO_top/DUT/SVA_count_threshold_coverage`| 10002  | ✅ Covered |
| `/FIFO_top/DUT/SVA_ptr_threshold_coverage`  | 10002  | ✅ Covered |

---

### Code Coverage

Code coverage analysis was performed by ModelSim on `FIFO_top/DUT`. All reachable statements, branches, and toggle signals achieved **100% coverage**.

| Coverage Type | Result  |
|---------------|:-------:|
| Statement     | ✅ 100% |
| Branch        | ✅ 100% |
| Toggle (count, rd_ptr, wr_ptr) | ✅ 100% |

**Total Coverage By Instance (filtered view): 100.00%**

---

## Assertions (SVA)

The following concurrent SVA properties are active during simulation (`` `ifdef SIM ``):

| Assertion                    | Description                                      |
|------------------------------|--------------------------------------------------|
| `SVA_wr_ack_assertion`       | `wr_ack` asserts one cycle after a valid write   |
| `SVA_overflow_assertion`     | `overflow` asserts on write-when-full            |
| `SVA_underflow_assertion`    | `underflow` asserts on read-when-empty           |
| `SVA_empty_assertion`        | `empty` is high when `count == 0`                |
| `SVA_full_assertion`         | `full` is high when `count == FIFO_DEPTH`        |
| `SVA_almostfull_assertion`   | `almostfull` when `count == FIFO_DEPTH - 1`      |
| `SVA_almostempty_assertion`  | `almostempty` when `count == 1`                  |
| `SVA_wr_ptr_assertion`       | Write pointer increments correctly               |
| `SVA_rd_ptr_assertion`       | Read pointer increments correctly                |
| `SVA_count_threshold_assertion` | Count never exceeds `FIFO_DEPTH`             |
| `SVA_ptr_threshold_assertion`| Pointers stay within valid address range         |

---

## License

This project is for educational purposes. See individual source files for author attribution.


## Repository Maintenance

Maintained by [Jasleen Kaur (@Jasleenxddd)](https://github.com/Jasleenxddd).
This repository imports an existing educational FIFO verification project; maintaining this copy does not imply original authorship of all included materials. Existing source-file author notices are retained.

## Validation Status

The coverage figures above are inherited project results, not results reproduced for this repository. ModelSim/QuestaSim is required to rerun the simulation. The supplied testbench and scoreboard use the default 16-bit width and depth of 8; other parameter values require corresponding testbench changes. The RTL pointer increment assumes a power-of-two depth.
