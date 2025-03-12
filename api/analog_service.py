
from WF_SDK import device, static, supplies       # import instruments
 
from time import sleep                            # needed for delays

sensors = {
    "state": "initial",
    "minigame": "cakegame",
    "leds": [False, False, False, False, False],
}

states = ["initial", "preparacao", "escolha_minigame", "state3", "state4", "state5"]
minigames = ["cakegame", "clothesgame", "memorygame"]


device_name = "Analog Discovery 2"
 
"""-----------------------------------------------------------------------"""
 
# connect to the device
device_data = device.open()
device_data.name = device_name
 
"""-----------------------------------"""
 
# start the positive supply
supplies_data = supplies.data()
supplies_data.master_state = True
supplies_data.state = True
supplies_data.voltage = 3.3
supplies.switch(device_data, supplies_data)
 
# set all pins as output
for index in range(16):
    static.set_mode(device_data, index, False)
 
try:
    while True:
        # repeat
        mask = 1
        while mask < 0x10000:
            # go through possible states
            for index in range(16):
                # set the state of every DIO channel
                static.get_state(device_data, index)
                print("DIO", index, "is", device_data.state)
            sleep(0.1)  # delay
            mask <<= 1  # switch mask
 
except KeyboardInterrupt:
    # stop if Ctrl+C is pressed
    pass
 
finally:
    # stop the static I/O
    static.close(device_data)
 
    # stop and reset the power supplies
    supplies_data.master_state = False
    supplies.switch(device_data, supplies_data)
    supplies.close(device_data)
 
    """-----------------------------------"""
 
    # close the connection
    device.close(device_data)

