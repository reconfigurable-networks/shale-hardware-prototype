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

#include <stdlib.h>
#include <stdio.h>
#include <errno.h>
#include <stdint.h>
#include <unistd.h>

#include "ShoalMultiSimTopIndication.h"
#include "ShoalMultiSimTopRequest.h"
#include "GeneratedTypes.h"

static uint32_t server_index = 0;
static uint32_t rate = 0; //rate of cell generation
static uint32_t timeslot = 0; //timeslot length
static uint64_t cycles = 0; //num of cycles to run exp for

static uint16_t chunk_num = 8;
static uint16_t run_index = 0;

static ShoalMultiSimTopRequestProxy *device = 0;

class ShoalMultiSimTopIndication : public ShoalMultiSimTopIndicationWrapper
{
public:

    /* -----------------   STATS  -----------------------*/

    virtual void display_latency(uint16_t idx, uint64_t count) {
        fprintf(stderr, "run_idx=%u, node_idx=%u, latency_in_cycles=%lu\n", run_index, idx, count);
    }

    virtual void display_buffer_length(uint16_t idx, uint64_t count) {
        fprintf(stderr, "run_idx=%u, node_idx=%u, max_buffer_len=%lu\n", run_index, idx, count);
    }

	virtual void display_time_slots_count(uint16_t idx, uint64_t count) {
        fprintf(stderr, "run_idx=%u, node_idx=%u, num_time_slots=%lu\n", run_index, idx, count);
	}

    virtual void display_received_wrong_dst_pkt_count(uint16_t idx, uint64_t count) {
        fprintf(stderr, "run_idx=%u, node_idx=%u, num_wrong_pkts_recvd=%lu\n", run_index, idx, count);
	}

    virtual void display_received_host_pkt_count(uint16_t idx, uint64_t count) {
        fprintf(stderr, "run_idx=%u, node_idx=%u, num_total_pkts_recvd=%lu\n", run_index, idx, count);
	}

    ShoalMultiSimTopIndication(unsigned int id)
        : ShoalMultiSimTopIndicationWrapper(id) {}
};

int main(int argc, char **argv)
{
    ShoalMultiSimTopIndication echoIndication(IfcNames_ShoalMultiSimTopIndicationH2S);
    device = new ShoalMultiSimTopRequestProxy(IfcNames_ShoalMultiSimTopRequestS2H);

    int i;

    if (argc != 9) {
        printf("Wrong number of arguments\n");
        exit(0);
    } else {
        server_index = atoi(argv[4]);
        rate = atoi(argv[5]);
        timeslot = atoi(argv[6]);
        cycles = atol(argv[7]);

        chunk_num = (atoi(argv[8]) * 8) / 64;
    }

    //  Run experiment i times.
    for (i = 0; i < 3; ++i) {
        printf("********* Starting i = %d **********\n", i);
        device->startSwitching(atoi(argv[1]), atol(argv[2]));
        printf("********** Started Sw i = %d **********\n", i);
        sleep(2);
        device->start_shoal(server_index,
                            rate,
                            timeslot,
                            cycles);
        printf("********** Started NIC i = %d **********\n", i);
        sleep(atoi(argv[3]));
        device->printSwStats();
        printf("********* Sleeping for 15 sec i = %d **********\n", i);
        sleep(15);
    }

    while(1);
    return 0;
}
