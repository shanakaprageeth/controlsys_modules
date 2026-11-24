# Known issues (audit 2026-11-25)

Found during the monorepo engineering audit (`shanaka-monolithic1/docs/EVALUATION.md`).
The RTL behaviour is unchanged. Each issue is pinned by a test, so a fix must update the test.

| ID | Module | Issue | Evidence |
|---|---|---|---|
| KI-1 | `filter_basic_fixed.v` | With GAIN_1 = 1 and GAIN_2 = 16 the update is `y <- y + (x + y_prev)/16`. This is an accumulator, not a low-pass filter. A constant input makes the output grow without bound (x = 160 gives about 1.97e7 after 400 clk in a cycle-accurate Python model). `filter_output` is unsigned while the state is signed. | `tests/tb_filter_basic.v` |
| KI-2 | `filter_float_IIR_buttorworth.v` | The constants are a 2nd-order Butterworth with fc = 0.020 x f_update, rounded to 4 significant digits. This gives a DC gain of 1.0273 (+2.7 %). The poles are at radius 0.915, which makes the response sensitive to coefficient rounding. Full float32 constants come from `tools/iir_coeffs.py --fc <fc> --fs <f_update>`. | `tests/test_iir_coeffs.py` |
| KI-3 | `filter_float_IIR_buttorworth.v` | The state updates every 10001 clocks, so f_update = f_clk / 10001. The old header claimed a 1 MHz sample rate and a 1 kHz cutoff. The header is now corrected. | header comment |
| KI-4 | `filter_float_IIR_buttorworth.v` | It needs Altera `float_multi` and `float_add_sub` IP cores, so it cannot be simulated with Icarus. Behavioural models of these cores would be needed for a testbench. | n/a |
| KI-5 | `quadrature_encoder_interface.v` | The header says "not tested". x4 decoding is now covered by `tests/tb_quadrature_encoder.v`. | test |
