from WF_SDK import device, static, supplies       # import instruments
from time import sleep                            # needed for delays

sensors = {
    "state": "inicio",
    "minigame": "memorygame",
    "jogada": [False, False, False, False, False, False, False],
    "pontuacao": 0,
}

cake_states = ["inicio", "preparation", "show_play", "show_interval", "next_show", "initiate_play", "wait_play", 
                "register_play", "compare_play", "next_play", "start_show", "register_show", "end_state", "Erro", "Erro", "Erro"]

genius_states =["inicial", "preparacao", "proxima_mostra", "espera_jogada", "registra_jogada", "compara_jogada", 
                "proxima_jogada", "foi_ultima_sequencia", "proxima_sequencia", "mostra_jogada", "intervalo_mostra", 
                "inicia_sequencia", "intervalo_rodada", "final_timeout", "final_acertou", "final_errou"]

minigames = ["memorygame", "cakegame", "memorygame", "cakegame"]
device_name = "Analog Discovery 2"


def convert_dec(bin):
    dec = 0
    for i in range(len(bin)):
        if (bin[i]):
            dec += 2**i
    return dec


def analog_loop():
    # connect to the device
    global device_data
    device_data = device.open()
    device_data.name = device_name
        
    # start the positive supply
    global supplies_data 
    supplies_data = supplies.data()
    supplies_data.master_state = True
    supplies_data.state = True
    supplies_data.voltage = 3.3
    supplies.switch(device_data, supplies_data)
    # set all pins as input
    for index in range(16):
        static.set_mode(device_data, index, False)
    while True:
        # go through possible states
        sensors_temp = []
        for index in range(16):
            # set the state of every DIO channel
            sensors_temp.append(static.get_state(device_data, index))
        # sleep(0.0001)  # delay
        sensors["jogada"] = sensors_temp[:7]
        sensors["minigame"] = minigames[convert_dec(sensors_temp[11:13])]
        if (sensors["minigame"] == "cakegame"):
            sensors["state"] = cake_states[convert_dec(sensors_temp[7:11])]
        else:
            sensors["state"] = genius_states[convert_dec(sensors_temp[7:11])]
        sensors["pontuacao"] = convert_dec(sensors_temp[13:])
        print(sensors)
   

def close_analog():
    # stop the static I/O
    static.close(device_data)

    # stop and reset the power supplies
    supplies_data.master_state = False
    supplies.switch(device_data, supplies_data)
    supplies.close(device_data)

    # close the connection
    device.close(device_data)

