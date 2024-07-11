
// Copyright (c) 2014 Cornell University.

// Permission is hereby granted, free of charge, to any person
// obtaining a copy of this software and associated documentation
// files (the "Software"), to deal in the Software without
// restriction, including without limitation the rights to use, copy,
// modify, merge, publish, distribute, sublicense, and/or sell copies
// of the Software, and to permit persons to whom the Software is
// furnished to do so, subject to the following conditions:

// The above copyright notice and this permission notice shall be
// included in all copies or substantial portions of the Software.

// THE SOFTWARE IS PROVIDED "AS IS", WITHOUT WARRANTY OF ANY KIND,
// EXPRESS OR IMPLIED, INCLUDING BUT NOT LIMITED TO THE WARRANTIES OF
// MERCHANTABILITY, FITNESS FOR A PARTICULAR PURPOSE AND
// NONINFRINGEMENT. IN NO EVENT SHALL THE AUTHORS OR COPYRIGHT HOLDERS
// BE LIABLE FOR ANY CLAIM, DAMAGES OR OTHER LIABILITY, WHETHER IN AN
// ACTION OF CONTRACT, TORT OR OTHERWISE, ARISING FROM, OUT OF OR IN
// CONNECTION WITH THE SOFTWARE OR THE USE OR OTHER DEALINGS IN THE
// SOFTWARE.

package AlteraExtra;

import Clocks ::*;

(* always_ready, always_enabled *)
interface AltClkCtrl;
    interface Clock     outclk;
endinterface
import "BVI" altera_clkctrl =
module mkAltClkCtrl#(Clock inclk)(AltClkCtrl);
    default_clock no_clock;
    no_reset;
    input_clock inclk(inclk) = inclk;
    output_clock outclk(outclk);
endmodule

(* always_ready, always_enabled *)
interface PLL644;
    interface Clock       outclk_0;
endinterface
import "BVI" pll_644 =
module mkPLL644#(Clock refclk, Reset rst)(PLL644);
    default_clock no_clock;
    no_reset;
    input_clock refclk(refclk) = refclk;
    input_reset rst(rst) clocked_by (refclk) = rst;
    output_clock outclk_0(outclk_0);
endmodule

(* always_ready, always_enabled *)
interface PLL156;
    interface Clock       outclk_0;
endinterface
import "BVI" pll_156 =
module mkPLL156#(Clock refclk, Reset rst)(PLL156);
    default_clock no_clock;
    no_reset;
    input_clock refclk(refclk) = refclk;
    input_reset rst(rst) clocked_by (refclk) = rst;
    output_clock outclk_0(outclk_0);
endmodule


endpackage: AlteraExtra
