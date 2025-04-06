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
#include "../src/assert_helper.h"
#include "../src/util.h"
#include "../src/serialize.h"

#include "../src/data/fp_int.h"
#include "../src/data/int24.h"
#include "../src/data/data_converter.h"
#include "../src/data/matrix.h"
#include "../src/data/matrix_view.h"

#include "../src/layers/layer.h"
#include "../src/layers/convolution.h"
#include "../src/layers/dense.h"
#include "../src/layers/flatten.h"
#include "../src/layers/max_pooling.h"
#include "../src/layers/quant_convolution.h"
#include "../src/layers/quant_dense.h"
#include "../src/layers/quant.h"
