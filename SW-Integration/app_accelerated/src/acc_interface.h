// SPDX-License-Identifier: GPL-3.0-only
/*
 * A hardware accelerated LeNet-5 architecture integrated to be accessible
 * by the processing system (CPU) of an FPGA.
 * Copyright (C) 2025  Markus Elias Gerber
 * Copyright (C) 2025  Maxim Balajan
 * 
 * This program is free software: you can redistribute it and/or modify
 * it under the terms of the GNU General Public License as published by
 * the Free Software Foundation, either version 3 of the License, or
 * (at your option) any later version.
 * 
 * This program is distributed in the hope that it will be useful,
 * but WITHOUT ANY WARRANTY; without even the implied warranty of
 * MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.  See the
 * GNU General Public License for more details.
 * 
 * You should have received a copy of the GNU General Public License
 * along with this program.  If not, see <https://www.gnu.org/licenses/>.
 */
#pragma once

#include <iterator>

#include "xaxidma.h"
#include "xil_types.h"
#include "xiltimer.h"

struct AccResult {
    bool error;
    u64 time_ns;
    u8 result;
};

class AccInterface {
   private:
    XAxiDma axi_dma;  // Instance of the XAxiDma
#ifndef SDT
    INTC intc;  // Instance of the Interrupt Controller
#endif

    XAxiDma_Config *config;

    AccInterface();

   public:
    // Flags interrupt handlers use to notify the application context the events.
    volatile u32 tx_done;
    volatile u32 rx_done;
    volatile u32 error;
    volatile XTime end_time;

    static AccInterface instance;

    ~AccInterface();
    AccInterface(AccInterface &other) = delete;
    void operator=(const AccInterface &) = delete;

    struct AccResult run(u8 *tx_buffer, int length);
};
