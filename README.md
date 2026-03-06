# FPGA-Top-of-Book-Engine
*Sub-50ns deterministic Top-of-Book arbitration engine implemented as a fully streaming FPGA pipeline.*

## Current Model timing characteristics:
8 cycles @ 220MHz = 45 ns latency. 

## Summary
A Top of Book engine is responsible for continuously tracking the best bids and best asks present in the market in real time. This design is a fully streaming pipeline, which takes N (assuming N to be a power of 2) quotes in parallel and outputs the best bid and best ask received. The result is the highest priced bid and lowest priced ask, while calculating spread and midpoint, and detecting crossed markets.
The processing pipeline consists of seven stages:
  - Input Buffering: Raw incoming quotes are registered and aligned to the pipeline clock.
  - Decoding: The order is split in: Valid, side, price, timestamp, size.
  - Filtering: Timestamps within each lane must be strictly increasing. Quotes with timestamps smaller than the last observed in that lane are invalidated to prevent stale updates and guarantee deterministic state evolution.
  - Canonicalization: To facilitate arbitration, a canonical (_c) data type is introduced. Asks have both price and timestamp inverted, while Bids have only the timestamp inverted. This transforms the comparison domain so that a single lexicographic comparison can deterministically select the best quote, independent of side.
  - Scoring: The _c quotes are assembled into a score vector of (Valid, Price, Timestamp, LaneID). This enables deterministic arbitration preferring the largest score. LaneID acts as a final deterministic tiebreaker. This stage holds state and is updated only when a new valid quote arrives.
  - Arbitration: The scored quotes are arbitrated using a pipelined O(log2(N)) tournament tree consisting of three comparison levels.
  - Signal Generation: The best bid and best ask are used to compute spread and midpoint, while also enabling crossed market detection (Bid > Ask).
The design is fully streaming and accepts new quotes every clock cycle after pipeline fill.
---

## Critical path analysis (TOB_Engine_V0)
The first version provided a latency of 8 cycles at a maximum frequency (Fmax) of 85 MHz, corresponding to 94 ns. The design was synthesized targeting an Artix-7 device.

The timing report (timing_report_summary_100MHz (`TOB_Engine_V0 branch`) indicated that the critical path was the unpipelined arbiter tree, consisting of 33 logic levels (27 CARRY4, 5 LUTs and one 2-1 MUX), and a high fanout of 239. The accumulated combinational depth across the full reduction path limited achievable frequency.

### Optimization 
As the deep combinational path in the arbiter was the primary bottleneck, pipelining was introduced to reduce logic depth per stage. Registers were inserted between each level of the tournament tree.

This increased total latency from 8 to 10 cycles, but reduced the combinational depth per stage for 3 levels (1 CARRY4, 2 LUTs)

The optimized design achieves:
   - Fmax: 181.8 MHz (~113% improvement)
   - Latency: 10 cycles @ 181.8 MHz = 55 ns (41.5% improvement in absolute latency)

The design was then stress tested with a clock at 181.8MHz, and sufficiently met timing by 0.001ns, according to timing_report_summary_181.8MHz(stress_test) in `main`.

## Critical path analysis (TOB_Engine_V1)

This version provided a latency of 10 cycles at a maximum frequency (Fmax) of 181.8 MHz, corresponding to 55 ns. The design was synthesized targeting an Artix-7 device.

The timing report (`TOB_Engine_V1 branch`) indicated that the critical path was the path from the arbiter output `price` to the `spread` register. This design performed `in_ASK.price >= in_BID.price` for the `crossed market` detection and `in_ASK.price - in_BID.price` for the `spread` computation. However, the FPGA implements `>=` as a subtraction, thus, it performed the same operation twice, increasing the latency.

### Optimization
Given this scenario, an external signed, 33 bit variable `comb_spread` was generated, and assigned as `comb_spread = $signed({0, in_ASK.price}) - $signed({0, in_BID.price})`. Then, in the `always_ff` block, this variable was passed into `reg_spread`, and its msb `comb_spread[PRICE_W]` was assigned into the `reg_cross` for detection of the crossed market. It flattened the 15 logic levels (13 CARRY4, 2 LUT's) into ().

Additionally, timing delay was further reduced. Instead of always propagating the quotes forward after the `CANONICALIZATION` stage, only the required `_c` canonical quotes were forwarded. Then, in the `SCORE` stage, only the score was forwarded. After arbitration, the winner quotes were reconstructed from the arbiter output. 

The optimized design achieves:
  - Fmax: 220.7 MHz (~21.4% improvement)
  - Latency: 10 cycles @ 220.7 MHz = 45 ns (18% improvement in absolute latency)


---

## Repository structure
Each branch represents a stage in the optimization process:
- main → Current optimized implementation (220 MHz)
- TOB_Engine_V1 → Pipelined arbiter implementation (181.8 MHz)
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
