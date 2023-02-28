#include "mbed.h"
#include "arm_math.h"

#ifndef DSP_DELAY_H
#define DPS_DELAY_H

#define SMPLE_FRQ_KHZ     (48)
#define MAX_DELAY_TIME_MS (500)
#define DELAY_BUF_SIZE    (SMPLE_FRQ_KHZ*MAX_DELAY_TIME_MS)

namespace dsp_delay {

    struct param {
        bool sw;
        float volume;
        uint32_t d_time;
        float feedback;
        float mix;
        float d_line_buf[DELAY_BUF_SIZE] = {0};
        uint32_t d_line_idx = 0;
        uint32_t d_line_buf_size = DELAY_BUF_SIZE;
    };

    namespace {
        void set_switch(param *p, bool sw) {
            p->sw = sw;
            if (!sw) {
                arm_fill_f32(0.0f, p->d_line_buf, p->d_line_buf_size);
                p->d_line_idx = 0;
            }
        }

        void set_delay_time(param *p, uint32_t delay_time) {
            p->d_time = (delay_time <= MAX_DELAY_TIME_MS) ? delay_time : MAX_DELAY_TIME_MS;
            p->d_line_buf_size = (uint32_t)(SMPLE_FRQ_KHZ*p->d_time);
        }

        void set_feedback_ratio(param *p, float fbk_ratio) {
            p->feedback = fbk_ratio; 
        }

        void set_mix_ratio(param *p, float mix_ratio) {
            p->mix = mix_ratio;
        }

        void set_volume(param *p, float volume) {
            p->volume = volume;
        }

        void process(param *p, float rx_left_buffer[], float rx_right_buffer[], float tx_left_buffer[], float tx_right_buffer[], unsigned int block_size) {
            static float in_sig = 0;
            static float fb_sig = 0;
            static float out_sig = 0;

            if (p->sw) { 
                if (rx_right_buffer != nullptr) {
                    for (uint32_t i = 0; i < block_size; i++) {

                    }
                } else {
                    for (uint32_t i = 0; i < block_size; i++) {
                        in_sig = rx_left_buffer[i] / 2.0f;
                        fb_sig = p->d_line_buf[p->d_line_idx] * p->feedback;
                        p->d_line_buf[p->d_line_idx] = in_sig + fb_sig;
                        tx_left_buffer[i] = p->d_line_buf[p->d_line_idx] * p->volume;
                        p->d_line_idx = (p->d_line_idx + 1) % p->d_line_buf_size;
                    }
                }
            } else { // copy
                if (rx_right_buffer != nullptr) {
                    arm_copy_f32(rx_left_buffer, tx_left_buffer, block_size);
                    arm_copy_f32(rx_right_buffer, tx_right_buffer, block_size);
                } else arm_copy_f32(rx_left_buffer, tx_left_buffer, block_size);
            }
        }

        void process(param *p, float *rx_buffer, float *tx_buffer, unsigned int block_size) {
            process(p, rx_buffer, nullptr, tx_buffer, nullptr, block_size);
        }
    }
};

#endif