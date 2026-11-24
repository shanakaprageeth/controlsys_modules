#!/bin/bash
# Compile and run every self-checking testbench with Icarus Verilog.
# A testbench passes when it prints a line starting with "PASS".
set -u
cd "$(dirname "$0")/.."
declare -A DUT=(
  [tb_pwm_out]="pwm_out.v"
  [tb_quadrature_encoder]="quadrature_encoder_interface.v"
  [tb_filter_basic]="filter_basic_fixed.v"
  [bldc_commutation_tb]="bldc_commutation.v"
)
mkdir -p build
FAILED=0
for tb in "${!DUT[@]}"; do
  src="tests/$tb.v"; [ -f "$src" ] || src="$tb.v"
  if ! iverilog -g2005 -Wall -o "build/$tb.vvp" "$src" ${DUT[$tb]} 2> "build/$tb.compile.log"; then
    echo "FAIL $tb (compile)"; cat "build/$tb.compile.log"; FAILED=$((FAILED + 1)); continue
  fi
  out=$(vvp -n "build/$tb.vvp")
  echo "$out" | grep -E "^(PASS|FAIL)" || true
  if ! echo "$out" | grep -q "^PASS" || echo "$out" | grep -q "^FAIL\|failed"; then
    FAILED=$((FAILED + 1))
  fi
done
echo "testbenches failed: $FAILED"
[ "$FAILED" -eq 0 ]
