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
#include "dense.h"
#include "../data/data_converter.h"

template<typename T, typename ACC>
Dense<T, ACC>::Dense(Matrix<T> weights, Matrix<T> bias, Matrix<T> output_buffer, bool enable_softmax)
    : weights(weights)
    , bias(bias)
    , enable_softmax(enable_softmax)
    , output_buffer(output_buffer) {}

template<typename T, typename ACC>
Dense<T, ACC>::Dense(Matrix<T> weights, Matrix<T> bias, bool enable_softmax, size_t batching, size_t x)
    : Dense(weights, bias, Matrix<T>({batching, x}), enable_softmax) {}


namespace {
    template<typename T>
    inline void softmax(Matrix<T>& input) {
        for (size_t batch_id = 0; batch_id < input.shape()[0]; batch_id++)
        {
            size_t max_id = 0;
            // Determine greatest value
            for (size_t x_id = 1; x_id < input.shape()[1]; x_id++)
            {
                if (input[{batch_id, x_id}] > input[{batch_id, max_id}])
                {
                    max_id = x_id;
                }
                
            }
            // Fill vector with 0s and single 1
            for (size_t x_id = 0; x_id < input.shape()[1]; x_id++)
            {
                input[{batch_id, x_id}] = convert_data<float, T>(0.0f);
            }

            input[{batch_id, max_id}] = convert_data<float, T>(1.0f);
            
        }
    }
}

template<typename T, typename ACC>
const Matrix<T>& Dense<T, ACC>::calc(const Matrix<T>& input)
{
    for (size_t batch_id = 0; batch_id < input.shape()[0]; batch_id++)
    {
        for (size_t wy_id = 0; wy_id < weights.shape()[1]; wy_id++)
        {
            T tmp = convert_data<float, T>(0.0f);

            for (size_t x_id = 0; x_id < input.shape()[1]; x_id++)
            {
                tmp += weights[{x_id, wy_id}] * input[{batch_id, x_id}];
            }

            output_buffer[{batch_id, wy_id}] = tmp + bias[{wy_id}];
        }
    }
//    cout << "Dense output " << output_buffer << "\n";

    if (enable_softmax) {
        softmax(output_buffer);
    }

    return output_buffer;
}


template<typename T, typename ACC>
const char* Dense<T, ACC>::name() const {
    return "Dense";
}

template<typename T, typename ACC>
LayerType Dense<T, ACC>::type() const {
    return LayerType::Dense;
}

template<typename T, typename ACC>
unsigned Dense<T, ACC>::serialize(ostream& stream) const {
    return 0;
}

template<typename T, typename ACC>
Dense<T, ACC> Dense<T, ACC>::deserialize(span<char>& data) {
    Matrix<T> weights({0});
    Matrix<T> bias({0});
    bool enable_softmax = false;
    size_t batching = 0;
    size_t x = 0;

    return Dense(weights, bias, enable_softmax, batching, x);
}
