#!/bin/bash
# Compile and run every self-checking testbench with Icarus Verilog.
# A testbench passes when it prints a line starting with "PASS" and no line
# starting with "FAIL". On GitHub Actions each failure is also emitted as an
# ::error:: annotation so it is readable from the public check-run API.
set -u
cd "$(dirname "$0")/.."
TBS=(tb_pwm_out tb_quadrature_encoder tb_filter_basic bldc_commutation_tb)
declare -A DUT=(
  [tb_pwm_out]="pwm_out.v"
  [tb_quadrature_encoder]="quadrature_encoder_interface.v"
  [tb_filter_basic]="filter_basic_fixed.v"
  [bldc_commutation_tb]="bldc_commutation.v"
)
mkdir -p build
FAILED=0

annotate() {  # $1 = testbench, $2 = message (multi-line allowed)
  [ -n "${GITHUB_ACTIONS:-}" ] || return 0
  local msg="${2//'%'/'%25'}"
  msg="${msg//$'\r'/'%0D'}"
  msg="${msg//$'\n'/'%0A'}"
  echo "::error title=$1::$msg"
}

for tb in "${TBS[@]}"; do
  src="tests/$tb.v"; [ -f "$src" ] || src="$tb.v"
  if ! iverilog -g2005 -Wall -o "build/$tb.vvp" "$src" "${DUT[$tb]}" 2> "build/$tb.compile.log"; then
    echo "FAIL $tb (compile)"; cat "build/$tb.compile.log"
    annotate "$tb" "compile failed: $(tail -n 20 "build/$tb.compile.log")"
    FAILED=$((FAILED + 1)); continue
  fi
  out=$(timeout 120 vvp -n "build/$tb.vvp" 2>&1); rc=$?
  echo "$out" | grep -E "^(PASS|FAIL)" || true
  if [ $rc -ne 0 ] || ! echo "$out" | grep -q "^PASS" || echo "$out" | grep -q "^FAIL"; then
    echo "FAIL $tb (vvp rc=$rc)"
    annotate "$tb" "vvp rc=$rc: $(echo "$out" | tail -n 20)"
    FAILED=$((FAILED + 1))
  fi
done
echo "testbenches failed: $FAILED"
[ "$FAILED" -eq 0 ]
