/***
 * Demo program to flash an LED attached to GPIO PAD 0.
 * Uses FreeRTOS Task + micro-ROS
 * Jon Durrant / Modified for micro-ROS
 */

#include "pico/stdlib.h"
#include "FreeRTOS.h"
#include "task.h"
#include <stdio.h>

#include "BlinkAgent.h"
#include "BlinkWorker.h"

extern "C" {
#include <rcl/rcl.h>
#include <rcl/error_handling.h>
#include <rclc/rclc.h>
#include <rclc/executor.h>
#include <std_msgs/msg/bool.h>
#include <std_msgs/msg/string.h>
#include <rmw_microros/rmw_microros.h>
#include "pico_uart_transports.h"
}

//Standard Task priority
#define TASK_PRIORITY		( tskIDLE_PRIORITY + 1)

//LED PAD to use
#define LED_PAD				0
#define LED1_PAD			2
#define LED2_PAD			3
#define ONBOARD_LED			25

volatile bool led_agent_state = false;
volatile bool led_worker1_state = false;
volatile bool led_worker2_state = false;

/***
 * Micro-ROS Task to publish LED states
 */
void microRosTask(void *params) {
    // Use onboard LED as diagnostic: fast blink = trying to connect
    gpio_init(ONBOARD_LED);
    gpio_set_dir(ONBOARD_LED, GPIO_OUT);

    // Signal: task started (3 quick flashes)
    for (int i = 0; i < 6; i++) {
        gpio_put(ONBOARD_LED, i % 2);
        vTaskDelay(pdMS_TO_TICKS(100));
    }

    rmw_uros_set_custom_transport(
        true,
        NULL,
        pico_serial_transport_open,
        pico_serial_transport_close,
        pico_serial_transport_write,
        pico_serial_transport_read
    );

    rcl_allocator_t allocator = rcl_get_default_allocator();
    rclc_support_t support;

    // Wait for micro-ROS agent connection (blink onboard LED while waiting)
    bool onboard_state = false;
    while(rmw_uros_ping_agent(1000, 1) != RMW_RET_OK) {
        onboard_state = !onboard_state;
        gpio_put(ONBOARD_LED, onboard_state);
        vTaskDelay(pdMS_TO_TICKS(200));
    }

    // Agent connected! Solid ON
    gpio_put(ONBOARD_LED, 1);

    rclc_support_init(&support, 0, NULL, &allocator);

    rcl_node_t node;
    rclc_node_init_default(&node, "pico_blink_synk", "", &support);

    // Individual Bool publishers
    rcl_publisher_t pub_agent;
    rcl_publisher_t pub_worker1;
    rcl_publisher_t pub_worker2;
    rclc_publisher_init_default(&pub_agent, &node, ROSIDL_GET_MSG_TYPE_SUPPORT(std_msgs, msg, Bool), "/led_agent/state");
    rclc_publisher_init_default(&pub_worker1, &node, ROSIDL_GET_MSG_TYPE_SUPPORT(std_msgs, msg, Bool), "/led_worker1/state");
    rclc_publisher_init_default(&pub_worker2, &node, ROSIDL_GET_MSG_TYPE_SUPPORT(std_msgs, msg, Bool), "/led_worker2/state");

    // Combined String publisher (shows all 3 at once)
    rcl_publisher_t pub_status;
    rclc_publisher_init_default(&pub_status, &node, ROSIDL_GET_MSG_TYPE_SUPPORT(std_msgs, msg, String), "/blink_synk/status");

    std_msgs__msg__Bool msg_agent;
    std_msgs__msg__Bool msg_worker1;
    std_msgs__msg__Bool msg_worker2;
    std_msgs__msg__String msg_status;
    char status_buf[128];
    msg_status.data.data = status_buf;
    msg_status.data.capacity = sizeof(status_buf);

    while (true) {
        msg_agent.data = led_agent_state;
        msg_worker1.data = led_worker1_state;
        msg_worker2.data = led_worker2_state;

        rcl_publish(&pub_agent, &msg_agent, NULL);
        rcl_publish(&pub_worker1, &msg_worker1, NULL);
        rcl_publish(&pub_worker2, &msg_worker2, NULL);

        // Format combined status string
        snprintf(status_buf, sizeof(status_buf),
            "Agent(GP0):%s | Worker1(GP2):%s | Worker2(GP3):%s",
            led_agent_state ? "ON " : "OFF",
            led_worker1_state ? "ON " : "OFF",
            led_worker2_state ? "ON " : "OFF");
        msg_status.data.size = strlen(status_buf);
        rcl_publish(&pub_status, &msg_status, NULL);

        vTaskDelay(pdMS_TO_TICKS(100)); // 10Hz
    }
}

/***
 * Main task to blink external LED
 * @param params - unused
 */
void mainTask(void *params){
	BlinkAgent blink(LED_PAD);
	BlinkWorker worker1(LED1_PAD);
	BlinkWorker worker2(LED2_PAD);

	worker1.setPeer(&worker2);
	worker2.setPeer(&worker1);

	blink.start("Blink",
	  TASK_PRIORITY);
	worker1.start("Worker 1",
	  TASK_PRIORITY);
	worker2.start("Worker 2",
	  TASK_PRIORITY);

	while (true) { // Loop forever
		vTaskDelay(3000);
	}
}

/***
 * Launch the tasks and scheduler
 */
void vLaunch( void) {

	//Start blink task
    TaskHandle_t task;
    xTaskCreate(mainTask, "MainThread", 500, NULL, TASK_PRIORITY, &task);
    
    //Start micro-ROS task (requires large stack for rclc init)
    TaskHandle_t uros_task;
    xTaskCreate(microRosTask, "uROS", 4096, NULL, TASK_PRIORITY + 1, &uros_task);

    /* Start the tasks and timer running. */
    vTaskStartScheduler();
}

/***
 * Main
 * @return
 */
int main( void )
{
    // Init USB stdio early and wait for USB to enumerate
    stdio_init_all();
    sleep_ms(2000);

    //Start tasks and scheduler
    vLaunch();

    return 0;
}
