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
#include <cstdint>
#include "fp_int.h"

template<typename T>
concept IsWrapper = requires(T t) {
    t.get_val();
};

static_assert(IsWrapper<FPInt8<0>>);

template<typename FROM, typename TO>
requires IsWrapper<TO> && IsWrapper<FROM>
TO convert_data(FROM input) {
    return TO(input.get_double());
}

template<typename FROM, typename TO>
requires IsWrapper<TO>
TO convert_data(FROM input) {
    return TO(input);
}

template<typename FROM, typename TO>
requires IsWrapper<FROM>
TO convert_data(FROM input) {
    return static_cast<TO>(input.get_val());
}

template<typename FROM, typename TO>
TO convert_data(FROM input) {
    return static_cast<TO>(input);
}
