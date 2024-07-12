
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

import Clocks::*;
import DefaultValue::*;
import XilinxCells::*;
import GetPut::*;

import ShaleUtil::*;

`include "ConnectalProjectConfig.bsv"

// NOTE: Set these according to pieo_datatypes.sv !!
// typedef 3 PHASE_LOG;
// typedef 3 TIMESLOT_LOG;
typedef 1 RANK_LOG;                 // bits to store flow rank
typedef 6 TIME_LOG;                 // bits to store flow send time: number of active buckets + 1
typedef 7 PIEO_NULL_ID;            // 2**ID_LOG - 1
// typedef 4 NUM_OF_SUBLIST;        // 2 * root( PIEO_LIST_SIZE)
// typedef 2 CLOG2_NUM_OF_SUBLIST;     // clog2(NUM_OF_SUBLIST)

// Struct enqueued and dequeued from PIEO.
// TODO: Is there any way to shorten this?
typedef struct
{
    Phase    prev_hop_phase;                // For FWD cells, hop this cell was recvd from.
    Coordinate prev_hop_slot;
    Bit#(RANK_LOG)  rank;                   // init with infinity
    Bit#(BUCKET_IDX_BITS)  id;
    Phase rem_spraying_hops_recvd;
    Bit#(1) is_spray;
} PIEOElement deriving(Bits, Eq);


interface PIEOQueue;

    method Action dequeue(Bit#(TIME_LOG) curr_time);
    method PIEOElement get_dequeue_result();
    method Action enqueue(PIEOElement f);

    method Action reset_queue();
endinterface

import "BVI" pieo =
module mkPIEOQueue#(Integer verbose) (PIEOQueue);

    parameter verbose = verbose;

    // define an input clock clk, with verilog port clk, and set this to be the default
    default_clock clk(clk);
    default_reset rst();

    port start = 1;
    
    method dequeue(curr_time_in) enable (dequeue_in) ready(pieo_ready_for_nxt_op_out);

    method deq_element_out get_dequeue_result() ready(deq_valid_out);

    method enqueue(f_in) enable(enqueue_f_in) ready(pieo_ready_for_nxt_op_out);

    method reset_queue() enable(rst);

    schedule (reset_queue) SB (dequeue, enqueue, get_dequeue_result) ;
    
    schedule reset_queue C reset_queue;
                      
    schedule (dequeue, enqueue) C (dequeue, enqueue);

    schedule (get_dequeue_result) SB (dequeue, enqueue);

    // This method is simply a read - no conflict!
    schedule get_dequeue_result CF get_dequeue_result;
    
endmodule