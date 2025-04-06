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
class Dense: public Layer<T, ACC> {
private:
    Matrix<T> output_buffer;
    const Matrix<T> weights;
    const Matrix<T> bias;
    bool enable_softmax;

    Dense(Matrix<T> weights, Matrix<T> bias, Matrix<T> output_buffer, bool enable_softmax);

public:
    Dense(Matrix<T> weights, Matrix<T> bias, bool enable_softmax, size_t batching, size_t x);

    virtual const Matrix<T>& calc(const Matrix<T>& input) override;
    virtual const char* name() const override;
    virtual LayerType type() const override;
    virtual unsigned serialize(ostream& stream) const override;
    static Dense deserialize(span<char>& data);
};

#include "dense.tpp"
