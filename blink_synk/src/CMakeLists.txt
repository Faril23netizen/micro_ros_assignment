add_executable(${NAME}
        main.cpp
        BlinkAgent.cpp
        Agent.cpp
        BlinkWorker.cpp
        pico_uart_transport.c
        )

# micro-ROS
set(MICROROS_DIR "${CMAKE_CURRENT_LIST_DIR}/../lib/libmicroros")

# Pull in our pico_stdlib which pulls in commonly used features
target_link_directories(${NAME} PRIVATE ${MICROROS_DIR})
target_link_libraries(${NAME} 
	 pico_stdlib
	 hardware_pwm
     FreeRTOS-Kernel-Heap4 
     microros
	)
	
target_include_directories(${NAME} PRIVATE
    ${CMAKE_CURRENT_LIST_DIR}
    ${MICROROS_DIR}/include
     )
     
target_compile_definitions(${NAME} PRIVATE
    configNUM_CORES=2
)

# create map/bin/hex file etc.
pico_add_extra_outputs(${NAME})

# enable usb output, disable uart output
pico_enable_stdio_usb(${NAME} 1)
pico_enable_stdio_uart(${NAME} 0)