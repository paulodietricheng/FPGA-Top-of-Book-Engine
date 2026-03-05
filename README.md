# FPGA-Top-of-Book-Engine
*Sub 100ns deterministic Top of Book arbitration engine.*

## Summary
A Top of Book engine is responsible for continuously tracking the best bids and best asks present in the market in real time. This design is a fully streaming pipeline, which takes N (assuming N to be a power of 2) quotes in parallel and outputs the best bid and best ask received. The result is the highest priced bid and lowest priced ask, while calculating spread and midpoint, and detecting crossed markets.
The processing pipeline consists of seven stages:
  - Input Buffering: The order is split into: Valid, side, price, timestamp, and size.
  - Decoding: The order is split in: Valid, side, price, timestamp, size.
  - Filtering: Timestamps within each lane must be strictly increasing. Quotes with timestamps smaller than the last observed in that lane are invalidated to prevent stale updates and guarantee deterministic state evolution.
  - Canonicalization: To facilitate arbitration, a canonical (_c) data type is introduced. Asks have both price and timestamp inverted, while Bids have only the timestamp inverted. This transforms the comparison domain so that a single lexicographic comparison can deterministically select the best quote, independent of side.
  - Scoring: The _c quotes are assembled into a score vector of (Valid, Price, Timestamp, LaneID). This enables deterministic arbitration preferring the largest score. LaneID acts as a final deterministic tiebreaker. This stage holds state and is updated only when a new valid quote arrives.
  - Arbitration: The scored quotes are arbitrated using an O(log2(N)) tournament tree with three levels of comparisons.
  - Signal Generation: The best bid and best ask are used to compute spread and midpoint, while also enabling crossed market detection (Bid > Ask).

---

## Critical path analysis (TOB_Engine_V0)
The first version provided a latency of 8 cycles at a maximum frequency (Fmax) of 85 MHz, corresponding to 94 ns. The design was synthesized targeting an Artix-7 device.

The critical path was the unpipelined arbiter tree, consisting of 33 logic levels (27 CARRY4, 5 LUTs and one 2-1 MUX), and a high fanout of 239. The accumulated combinational depth across the full reduction path limited achievable frequency.

### Optimization 
As the deep combinational path in the arbiter was the primary bottleneck, pipelining was introduced to reduce logic depth per stage. Registers were inserted between each level of the tournament tree.

This increased total latency from 8 to 10 cycles, but reduced the combinational depth per stage for 15 levels (13 CARRY4, 2 LUTs), and a high fanout of 64.

The optimized design achieves:
   - Fmax: 182 MHz (114% improvement)
   - Latency: 10 cycles @ 182 MHz = 54 ns (42.5% reduction in absolute latency)

---

## Repository structure
Each branch in this repository represents a version of the design:
  - main → Pipelined arbiter implementation (182 MHz)
  - TOB_Engine_V0 → Unpipelined baseline (85 MHz)

Folders:
   - reports/ → Important performance reports
   - rtl/ → RTL source files
   - sim/ → Testbench and simulation files
---

## Build & Simulation
- Target device: Xilinx Artix-7
- Toolchain: Vivado 2025.2
- Language: SystemVerilog
## Future directions
This design targets a maximum frequency of 250 MHz. Further improvements will focus on:
- Balanced comparator tree restructuring
- Fanout reduction and potential register duplication
- Physical-aware optimizations and floorplanning exploration
