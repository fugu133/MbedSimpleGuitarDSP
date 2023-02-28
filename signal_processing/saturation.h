#include "mbed.h"
#include "arm_math.h"

namespace dsp_saturation {
    struct param {
        float max;
        float min;
    };

    namespace {
        float saturation(float min, float max, float data) {
            return (data <= max) ? ((-1.0f <= min) ? data : min) : max;
        }

        void process(param *p, float rx_left_buffer[], float rx_right_buffer[], float tx_left_buffer[], float tx_right_buffer[], unsigned int block_size) {
            if (rx_right_buffer != nullptr) {
                for (uint32_t i = 0; i < block_size; i++) {
                    tx_left_buffer[i] = saturation(p->min, p->max, rx_left_buffer[i]);
                    tx_right_buffer[i] = saturation(p->min, p->max, rx_right_buffer[i]);
                }
            } else {
                for (uint32_t i = 0; i < block_size; i++) tx_left_buffer[i] = saturation(p->min, p->max, rx_left_buffer[i]);
            }
        }

        void process(param *p, float rx_buffer[], float tx_buffer[], unsigned int block_size) {
            process(p, rx_buffer, nullptr, tx_buffer, nullptr, block_size);
        }
    }
}