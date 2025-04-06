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
#include <stdio.h>
#include <assert.h>
#include <iostream>
#include <sys/_intsup.h>
#include <sys/types.h>
#include <xiltimer.h>
#include "acc_interface.h"

using namespace std;

unsigned run(char* data, int length, bool verbose) {
    auto res = AccInterface::instance.run(reinterpret_cast<u8*>(data), length);

    if (verbose) {
        cout << "error: " << res.error << endl;
        cout << "time: " << res.time_ns << endl;
        cout << "result: " << static_cast<int>(res.result) << endl;        
    }

    return res.time_ns;
}

int main() {
    char* ptr = (char*) 0x01000000 + 0x00400000;
    *ptr = 10;
    int test_num = 10000;
    unsigned total_latency = 0;

    for (int i = 0; i < test_num; i++) {
        unsigned latency = run(ptr, 32*32, false);

        total_latency += latency;
        cout << "[" << ((i * 100) / test_num) << "%] Inference of " << 1 << " image";
        cout << " completed in " << latency << "ns!" << endl;

        cout << "[BENCH-INFO] " << latency << endl;
    }

    cout << "\n" << "Inference finished!\n";
    cout << "\n";
    cout << "--- Result ---\n";
    cout << "Total inference duration: " << ((1.0*total_latency)/(1000 * 1000 * 1000)) << "s\n";
    cout << "Avg inference duration: " << ((1.0*total_latency)/test_num) << "ns\n";

    cout << "[BENCH-STATUS] Finished" << endl;

    return 0;
}
