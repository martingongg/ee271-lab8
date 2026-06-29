# EE 271 Lab 8 — Flappy Bird on FPGA

Course materials for **EE 271 Digital Design** at the University of Washington, including the Lab 8 final project proposal and related documentation for implementing **Flappy Bird** on the Altera DE1-SoC development board.

**Author:** Martin Gong  
**Academic Year:** 2025–26

## Project Overview

This project implements a hardware version of the mobile game *Flappy Bird* on an FPGA. The player controls a bird that must navigate through scrolling obstacles while gravity continuously pulls it downward. The design demonstrates core digital design concepts including finite state machines (FSMs), clock division, collision detection, pseudo-random barrier generation, and real-time display output.

The primary target platform is the **DE1-SoC board** (Cyclone V FPGA) with an **8×8 LED matrix** as the game display.

## User Interaction

| Input | Function |
|-------|----------|
| `KEY[0]` | Flap — moves the bird upward |
| `SW[9]` | Reset — restarts the game |
| `SW[1]` | Pause — freezes gameplay |
| `SW[0]` | High score mode — displays best score on HEX displays |

| Output | Function |
|--------|----------|
| 8×8 LED Matrix | Red LED for the bird; green LEDs for scrolling barriers |
| HEX0–HEX5 | Current score during play; high score when `SW[0]` is on |

## System Architecture

The design is organized into six major subsystems, all synchronized to the board's 50 MHz clock (`CLOCK_50`):

1. **Input Processing** — Clock divider, button debouncing, and timing counters for gravity, scrolling, and barrier generation rates
2. **Bird Control** — Vertical position FSMs with gravity simulation and out-of-bounds detection
3. **Barrier Generation** — Random gap patterns with left-scrolling column modules
4. **Collision Detection** — Bitwise comparison of bird and barrier positions
5. **Scoring** — Incremental 4-digit decimal counter (0–9999) with high-score storage
6. **Display & Pause** — LED matrix driver, pause overlay, and HEX display multiplexing

## Repository Contents

| File | Description |
|------|-------------|
| [`lab8.pdf`](lab8.pdf) | Full final project proposal with system block diagram and implementation details |
| [`Flappy_Bird_Project_Proposal.pdf`](Flappy_Bird_Project_Proposal.pdf) | Flappy Bird project proposal (PDF) |
| [`Flappy_Bird_Project_Proposal.docx`](Flappy_Bird_Project_Proposal.docx) | Flappy Bird project proposal (Word) |
| [`Lab 8 proposal.docx`](Lab%208%20proposal.docx) | Lab 8 proposal draft (includes VGA variant notes) |
| [`Final_Project_Proposal.pdf`](Final_Project_Proposal.pdf) | Final project proposal document |

## Key Design Concepts

- **Clock management** — Single clock domain with divided signals controlling game physics speed
- **2D array data structures** — `red_array[7:0][7:0]` for bird position; `green_array[7:0][7:0]` for barriers
- **FSM-based modules** — Individual LED and column controllers (`normalLight`, `centerLight`, `normalColumn`)
- **LFSR pseudo-randomness** — Random barrier gap heights on obstacle regeneration

## Course

**EE 271 — Digital Design**  
University of Washington, 2025–26