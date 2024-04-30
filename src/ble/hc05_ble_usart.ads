with Serial_IO.Interrupt_Driven;            use Serial_IO.Interrupt_Driven;
with Software_Ble;             

package HC05_BLE_USART is new Software_Ble
  (Transport_Media => Serial_Port,
   Read            => Get,
   Write           => Put);