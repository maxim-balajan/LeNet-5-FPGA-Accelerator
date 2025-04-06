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
#include "matrix_view.h"

template<typename T>
MatrixView<T>::MatrixView(Matrix<T> original_data, size_t window_size)
    : original_data(original_data)
    , curr_index(0)
    , current_data({1}) // init later
{
    vector<size_t> shape(original_data.shape());
    if (shape[0] % window_size != 0) {
        if (shape[0] >= window_size) {
            throw new runtime_error("size is too big!");
        }

        throw new runtime_error("matrix size is not devisable by window size!");
    }

    shape[0] = window_size;
    current_data = Matrix<T>(shape);

    element_count = 1;
    for (auto& dim : shape) {
        element_count *= dim;
    }

    // load first item
    next();
}

template<typename T>
const Matrix<T>& MatrixView<T>::get_current() {
    return current_data;
}

template<typename T>
bool MatrixView<T>::next() {
    if (curr_index * current_data.shape()[0] >= original_data.shape()[0]) {
        return false;
    }
    size_t offset = curr_index * element_count;

    for (int i = 0; i < element_count; i++) {
        current_data[i] = original_data[i + offset];
    }

    curr_index++;

    return true;
}
