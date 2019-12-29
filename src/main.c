/**
 * STM32F103 USB Bootloader
 *
 * John Berg @ netbasenext.nl
 */

#include "stm32f1xx.h"
#include "system_stm32f1xx.h"

// delay loop for 8 MHz CPU clock with optimizer enabled
void delay(uint32_t msec)
{
    for (uint32_t j = 0; j < 2000UL * msec; j++)
    {
        __NOP();
    }
}

int main(void)
{
    // at this point, a firmware update is pending

    //Step 1: Enable the clock to PORT C
    RCC->APB2ENR |= RCC_APB2ENR_IOPCEN;

    //Step 2: Change PC13's mode to 0x3 (output) and cfg to 0x0 (push-pull)
    GPIOC->CRH = GPIO_CRH_MODE13_0 | GPIO_CRH_MODE13_1;

    while (1)
    {
        //Step 3: Reset PC13 low = on
        GPIOC->BSRR = GPIO_BSRR_BR13;
        delay(1000);

        //Step 4: Set PC13 high
        GPIOC->BSRR = GPIO_BSRR_BS13;
        delay(1000);
    }

    return 0;
}
