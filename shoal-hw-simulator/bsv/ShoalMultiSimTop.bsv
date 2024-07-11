// MIT License

// Copyright (c) 2024 Cornell University

// Permission is hereby granted, free of charge, to any person obtaining a copy
// of this software and associated documentation files (the "Software"), to deal
// in the Software without restriction, including without limitation the rights
// to use, copy, modify, merge, publish, distribute, sublicense, and/or sell
// copies of the Software, and to permit persons to whom the Software is
// furnished to do so, subject to the following conditions:

// The above copyright notice and this permission notice shall be included in all
// copies or substantial portions of the Software.

// THE SOFTWARE IS PROVIDED "AS IS", WITHOUT WARRANTY OF ANY KIND, EXPRESS OR
// IMPLIED, INCLUDING BUT NOT LIMITED TO THE WARRANTIES OF MERCHANTABILITY,
// FITNESS FOR A PARTICULAR PURPOSE AND NONINFRINGEMENT. IN NO EVENT SHALL THE
// AUTHORS OR COPYRIGHT HOLDERS BE LIABLE FOR ANY CLAIM, DAMAGES OR OTHER
// LIABILITY, WHETHER IN AN ACTION OF CONTRACT, TORT OR OTHERWISE, ARISING FROM,
// OUT OF OR IN CONNECTION WITH THE SOFTWARE OR THE USE OR OTHER DEALINGS IN THE
// SOFTWARE.

import FIFO::*;
import FIFOF::*;
import Pipe::*;
import Vector::*;
import GetPut::*;
import Connectable::*;
import DefaultValue::*;
import Clocks::*;

`include "ConnectalProjectConfig.bsv"

import ShaleUtil::*;
`ifndef CW_PHY_SIM
import MacSwitch::*;
`else
import PhySwitch::*;
`endif
import CellGenerator::*;
import Mac::*;
import Scheduler::*;
import RingBufferTypes::*;
import RingBuffer::*;

import AlteraMacWrap::*;
import EthMac::*;

interface ShoalMultiSimTopIndication;
    method Action display_tx_port_0_stats
        (Bit#(64) sop, Bit#(64) eop, Bit#(64) blocks, Bit#(64) cells);
    method Action display_tx_port_1_stats
        (Bit#(64) sop, Bit#(64) eop, Bit#(64) blocks, Bit#(64) cells);
    method Action display_tx_port_2_stats
        (Bit#(64) sop, Bit#(64) eop, Bit#(64) blocks, Bit#(64) cells);
    method Action display_tx_port_3_stats
        (Bit#(64) sop, Bit#(64) eop, Bit#(64) blocks, Bit#(64) cells);
    method Action display_rx_port_0_stats
        (Bit#(64) sop, Bit#(64) eop, Bit#(64) blocks, Bit#(64) cells);
    method Action display_rx_port_1_stats
        (Bit#(64) sop, Bit#(64) eop, Bit#(64) blocks, Bit#(64) cells);
    method Action display_rx_port_2_stats
        (Bit#(64) sop, Bit#(64) eop, Bit#(64) blocks, Bit#(64) cells);
    method Action display_rx_port_3_stats
        (Bit#(64) sop, Bit#(64) eop, Bit#(64) blocks, Bit#(64) cells);
    
    `ifdef CW_PHY_SIM
    method Action display_latency_port_0_stats(Bit#(64) t);
    method Action display_latency_port_1_stats(Bit#(64) t);
    method Action display_latency_port_2_stats(Bit#(64) t);
    method Action display_latency_port_3_stats(Bit#(64) t);
    `endif

	method Action display_received_wrong_dst_pkt_count(Bit#(16) idx, Bit#(64) count);
    method Action display_latency(Bit#(16) idx, Bit#(64) count);
    method Action display_buffer_length(Bit#(16) idx, Bit#(64) count);
	method Action display_time_slots_count(Bit#(16) idx, Bit#(64) count);
	method Action display_received_host_pkt_count(Bit#(16) idx, Bit#(64) count);

	method Action display_sent_host_pkt_count_p0(Bit#(64) count);
	method Action display_sent_fwd_pkt_count_p0(Bit#(64) count);
	method Action display_received_fwd_pkt_count_p0(Bit#(64) count);
	method Action display_received_corrupted_pkt_count_p0(Bit#(64) count);
    method Action display_num_of_blocks_transmitted_from_mac_p0(Bit#(64) count);
    method Action display_num_of_blocks_received_by_mac_p0(Bit#(64) count);

	method Action display_sent_host_pkt_count_p1(Bit#(64) count);
	method Action display_sent_fwd_pkt_count_p1(Bit#(64) count);
	method Action display_received_fwd_pkt_count_p1(Bit#(64) count);
	method Action display_received_corrupted_pkt_count_p1(Bit#(64) count);
    method Action display_num_of_blocks_transmitted_from_mac_p1(Bit#(64) count);
    method Action display_num_of_blocks_received_by_mac_p1(Bit#(64) count);

	method Action display_sent_host_pkt_count_p2(Bit#(64) count);
	method Action display_sent_fwd_pkt_count_p2(Bit#(64) count);
	method Action display_received_fwd_pkt_count_p2(Bit#(64) count);
	method Action display_received_corrupted_pkt_count_p2(Bit#(64) count);
    method Action display_num_of_blocks_transmitted_from_mac_p2(Bit#(64) count);
    method Action display_num_of_blocks_received_by_mac_p2(Bit#(64) count);

	method Action display_sent_host_pkt_count_p3(Bit#(64) count);
	method Action display_sent_fwd_pkt_count_p3(Bit#(64) count);
	method Action display_received_fwd_pkt_count_p3(Bit#(64) count);
	method Action display_received_corrupted_pkt_count_p3(Bit#(64) count);
    method Action display_num_of_blocks_transmitted_from_mac_p3(Bit#(64) count);
    method Action display_num_of_blocks_received_by_mac_p3(Bit#(64) count);
endinterface

interface ShoalMultiSimTopRequest;
    method Action startSwitching(Bit#(8) reconfig_flag, Bit#(64) timeslot);
	method Action printSwStats();
    method Action start_shoal(Bit#(32) idx, //host server index
		                    Bit#(16) rate,  //rate of cell generation
                            Bit#(8) timeslot, //timeslot length
		                    Bit#(64) cycles); //num of cycles to run exp for
endinterface

interface ShoalMultiSimTop;
    interface ShoalMultiSimTopRequest request;
endinterface

module mkShoalMultiSimTop#(ShoalMultiSimTopIndication indication)
        (ShoalMultiSimTop);

    // Clocks
    Clock defaultClock <- exposeCurrentClock();
    Reset defaultReset <- exposeCurrentReset();

    Clock txClock <- mkAbsoluteClock(0, 64);
    Reset txReset <- mkAsyncReset(2, defaultReset, txClock);

    Clock rxClock <- mkAbsoluteClock(0, 64);
    Reset rxReset <- mkAsyncReset(2, defaultReset, rxClock);

/*-------------------------------------------------------------------------------*/

    /* Reset signals and module initialization */

    // MakeResetIfc tx_reset_ifc <- mkResetSync(0, False, defaultClock);
    // Reset tx_rst_sig <- mkAsyncReset(0, tx_reset_ifc.new_rst, txClock);
    // Reset txReset <- mkResetEither(txReset, tx_rst_sig, clocked_by txClock);

    // MakeResetIfc rx_reset_ifc <- mkResetSync(0, False, defaultClock);
    // Reset rx_rst_sig <- mkAsyncReset(0, rx_reset_ifc.new_rst, rxClock);
    // Reset rxReset <- mkResetEither(rxReset, rx_rst_sig, clocked_by rxClock);

`ifndef CW_PHY_SIM
    MacSwitch sw <- mkMacSwitch(txClock, txReset, txReset, rxClock, rxReset, rxReset);
`else
    PhySwitch sw <- mkPhySwitch(txClock, txReset, txReset, rxClock, rxReset, rxReset);
`endif

    Mac mac <- mkMac(0, txClock, txReset, txReset, rxClock, rxReset, rxReset);

    Vector#(NUM_OF_ALTERA_PORTS, CellGenerator)
        cg <- replicateM(mkCellGenerator(valueOf(CELL_SIZE)),
            clocked_by txClock, reset_by txReset);

    Scheduler scheduler <- mkScheduler(mac, cg, defaultClock, defaultReset,
            clocked_by txClock, reset_by txReset);

/*-------------------------------------------------------------------------------*/

    /* send request for stats */

	Reg#(Bit#(1)) get_time_slots_flag
	    <- mkReg(0, clocked_by txClock, reset_by txReset);
	// Reg#(Bit#(1)) get_sent_host_pkt_flag
	//     <- mkReg(0, clocked_by txClock, reset_by txReset);
	// Reg#(Bit#(1)) get_sent_fwd_pkt_flag
	//     <- mkReg(0, clocked_by txClock, reset_by txReset);
	Reg#(Bit#(1)) get_received_host_pkt_flag
	    <- mkReg(0, clocked_by txClock, reset_by txReset);
	// Reg#(Bit#(1)) get_received_fwd_pkt_flag
	//     <- mkReg(0, clocked_by txClock, reset_by txReset);
	// Reg#(Bit#(1)) get_received_corrupted_pkt_flag
	//     <- mkReg(0, clocked_by txClock, reset_by txReset);
	// Reg#(Bit#(1)) get_received_wrong_dst_pkt_flag
	//     <- mkReg(0, clocked_by txClock, reset_by txReset);
	Reg#(Bit#(1)) get_latency_flag
	    <- mkReg(0, clocked_by txClock, reset_by txReset);
    Reg#(Bit#(1)) get_buffer_lengths_flag
	    <- mkReg(0, clocked_by txClock, reset_by txReset);

	// Reg#(Bit#(1))
    //     get_num_of_blocks_trans_from_mac_flag
	//         <- mkReg(0, clocked_by txClock, reset_by txReset);
	// SyncFIFOIfc#(Bit#(1))
    //     get_num_of_blocks_recvd_by_mac_flag
	//         <- mkSyncFIFO(1, txClock, txReset, rxClock);

    // TODO: Why can't we send all stat requests together in one rule?
    rule get_time_slot_stats (get_time_slots_flag == 1);
        scheduler.timeSlotsCount();
        get_time_slots_flag <= 0;
        get_received_host_pkt_flag <= 1;
    endrule

    // rule get_sent_host_pkt_stats (get_sent_host_pkt_flag == 1);
    //     scheduler.sentHostPktCount();
    //     get_sent_host_pkt_flag <= 0;
    //     get_sent_fwd_pkt_flag <= 1;
    // endrule

    // rule get_sent_fwd_pkt_stats (get_sent_fwd_pkt_flag == 1);
    //     scheduler.sentFwdPktCount();
    //     get_sent_fwd_pkt_flag <= 0;
    //     get_received_host_pkt_flag <= 1;
    // endrule

    rule get_received_host_pkt_stats (get_received_host_pkt_flag == 1);
        scheduler.receivedHostPktCount();
        get_received_host_pkt_flag <= 0;
        get_latency_flag <= 1;
    endrule

    // rule get_received_fwd_pkt_stats (get_received_fwd_pkt_flag == 1);
    //     scheduler.receivedFwdPktCount();
    //     get_received_fwd_pkt_flag <= 0;
    //     get_received_corrupted_pkt_flag <= 1;
    // endrule

    // rule get_received_corrupted_pkt_stats
    //         (get_received_corrupted_pkt_flag == 1);
    //     scheduler.receivedCorruptedPktCount();
    //     get_received_corrupted_pkt_flag <= 0;
    //     get_received_wrong_dst_pkt_flag <= 1;
    // endrule

    // rule get_received_wrong_dst_pkt_stats
    //         (get_received_wrong_dst_pkt_flag == 1);
    //     scheduler.receivedWrongDstPktCount();
    //     get_received_wrong_dst_pkt_flag <= 0;
    //     get_latency_flag <= 1;
    // endrule

    rule get_latency_stats (get_latency_flag == 1);
        scheduler.latency();
        get_latency_flag <= 0;
        get_buffer_lengths_flag <= 1;
    endrule

    rule get_buffer_length_stats (get_buffer_lengths_flag == 1);
        scheduler.max_fwd_buffer_length();
        get_buffer_lengths_flag <= 0;
        // get_num_of_blocks_trans_from_mac_flag <= 1;
    endrule

    // rule get_num_of_blocks_trans_from_mac_stats
    //         (get_num_of_blocks_trans_from_mac_flag == 1);
    //     mac.getBlocksTransmittedFromMac();
    //     get_num_of_blocks_trans_from_mac_flag <= 0;
    //     get_num_of_blocks_recvd_by_mac_flag.enq(1);
    // endrule

    // rule get_num_of_blocks_recvd_by_mac_stats;
    //     let d <- toGet(get_num_of_blocks_recvd_by_mac_flag).get;
    //     mac.getBlocksReceivedByMac();
    // endrule

/*-------------------------------------------------------------------------------*/

    /* Configure when to stop the Cell generator and collect stats */

	SyncFIFOIfc#(Bit#(64)) num_of_cycles_to_run_fifo
	    <- mkSyncFIFO(1, defaultClock, defaultReset, txClock);
    Reg#(Bit#(64)) num_of_cycles_to_run
        <- mkReg(0, clocked_by txClock, reset_by txReset);

	rule deq_num_of_cycles_to_run;
		let x <- toGet(num_of_cycles_to_run_fifo).get;
		num_of_cycles_to_run <= x;
	endrule

    Reg#(Bit#(1)) start_counting <- mkReg(0, clocked_by txClock, reset_by txReset);
    Reg#(Bit#(64)) counter <- mkReg(0, clocked_by txClock, reset_by txReset);

`ifdef WAIT_FOR_START_SIG
    /* This rule is to configure when to stop the DMA and collect stats */
    rule start_counting_cycles;
        let d <- mac.start_counting[0].get;
        start_counting <= 1;
        $display("Starting counting, counter = %d", counter);
    endrule
`endif

    rule count_cycles (start_counting == 1);
        if (counter == num_of_cycles_to_run)
        begin
			/* reset state */
			counter <= 0;
			start_counting <= 0;
            for (Integer i = 0; i < valueof(NUM_OF_ALTERA_PORTS); i = i + 1)
            begin
                cg[i].stop();
            end
            scheduler.stop();
            get_time_slots_flag <= 1; //start collecting stats
        end
		else
			counter <= counter + 1;
    endrule

/*------------------------------------------------------------------------------*/

	/* Start Shoal NIC */

	SyncFIFOIfc#(Bit#(16))
        rate_fifo <- mkSyncFIFO(1, defaultClock, defaultReset, txClock);
	SyncFIFOIfc#(ServerIndex)
        host_index_fifo <- mkSyncFIFO(1, defaultClock, defaultReset, txClock);
	SyncFIFOIfc#(Bit#(8))
        timeslot_fifo <- mkSyncFIFO(1, defaultClock, defaultReset, txClock);

	Reg#(ServerIndex)
        host_index <- mkReg(0, clocked_by txClock, reset_by txReset);
	Reg#(Bit#(16))
        rate <- mkReg(0, clocked_by txClock, reset_by txReset);
	Reg#(Bit#(8))
        timeslot <- mkReg(0, clocked_by txClock, reset_by txReset);

	Reg#(Bit#(1))
        host_index_ready <- mkReg(0, clocked_by txClock, reset_by txReset);
	Reg#(Bit#(1))
        rate_ready <- mkReg(0, clocked_by txClock, reset_by txReset);
	Reg#(Bit#(1))
        timeslot_ready <- mkReg(0, clocked_by txClock, reset_by txReset);

	rule deq_from_host_index_fifo;
		let x <- toGet(host_index_fifo).get;
        host_index <= x;
        host_index_ready <= 1;
	endrule

	rule deq_from_rate_fifo;
		let x <- toGet(rate_fifo).get;
        rate <= x;
        rate_ready <= 1;
	endrule

    rule deq_from_timeslot_fifo;
        let x <- toGet(timeslot_fifo).get;
        timeslot <= x;
        timeslot_ready <= 1;
    endrule

    Reg#(Bit#(1)) wait_for_100_cycles <- mkReg(0, clocked_by txClock, reset_by txReset);
    Reg#(Bit#(64)) wait_counter <- mkReg(0, clocked_by txClock, reset_by txReset);

    rule start_shoal (host_index_ready == 1
                    && rate_ready == 1
                    && timeslot_ready == 1);
        // TODO: In Shoal, WHY ARE WE ONLY STARTING THE CELL GENERATOR FOR idx=0 ?
        if (rate != 0)
        begin
            for (Integer i = 0; i < valueof(NUM_OF_ALTERA_PORTS); i = i + 1)
            begin
                cg[i].start(fromInteger(i), rate);
            end
        end

        wait_for_100_cycles <= 1;
        /* reset the state */
        host_index_ready <= 0;
        rate_ready <= 0;
        timeslot_ready <= 0;
    endrule

    rule wait_for_100_cycles_rule (wait_for_100_cycles == 1);
        if (wait_counter == 100)
        begin
            wait_counter <= 0;
            wait_for_100_cycles <= 0;
        end
        else
            wait_counter <= wait_counter + 1;
    endrule

    rule start_scheduler (wait_counter == 100);
        scheduler.start(host_index, timeslot);
`ifndef WAIT_FOR_START_SIG
        start_counting <= 1;
`endif
    endrule

    
/* ------------------------------------------------------------------------------
*                   Simulating connection wires via SyncFIFOs */
/* ------------------------------------------------------------------------------*/

    Vector#(NUM_OF_SWITCH_PORTS, SyncFIFOIfc#(Bit#(72))) wire_fifo_sw_to_node
         <- replicateM(mkSyncFIFO(16, txClock, txReset, rxClock));
    Vector#(NUM_OF_SWITCH_PORTS, SyncFIFOIfc#(Bit#(72))) wire_fifo_node_to_sw
         <- replicateM(mkSyncFIFO(16, txClock, txReset, rxClock));

    // Simulated delay (in cycles) from NIC to switch. 
    // Substitute for propagation delay.
    Integer delay = 1;
    
    Vector#(NUM_OF_SWITCH_PORTS, Vector#(1, FIFO#(Bit#(72)))) fifo_node_to_sw
        <- replicateM(replicateM(mkSizedFIFO(2, clocked_by txClock, reset_by txReset)));

    for (Integer i = 0; i < valueof(NUM_OF_SWITCH_PORTS); i = i + 1)
    begin
        rule tx_rule_node_to_sw;
            let v = mac.tx(i);
            fifo_node_to_sw[i][0].enq(v);
        endrule
    end

    for (Integer i = 0; i < valueof(NUM_OF_SWITCH_PORTS); i = i + 1)
    begin
        for (Integer j = 0; j < delay; j = j + 1)
        begin
            rule get_and_put_node_sw;
                let v <- toGet(fifo_node_to_sw[i][j]).get;
                if (j < delay-1)
                    fifo_node_to_sw[i][j+1].enq(v);
                else
                    wire_fifo_node_to_sw[i].enq(v);
            endrule
        end
    end

    for (Integer i = 0; i < valueof(NUM_OF_SWITCH_PORTS); i = i + 1)
    begin
        rule tx_rule_sw_node;
    `ifndef CW_PHY_SIM
            let v = sw.tx(i);
    `else
            let v <- sw.phyTx[i].get;
    `endif
            wire_fifo_sw_to_node[i].enq(v);
        endrule
    end

    for (Integer i = 0; i < valueof(NUM_OF_SWITCH_PORTS); i = i + 1)
    begin
        rule rx_rule_node_sw;
            let v <- toGet(wire_fifo_node_to_sw[i]).get;
    `ifndef CW_PHY_SIM
            sw.rx(i, v);
    `else
            sw.phyRx[i].put(v);
    `endif
        endrule
    end

    for (Integer i = 0; i < valueof(NUM_OF_SWITCH_PORTS); i = i + 1)
    begin
        rule rx_rule_sw_node;
            let v <- toGet(wire_fifo_sw_to_node[i]).get;
            mac.rx(i, v);
        endrule
    end

	Vector#(NUM_OF_ALTERA_PORTS, Reg#(Bit#(64)))
        time_slots_reg <- replicateM(mkReg(0));
	Vector#(NUM_OF_ALTERA_PORTS, Reg#(Bit#(1)))
        fire_time_slots <- replicateM(mkReg(0));

    for (Integer i = 0; i < valueof(NUM_OF_ALTERA_PORTS); i = i + 1)
    begin
        rule time_slots_rule;
            let res <- scheduler.time_slots_res[i].get;
            time_slots_reg[i] <= res;
            fire_time_slots[i] <= 1;
        endrule

        rule time_slots (fire_time_slots[i] == 1);
            fire_time_slots[i] <= 0;
            indication.display_time_slots_count(fromInteger(i), time_slots_reg[i]);
        endrule
    end

	Vector#(NUM_OF_ALTERA_PORTS, Reg#(Bit#(64)))
        received_host_pkt_reg <- replicateM(mkReg(0));
	Vector#(NUM_OF_ALTERA_PORTS, Reg#(Bit#(1)))
        fire_received_host_pkt <- replicateM(mkReg(0));

    for (Integer i = 0; i < valueof(NUM_OF_ALTERA_PORTS); i = i + 1)
    begin
        rule received_host_pkt_rule;
            let res <- scheduler.received_host_pkt_res[i].get;
            received_host_pkt_reg[i] <= res;
            fire_received_host_pkt[i] <= 1;
        endrule

        rule received_host_pkt (fire_received_host_pkt[i] == 1);
            fire_received_host_pkt[i] <= 0;
            indication.display_received_host_pkt_count(
                fromInteger(i), received_host_pkt_reg[i]);
        endrule
    end

	Vector#(NUM_OF_ALTERA_PORTS, Reg#(Bit#(64)))
        latency_reg <- replicateM(mkReg(0));
	Vector#(NUM_OF_ALTERA_PORTS, Reg#(Bit#(1)))
        fire_latency <- replicateM(mkReg(0));

    for (Integer i = 0; i < valueof(NUM_OF_ALTERA_PORTS); i = i + 1)
    begin
        rule latency_rule;
            let res <- scheduler.latency_res[i].get;
            latency_reg[i] <= truncate(res);
            fire_latency[i] <= 1;
        endrule

        rule latency (fire_latency[i] == 1);
            fire_latency[i] <= 0;
            indication.display_latency(fromInteger(i), latency_reg[i]);
        endrule
    end

	Vector#(NUM_OF_ALTERA_PORTS, Reg#(Bit#(64)))
        max_fwd_buffer_length_reg <- replicateM(mkReg(0));
    Vector#(NUM_OF_ALTERA_PORTS, Reg#(Bit#(1)))
        fire_buffer_length <- replicateM(mkReg(0));

    for (Integer i = 0; i < valueof(NUM_OF_ALTERA_PORTS); i = i + 1)
    begin
        rule get_fwd_buf_len;
            let res <- scheduler.max_fwd_buffer_length_res[i].get;
            max_fwd_buffer_length_reg[i] <= res;
            fire_buffer_length[i] <= 1;
        endrule

        rule print_fwd_buf_len (fire_buffer_length[i] == 1);
            fire_buffer_length[i] <= 0;
            indication.display_buffer_length(fromInteger(i), max_fwd_buffer_length_reg[i]);
        endrule
    end

    Reg#(ServerIndex) host_index_reg <- mkReg(0);
	Reg#(Bit#(16)) rate_reg <- mkReg(0);
    Reg#(Bit#(8)) timeslot_reg <- mkReg(0);
	Reg#(Bit#(64)) cycles_reg <- mkReg(0);

	Reg#(Bit#(1)) fire_reset_state <- mkReg(0);
	Reg#(Bit#(1)) fire_start_scheduler_and_cg_req <- mkReg(0);

	Reg#(Bit#(64)) reset_len_count <- mkReg(0);

    Reg#(Bit#(1)) send_stat_request <- mkReg(0);
    SyncFIFOIfc#(Bit#(8)) reconfig_fifo
        <- mkSyncFIFO(1, defaultClock, defaultReset, rxClock);
    SyncFIFOIfc#(Bit#(64)) sw_timeslot_fifo
        <- mkSyncFIFO(1, defaultClock, defaultReset, rxClock);

    Reg#(Bit#(1)) start_switching_flag <- mkReg(0);
    Reg#(Bit#(8)) reconfig_flag_val <- mkReg(0);
    Reg#(Bit#(64)) timeslot_val <- mkReg(0);

	rule reset_state (fire_reset_state == 1);
		// tx_reset_ifc.assertReset;
        // rx_reset_ifc.assertReset;
		reset_len_count <= reset_len_count + 1;
		if (reset_len_count == 1000)
		begin
			fire_reset_state <= 0;
			//fire_start_scheduler_and_cg_req <= 1;
            start_switching_flag <= 1;
		end
	endrule

    rule send_start_switching_req (start_switching_flag == 1);
        start_switching_flag <= 0;
        reconfig_fifo.enq(reconfig_flag_val);
        sw_timeslot_fifo.enq(timeslot_val);
    endrule

    rule start_switching;
        let d <- toGet(reconfig_fifo).get;
        let t <- toGet(sw_timeslot_fifo).get;
        sw.start(truncate(d), t);
    endrule


	rule start_scheduler_and_cg_req (fire_start_scheduler_and_cg_req == 1);
		fire_start_scheduler_and_cg_req <= 0;
		rate_fifo.enq(rate_reg);
		num_of_cycles_to_run_fifo.enq(cycles_reg);
		host_index_fifo.enq(host_index_reg);
        timeslot_fifo.enq(timeslot_reg);
	endrule

    interface ShoalMultiSimTopRequest request;
        method Action startSwitching(Bit#(8) reconfig_flag, Bit#(64) timeslot);
			fire_reset_state <= 1;
			reset_len_count <= 0;
            reconfig_flag_val <= reconfig_flag;
            timeslot_val <= timeslot;
        endmethod

        method Action printSwStats();
            send_stat_request <= 1;
        endmethod
        method Action start_shoal(Bit#(32) idx,
			                    Bit#(16) rate,
                                Bit#(8) timeslot,
								Bit#(64) cycles);
			host_index_reg <= truncate(idx);
            rate_reg <= rate;
            timeslot_reg <= timeslot;
			cycles_reg <= cycles;
            fire_start_scheduler_and_cg_req <= 1;
        endmethod
    endinterface
endmodule
