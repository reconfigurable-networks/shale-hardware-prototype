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

#include "ShaleMultiSimTopIndication.h"
#include "ShaleMultiSimTopRequest.h"
#include "GeneratedTypes.h"

static uint32_t server_index = 0;
static uint32_t rate = 0; //rate of cell generation
static uint32_t timeslot = 0; //timeslot length
static uint64_t cycles = 0; //num of cycles to run exp for
static uint16_t run_index = 0;

static ShaleMultiSimTopRequestProxy *device = 0;

class ShaleMultiSimTopIndication : public ShaleMultiSimTopIndicationWrapper
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

    ShaleMultiSimTopIndication(unsigned int id)
        : ShaleMultiSimTopIndicationWrapper(id) {}
};

int main(int argc, char **argv)
{
    ShaleMultiSimTopIndication echoIndication(IfcNames_ShaleMultiSimTopIndicationH2S);
    device = new ShaleMultiSimTopRequestProxy(IfcNames_ShaleMultiSimTopRequestS2H);

    int i;

    if (argc != 5) {
        printf("Wrong number of arguments\n");
        exit(0);
    } else {
        server_index = 0;
        rate = atoi(argv[3]);
        timeslot = atoi(argv[1]);
        cycles = atol(argv[4]);
    }

    //  Run experiment i times.
    for (i = 0; i < 3; ++i) {
        printf("********* Starting i = %d **********\n", i);
        device->startSwitching(1, atol(argv[1]));
        printf("********** Started Sw i = %d **********\n", i);
        sleep(2);
        device->start_shale(server_index,
                            rate,
                            timeslot,
                            cycles);
        printf("********** Started NIC i = %d **********\n", i);
        sleep(atoi(argv[2]));
        device->printSwStats();
        printf("********* Sleeping for 15 sec i = %d **********\n", i);
        sleep(15);
    }

    while(1);
    return 0;
}
