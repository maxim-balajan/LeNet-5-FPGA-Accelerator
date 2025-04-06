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
#include "layers/convolution.h"
#include "layers/dense.h"
#include "layers/flatten.h"
#include "layers/layer.h"
#include "layers/max_pooling.h"
#include "layers/quant.h"
#include "layers/quant_dense.h"
#include "layers/quant_convolution.h"
#include "util.h"
#include <ostream>
#include <memory>
#include <vector>

using namespace std;

template<typename T, typename ACC>
unsigned serialize_layers(const vector<unique_ptr<Layer<T, ACC>>>& layers, ostream& stream) {
    unsigned bytes = 0;
    bytes += serialize_number(static_cast<unsigned>(layers.size()), stream);

    for (const auto& layer : layers) {
        unsigned layer_type = static_cast<unsigned>(layer.get()->type());
        bytes += serialize_number(layer_type, stream);
        bytes += layer.get()->serialize(stream);
    }

    return bytes;
}


template<typename T, typename ACC>
vector<unique_ptr<Layer<T, ACC>>> deserialize_layers(span<char>& data) {
    unsigned num_layers = deserialize_number<unsigned>(data);

    vector<unique_ptr<Layer<T, ACC>>> layers;

    for (unsigned i = 0; i < num_layers; i++) {
        unsigned layer_type = deserialize_number<unsigned>(data);
        switch (static_cast<LayerType>(layer_type)) {
            case LayerType::Convolution:
                layers.push_back(make_unique<Convolution<T, ACC>>(Convolution<T, ACC>::deserialize(data)));
                break;
            case LayerType::Dense:
                layers.push_back(make_unique<Dense<T, ACC>>(Dense<T, ACC>::deserialize(data)));
                break;
            case LayerType::Flatten:
                layers.push_back(make_unique<Flatten<T, ACC>>(Flatten<T, ACC>::deserialize(data)));
                break;
            case LayerType::MaxPooling:
                layers.push_back(make_unique<MaxPooling<T, ACC>>(MaxPooling<T, ACC>::deserialize(data)));
                break;
            case LayerType::QuantConvolution:
                layers.push_back(make_unique<QuantConvolution<T, ACC>>(QuantConvolution<T, ACC>::deserialize(data)));
                break;
            case LayerType::QuantDense:
                layers.push_back(make_unique<QuantDense<T, ACC>>(QuantDense<T, ACC>::deserialize(data)));
                break;
            case LayerType::Quant:
                layers.push_back(make_unique<Quant<T, ACC>>(Quant<T, ACC>::deserialize(data)));
                break;
            default:
                throw exception();
        }
    }
    
    return layers;    
}
