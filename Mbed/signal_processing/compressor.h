#include "mbed.h"
#include "arm_math.h"

#ifndef DSP_COMPRESSOR_H
#define DSP_COMPRESSOR_H

namespace dsp_compressor {
    struct param {
        bool sw;
        float volume;
        float threshold;
        float ratio;
    };

    namespace {
        float compressor(float threshold, float ratio, float data) {
            return (data >= threshold) ? data*ratio : ((data <= -threshold) ? data*ratio : data);
        }

        void process(param *p, float rx_left_buffer[], float rx_right_buffer[], float tx_left_buffer[], float tx_right_buffer[], unsigned int block_size) {
            if (p->sw) { 
                if (rx_right_buffer != nullptr) {
                    for (uint32_t i = 0; i < block_size; i++) {
                        tx_left_buffer[i] = compressor(p->threshold, p->ratio, rx_left_buffer[i]);
                        tx_right_buffer[i] = compressor(p->threshold, p->ratio, rx_right_buffer[i]);
                    }
                } else {
                    for (uint32_t i = 0; i < block_size; i++) {
                        tx_left_buffer[i] = compressor(p->threshold, p->ratio, rx_left_buffer[i]);
                    }
                }
            } else { // copy
                if (rx_right_buffer != nullptr) {
                    arm_copy_f32(rx_left_buffer, tx_left_buffer, block_size);
                    arm_copy_f32(rx_right_buffer, tx_right_buffer, block_size);
                } else arm_copy_f32(rx_left_buffer, tx_left_buffer, block_size);
            }
        }

        void process(param *p, float rx_buffer[], float tx_buffer[], uint32_t block_size) {
            process(p, rx_buffer, nullptr, tx_buffer, nullptr, block_size);
        }
    }
}

#endif 