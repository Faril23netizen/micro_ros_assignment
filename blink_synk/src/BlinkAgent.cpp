/*
 * BlinkAgent.cpp
 *
 *  Created on: 15 Aug 2022
 *      Author: jondurrant
 */

#include "BlinkAgent.h"

#include "stdio.h"


//Blink Delay
#define DELAY			500

/***
 * Constructor
 * @param gp - GPIO Pad number for LED
 */
BlinkAgent::BlinkAgent(uint8_t gp) {
	xLedPad = gp;

}

/***
 * Destructor
 */
BlinkAgent::~BlinkAgent() {
	stop();
}


 /***
  * Main Run Task for agent
  */
 void BlinkAgent::run(){
	gpio_init(xLedPad);

	gpio_set_dir(xLedPad, GPIO_OUT);

extern volatile bool led_agent_state;
	while (true) { // Loop forever
        led_agent_state = true;
		gpio_put(xLedPad, 1);
		vTaskDelay(DELAY);
        led_agent_state = false;
		gpio_put(xLedPad, 0);
		vTaskDelay(DELAY);
	}

 }

/***
 * Get the static depth required in words
 * @return - words
 */
configSTACK_DEPTH_TYPE BlinkAgent::getMaxStackSize(){
	return 150;
}
