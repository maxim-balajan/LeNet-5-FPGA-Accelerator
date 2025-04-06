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
#include "quant.h"

#include "../data/matrix.h"

template<typename T, typename ACC>
Quant<T, ACC>::Quant(Matrix<T> output_buffer, T inv_scale, T zero_point)
    : output_buffer(output_buffer)
    , zero_point(zero_point)
    , inv_scale(inv_scale) {}

template<typename T, typename ACC>
Quant<T, ACC>::Quant(vector<size_t> dimensions, T inv_scale, T zero_point)
    : Quant(Matrix<T>(dimensions), zero_point, inv_scale) {}

template<typename T, typename ACC>
const Matrix<T>& Quant<T, ACC>::calc(const Matrix<T>& input) {
    assertm(input.total_size() == output_buffer.total_size(), "sizes should match!");

    // clamp should happen automatically
    for (int i = 0; i < input.total_size(); i++) {
        // TODO check different precisions
        output_buffer[i] = input[i] * inv_scale + zero_point;
    }

    return output_buffer;
}

template<typename T, typename ACC>
const char* Quant<T, ACC>::name() const {
    return "Quant";
}

template<typename T, typename ACC>
LayerType Quant<T, ACC>::type() const {
    return LayerType::Quant;
}

template<typename T, typename ACC>
unsigned Quant<T, ACC>::serialize(ostream& stream) const {
    unsigned bytes = 0; 

    bytes += serialize_number(inv_scale, stream);
    bytes += serialize_number(zero_point, stream);
    bytes += serialize_vector(output_buffer.shape(), stream);

    return bytes;
}

template<typename T, typename ACC>
Quant<T, ACC> Quant<T, ACC>::deserialize(span<char>& data) {
    T inv_scale = deserialize_number<T>(data);
    T zero_point = deserialize_number<T>(data);

    vector<size_t> out_shape = deserialize_vector<size_t>(data);
    Matrix<T> output_buffer(out_shape);

    return Quant(output_buffer, inv_scale, zero_point);
}
