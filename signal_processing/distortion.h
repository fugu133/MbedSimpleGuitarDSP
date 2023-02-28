#include "mbed.h"
#include "fast_atan.h"
#include "arm_math.h"

#ifndef DPS_DISTORTION_H
#define DSP_DISTORTION_H

#define DIV2_PI (0.6366198f)

namespace dsp_distortion {
    struct param {
        bool sw; // switch
        float volume; // master volume
        float gain;   // gain 
        float range;  // gain range
        float mix;  // clean signal and distortion siganl blend parameter
    };

    namespace {
        float distortion(float gain, float clean) {
            return DIV2_PI*fast_atan(clean*gain);
        }

        void process(param *p, float rx_left_buffer[], float rx_right_buffer[], float tx_left_buffer[], float tx_right_buffer[], unsigned int block_size) {
            float process_gain = p->gain * p->range;
            float process_mix_dist = 1-p->mix;
            float process_mix_clean = p->mix;
            float process_volume = p->volume/2.0f;
        
            if (p->sw) { 
                if (rx_right_buffer != nullptr) {
                    for (uint32_t i = 0; i < block_size; i++) {
                        tx_left_buffer[i] = (distortion(process_gain, rx_left_buffer[i])*process_mix_dist + rx_left_buffer[i]*process_mix_clean) * process_volume;
                        tx_right_buffer[i] = (distortion(process_gain, rx_right_buffer[i])*process_mix_dist + rx_right_buffer[i]*process_mix_clean) * process_volume;
                    }
                } else {
                    for (uint32_t i = 0; i < block_size; i++) {
                        tx_left_buffer[i] = (distortion(process_gain, rx_left_buffer[i])*process_mix_dist + rx_left_buffer[i]*process_mix_clean) * process_volume;
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