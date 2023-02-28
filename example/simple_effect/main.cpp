/**
 * @file main.cpp
 * @author Kaiji Takeuchi
 * @remark Audio Codec Framework: https://os.mbed.com/users/shorie/notebook/unzen_audio_framework/
 * @version 0.1
 */

#include "mbed.h"
#include "unzen.h"          // audio framework include file
#include "umb_adau1361a.h"  // audio codec contoler include file
#include "amakusa.h"        // audio signal processing class library.
#include "compressor.h"
#include "distortion.h"
#include "delay.h"

using namespace amakusa;
using namespace shimabara;
using namespace unzen;

#define CODEC_I2C_ADDR 0x38 // Address of the ADAU-1361A
#define SMPLE_FRQ      48e3 // sampling frequency
#define FILTER_TUP     16
#define BUFFER_SIZE    4
#define BLOCK_SIZE     FILTER_TUP*BUFFER_SIZE // sampling block size
#define I2C_SCL        PB_8 
#define I2C_SDA        PB_9

I2C i2c(I2C_SDA, I2C_SCL);
UMB_ADAU1361A codec(Fs_48, i2c, CODEC_I2C_ADDR);
Framework audio; 

// signal processing initialization call back.
void init_callback(unsigned int block_size);

// signal processing call back.
void process_callback(float rx_left_buffer[], float rx_right_buffer[], float tx_left_buffer[], float tx_right_buffer[], unsigned int block_size);


volatile float knob_data[3] = {0};

dsp_compressor::param comp_p;
dsp_distortion::param dist_p;
dsp_delay::param delay_p;

int main() 
{    

    i2c.frequency(100000);

    audio.set_block_size(BLOCK_SIZE);
    audio.start(init_callback, process_callback);

    codec.start();
    codec.set_hp_output_gain(0, 0); 
    codec.set_line_output_gain(-10, -10);

    // compressor effect parameter
    comp_p.sw = true;
    comp_p.volume = 1.0;
    comp_p.ratio = 0.7;
    comp_p.threshold = 0.1;
    
    // distortion effect prameter
    dist_p.sw = true;    
    dist_p.volume = 1.5f;
    dist_p.gain = 10.0f;
    dist_p.range = 1.0f;
    dist_p.mix = 0.0f;    

    // delay effect parameter
    dsp_delay::set_switch(&delay_p, true);
    dsp_delay::set_delay_time(&delay_p, 250);
    dsp_delay::set_volume(&delay_p, 2.0f);
    dsp_delay::set_feedback_ratio(&delay_p, 0.5f);

    while(true) {

    }
}

// signal processing initialization call back.
void init_callback(unsigned int block_size)
{
    // place initialization code here
}
 
// signal processing call back.
void process_callback(float rx_left_buffer[], float rx_right_buffer[], float tx_left_buffer[], float tx_right_buffer[], unsigned int block_size)
{
    // generate tone.
    osc.run(tx_left_buffer, block_size);
    arm_copy_f32(tx_left_buffer, tx_right_buffer, block_size); // copy
    
    // siganl processing (comp -> dist -> delay)
    dsp_compressor::process(&comp_p, tx_left_buffer, tx_left_buffer, block_size); // compressor process
    dsp_distortion::process(&dist_p, tx_left_buffer, tx_left_buffer, block_size); // distortion process
    dsp_delay::process(&delay_p, tx_left_buffer, tx_left_buffer, block_size); // delay process
}

