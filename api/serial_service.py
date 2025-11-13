
import time
import serial
import copy

# --- Configuration ---
# !!! Replace with your device's port name
# Linux: /dev/ttyUSB0, /dev/ttyACM0, etc.
# Windows: COM3, COM4, etc.
PORT_NAME = '/dev/ttyUSB1'

BAUD_RATE = 115200
DATA_BITS = serial.EIGHTBITS
PARITY = serial.PARITY_EVEN
STOP_BITS = serial.STOPBITS_ONE
# ---------------------

# Data: tres pacotes de 8 bits (3 bytes) = 24 bits
# 0-1: Numero do pacote (2 bits)
# 2-7: dados (5 bits)
# 8-9: paridade e stop bits (2 bits)

sensors = {
    "state": "inicio",
    "minigame": "memorygame",
    "jogada": [False, False, False, False, False, False, False],
    "difficulty": False,
    "player_position": 0,
    "map_obstacles": [[False, False, False, False],[False, False, False, False],[False, False, False, False],[False, False, False, False],[False, False, False, False],[False, False, False, False],[False, False, False, False],[False, False, False, False],[False, False, False, False],[False, False, False, False],[False, False, False, False],[False, False, False, False],[False, False, False, False],[False, False, False, False],[False, False, False, False],[False, False, False, False]]  # 16 obstacles
}

temp_sensors = copy.deepcopy(sensors)

cake_states = ["inicio", "preparation", "show_play", "show_interval", "next_show", "initiate_play", "wait_play", 
                "register_play", "compare_play", "next_play", "start_show", "register_show", "end_state", "Erro", "Erro", "Erro"]

genius_states =["inicial", "preparacao", "proxima_mostra", "espera_jogada", "registra_jogada", "compara_jogada", 
                "proxima_jogada", "foi_ultima_sequencia", "proxima_sequencia", "mostra_jogada", "intervalo_mostra", 
                "inicia_sequencia", "intervalo_rodada", "final_timeout", "final_acertou", "final_errou"]

delivery_states = ["idle", "preparation", "playing", "get_velocity", "game_over"]

minigames = ["memorygame", "cakegame", "deliverygame", "cakegame"]

package_count = 0


def loop():
    global ser  # Global serial object to be accessed in close_serial
    # Connect to the serial port with all parameters
    ser = serial.Serial(
        port=PORT_NAME,
        baudrate=BAUD_RATE,
        bytesize=DATA_BITS,
        parity=PARITY,
        stopbits=STOP_BITS,
        timeout=None
    )
    
    print(f"Listening on {ser.name} at {BAUD_RATE} baud (8E1)...")

    while True:
        # Read one byte of data
        data_byte = ser.read(1)
        if not data_byte:
            continue
        
        int_value = data_byte[0]
        
        if package_count == 0:
            if int_value == 0xff:
                temp_sensors = copy.deepcopy(sensors)
                package_count += 1
            
        elif package_count == 1 or package_count == 2 or package_count == 3:
            package_num = (int_value >> 6) & (0b11)
            if package_num == 0:
                # -- Pacote 1 --
                # 2-3: minigame (2 bits)
                temp_sensors["minigame"] = minigames[(int_value >> 4) & 0b11]
                # 4-7: state (4 bits)
                temp_sensors["state"] = (cake_states if temp_sensors["minigame"] == "cakegame" else (genius_states if temp_sensors["minigame"] == "memorygame" else delivery_states))[(int_value & 0b1111)]
            elif package_num == 1:
                # -- Pacote 2 --
                # 2-7: dados da jogada (6 bits)
                for i in range(6):
                    temp_sensors["jogada"][i] = bool((int_value >> (5 - i)) & 1)
            elif package_num == 2:
                # -- Pacote 3 --
                # 2: dados da jogada (1 bit)
                temp_sensors["jogada"][6] = bool((int_value >> 5) & 1)
                # 3: dificuldade (1 bit)
                temp_sensors["difficulty"] = bool((int_value >> 4) & 1)
                # 4-7: player position (4 bits)
                temp_sensors["player_position"] = (int_value & 0b1111)
            package_count += 1
        elif package_count >= 4 and package_count <= 11:
            obstacle_index = 2 * (package_count - 4)
            for i in range(4):
                temp_sensors["map_obstacles"][obstacle_index][i] = bool((int_value >> i) & 1)
                temp_sensors["map_obstacles"][obstacle_index + 1][i] = bool((int_value >> (4 + i)) & 1)
            package_count += 1
        elif package_count == 12:
            package_count = 0
            if int_value != 0xff:
                continue    # Invalid end byte, ignore
            sensors = temp_sensors


def close_serial():
    # Make sure to close the port when the script is done
    if 'ser' in locals() and ser.is_open:
        ser.close()
        print("Serial port closed.")

