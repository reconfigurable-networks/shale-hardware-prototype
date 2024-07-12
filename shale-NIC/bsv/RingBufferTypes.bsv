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

import DefaultValue::*;

`include "ConnectalProjectConfig.bsv"

typedef 512 BUS_WIDTH;
typedef 9 BUS_WIDTH_POW_OF_2;

typedef Bit#(32) Address;

typedef enum {READ, PEEK, WRITE} Operation deriving(Bits, Eq);

typedef struct {
    Bit#(1) sop;
    Bit#(1) eop;
    Bit#(BUS_WIDTH) payload;
} RingBufferDataT deriving(Bits, Eq);

instance DefaultValue#(RingBufferDataT);
	defaultValue = RingBufferDataT {
		sop     : 0,
		eop     : 0,
		payload : 0
	};
endinstance

typedef struct {
    Operation op;
} ReadReqType deriving(Bits, Eq);

typedef struct {
    RingBufferDataT data;
} ReadResType deriving(Bits, Eq);

instance DefaultValue#(ReadResType);
    defaultValue = ReadResType {
        data : unpack(0)
    };
endinstance

typedef struct {
    RingBufferDataT data;
} WriteReqType deriving(Bits, Eq);

function ReadReqType makeReadReq(Operation op);
    return ReadReqType {
        op : op
    };
endfunction

function ReadResType makeReadRes(RingBufferDataT data);
    return ReadResType {
        data : data
    };
endfunction

function WriteReqType makeWriteReq
        (Bit#(1) sop, Bit#(1) eop, Bit#(BUS_WIDTH) payload);
    RingBufferDataT d = RingBufferDataT {
        sop     : sop,
        eop     : eop,
        payload : payload
    };

    return WriteReqType {
        data : d
    };
endfunction

