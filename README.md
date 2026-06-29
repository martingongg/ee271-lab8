# EE 271 Lab 8 — Flappy Bird on FPGA

Course materials and SystemVerilog implementation for **EE 271 Digital Design** at the University of Washington. This repository contains the final project proposal documents and the complete Quartus project for implementing **Flappy Bird** on the Altera DE1-SoC development board.

**Author:** Martin Gong  
**Academic Year:** 2025–26

## Project Overview

This project implements a hardware version of the mobile game *Flappy Bird* on an FPGA. The player controls a bird (green LED) that must navigate through scrolling pipe obstacles (red LEDs) on a 16×16 LED matrix while gravity continuously pulls it downward. The design demonstrates finite state machines (FSMs), clock division, collision detection, pseudo-random pipe generation, and real-time display output.

**Target platform:** DE1-SoC board (Cyclone V FPGA) with GPIO-connected LED matrix display.

## Controls

| Input | Function |
|-------|----------|
| `KEY[0]` | Flap — moves the bird upward |
| `KEY[3]` | Reset — restarts the game |

| Output | Function |
|--------|----------|
| GPIO LED Matrix | Green LEDs for the bird; red LEDs for scrolling pipes |
| HEX0 | Displays "L" on game over |
| HEX3–HEX5 | Score display (ones, tens, hundreds) |

## Source Code

All SystemVerilog source and Quartus project files are in [`src/`](src/).

### Top-Level Module

[`src/DE1_SoC.sv`](src/DE1_SoC.sv) — Top-level design and integrated testbench (`DE1_SoC_testbench`).

### Module Hierarchy

| Module | Description |
|--------|-------------|
| `clock_divider` | Divides 50 MHz clock for game timing |
| `metaFilter` | Debounces push-button inputs |
| `birdLight` | Bird vertical position FSM with gravity |
| `slowDown` | Programmable clock divider for pipe timing |
| `newPipe` | Generates random pipe gap patterns offscreen |
| `pipeColumn` | Shifts pipe columns across the display |
| `collisionCheck` | Detects bird–pipe collisions and score events |
| `pointDisplay` / `pointCounter` | 3-digit decimal score on HEX displays |
| `seg7` | 7-segment decoder for game-over indicator |
| `LEDDriver` | Multiplexes pixel arrays to GPIO LED matrix |
| `normalLight`, `centerLight`, `topLight`, `bottomLight` | Per-row bird position FSMs |
| `playfield`, `victoryDisplay` | Display helpers |

## Building & Simulation

### Quartus (synthesis & FPGA programming)

1. Open [`src/DE1_SoC.qpf`](src/DE1_SoC.qpf) in Intel Quartus Prime.
2. Compile the project (Processing → Start Compilation).
3. Program the DE1-SoC via [`src/ProgramTheDE1_SoC.cdf`](src/ProgramTheDE1_SoC.cdf).

### ModelSim (RTL simulation)

From the `src/` directory:

```bash
vsim -do runlab.do
```

This compiles all modules, runs `DE1_SoC_testbench`, and opens the waveform viewer via `DE1_SoC_wave.do`.

## Repository Contents

### Documentation

| File | Description |
|------|-------------|
| [`lab8.pdf`](lab8.pdf) | Full final project proposal with system block diagram |
| [`Flappy_Bird_Project_Proposal.pdf`](Flappy_Bird_Project_Proposal.pdf) | Flappy Bird project proposal (PDF) |
| [`Flappy_Bird_Project_Proposal.docx`](Flappy_Bird_Project_Proposal.docx) | Flappy Bird project proposal (Word) |
| [`Lab 8 proposal.docx`](Lab%208%20proposal.docx) | Lab 8 proposal draft |
| [`Final_Project_Proposal.pdf`](Final_Project_Proposal.pdf) | Final project proposal document |

### Source (`src/`)

20 SystemVerilog modules, Quartus project files (`.qpf`, `.qsf`, `.sdc`), ModelSim scripts, and programming configuration.

## Key Design Concepts

- **Clock management** — 50 MHz `CLOCK_50` divided to ~1.5 kHz system clock (`clk[14]`)
- **2D pixel arrays** — `RedPixels[15:0][15:0]` for pipes; `GrnPixels[15:0][15:0]` for bird
- **Generate loop** — 15 `pipeColumn` instances chained for horizontal scrolling
- **FSM-based modules** — Individual LED row controllers for bird physics
- **Integrated testbench** — Automated tests for reset, jumping, pipe mechanics, scoring, and collision

## Course

**EE 271 — Digital Design**  
University of Washington, 2025–26