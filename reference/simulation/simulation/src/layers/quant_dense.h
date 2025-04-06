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

#include "layer.h"
#include "../data/matrix.h"
#include <span>

using namespace std;

template<typename T, typename ACC>
class QuantDense: public Layer<T, ACC> {
private:
    Matrix<T> output_buffer;
    const Matrix<T> weights;
    const Matrix<T> bias;
    const bool enable_softmax;
    const float s_b;
    const float s_x;
    const float s_w;
    const float s_y;

    const uint8_t s_b_shift;
    const uint8_t s_x_shift;

    QuantDense(Matrix<T> weights, Matrix<T> bias, bool enable_softmax, Matrix<T> output_buffer, float s_b, float s_x, float s_w, float s_y);

public:
    QuantDense(Matrix<T> weights, Matrix<T> bias, bool enable_softmax, size_t batching, size_t x, float s_b, float s_x, float s_w, float s_y);

    virtual const Matrix<T>& calc(const Matrix<T>& input) override;
    virtual const char* name() const override;
    virtual LayerType type() const override;
    virtual unsigned serialize(ostream& stream) const override;
    static QuantDense deserialize(span<char>& data);
};

#include "quant_dense.tpp"
