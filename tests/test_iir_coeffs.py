"""Offline checks of the float IIR constants in filter_float_IIR_buttorworth.v."""
import sys
from pathlib import Path

import pytest

sys.path.insert(0, str(Path(__file__).resolve().parents[1] / "tools"))
import iir_coeffs as ic  # noqa: E402


def test_bit_pattern_roundtrip():
    for v in (0.0036210001, 1.823, -0.5, 1.0):
        assert ic.bits_f32(ic.f32_bits(v)) == pytest.approx(v, rel=1e-7)


def test_fresh_design_has_unity_dc_gain_in_float32():
    c = {k: ic.bits_f32(ic.f32_bits(v)) for k, v in ic.design(1000, 50000).items()}
    assert ic.dc_gain(c) == pytest.approx(1.0, abs=1e-4)


def test_rtl_constants_are_a_second_order_butterworth_near_wn_0p04():
    c = ic.read_rtl()
    assert ic.fit_wn(c) == pytest.approx(0.04, abs=1e-3)


def test_rtl_constants_known_dc_gain_error():
    """Known issue KI-2: 4-significant-digit rounding gives about +2.7 % DC gain."""
    g = ic.dc_gain(ic.read_rtl())
    assert 1.02 < g < 1.035
