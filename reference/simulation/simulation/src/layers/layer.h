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

#include "../data/matrix.h"
#include <ostream>

enum class LayerType {
    Convolution = 0,
    Dense = 1,
    Flatten = 2,
    MaxPooling = 3,
    QuantConvolution = 4,
    QuantDense = 5,
    Quant = 6
};

template<typename T, typename ACC>
class Layer {
public:
    virtual ~Layer() {}
    virtual const Matrix<T>& calc(const Matrix<T>& input) = 0;
    virtual const char* name() const = 0;
    virtual LayerType type() const = 0;
    virtual unsigned serialize(ostream& stream) const = 0;
};
