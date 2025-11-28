
import time
import serial
import copy

# --- Configuration ---
# !!! Replace with your device's port name
# Linux: /dev/ttyUSB0, /dev/ttyACM0, etc.
# Windows: COM3, COM4, etc.
PORT_NAME = '/dev/ttyUSB0'

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
    "player_position": [False, False, False, True],
    "map_obstacles": [[False, False, False, False] for _ in range(128)],  # 128 rows for delivery game
    "map_objectives": [[False, False, False, False] for _ in range(128)]  # 128 rows for delivery game
}

cake_states = ["inicio", "preparation", "show_play", "show_interval", "next_show", "initiate_play", "wait_play", 
                "register_play", "compare_play", "next_play", "start_show", "register_show", "end_state", "Erro", "Erro", "Erro"]

genius_states =["inicial", "preparacao", "proxima_mostra", "espera_jogada", "registra_jogada", "compara_jogada", 
                "proxima_jogada", "foi_ultima_sequencia", "proxima_sequencia", "mostra_jogada", "intervalo_mostra", 
                "inicia_sequencia", "intervalo_rodada", "final_timeout", "final_acertou", "final_errou"]

# second playing state is from "get_valocity", but since it is not used in the game logic, we can map it to "playing"
delivery_states = ["inicio", "preparation", "playing", "playing", "playing", "game_over", "playing"]

minigames = ["memorygame", "cakegame", "deliverygame", "cakegame"]


def loop():
    global sensors  # Declare sensors as global
    package_count = 0
    global ser  # Global serial object to be accessed in close_serial
    # Connect to the serial port with all parameters
    ser = serial.Serial(
        port=PORT_NAME,
        baudrate=BAUD_RATE,
        bytesize=DATA_BITS,
        parity=PARITY,
        stopbits=STOP_BITS,
        timeout=1  # Add timeout to prevent blocking forever
    )
    
    # Flush any stale data in the buffer
    ser.reset_input_buffer()
    ser.reset_output_buffer()
    
    print(f"Listening on {ser.name} at {BAUD_RATE} baud (8E1)...")
    
    last_byte_time = time.time()
    PACKET_TIMEOUT = 2  # If no complete packet in 2 seconds, reset

    while True:
        # Read one byte of data
        data_byte = ser.read(1)
        if not data_byte:
            # Check if we've been waiting too long in the middle of a packet
            if package_count > 0 and (time.time() - last_byte_time) > PACKET_TIMEOUT:
                print(f"  -> TIMEOUT: Incomplete packet (stuck at package {package_count}), resetting")
                package_count = 0
            # Timeout is normal - FPGA may not be sending continuously
            # Don't spam the console, just continue waiting
            continue
        
        last_byte_time = time.time()
        int_value = data_byte[0]
        # print(f"Package {package_count}: Received 0x{int_value:02X} ({int_value:08b})")
        
        if package_count == 0:
            if int_value == 0xff:
                package_count += 1
                # print("  -> Start byte detected")
            else:
                # print(f"  -> Waiting for start byte (0xFF), got 0x{int_value:02X}")
                pass
            
        elif package_count == 1 or package_count == 2 or package_count == 3:
            package_num = (int_value >> 6) & (0b11)
            if package_num == 0:
                # -- Pacote 1 --
                # 2-3: minigame (2 bits)
                sensors["minigame"] = minigames[(int_value >> 4) & 0b11]
                # 4-7: state (4 bits)
                sensors["state"] = (cake_states if sensors["minigame"] == "cakegame" else (genius_states if sensors["minigame"] == "memorygame" else delivery_states))[(int_value & 0b1111)]
            elif package_num == 1:
                # print(f"Processing package {package_count} with value {int_value:08b} ({int_value})")  # Debug
                # -- Pacote 2 --
                # 2-7: dados da jogada (6 bits)
                for i in range(5, -1, -1):
                    # print(f"Bit {i} of jogada: {bool((int_value >> (i)) & 1)}")  # Debug
                    sensors["jogada"][i] = bool((int_value >> (i)) & 1)
            elif package_num == 2:
                # -- Pacote 3 --
                # 2: dados da jogada (1 bit)
                sensors["jogada"][6] = bool((int_value >> 5) & 1)
                # 3: dificuldade (1 bit)
                sensors["difficulty"] = bool((int_value >> 4) & 1)
                # 4-7: player position (4 bits)
                sensors["player_position"] = [bool((int_value >> i) & 1) for i in range(4)]
            package_count += 1
        elif package_count >= 4 and package_count <= 67:
            # 64 bytes of obstacle map data (packages 4-67)
            # Each byte contains 2 rows of 4 bits each
            obstacle_index = 2 * (package_count - 4)
            for i in range(4):
                sensors["map_obstacles"][obstacle_index][i] = bool((int_value >> i) & 1)
                sensors["map_obstacles"][obstacle_index + 1][i] = bool((int_value >> (4 + i)) & 1)
            package_count += 1
        elif package_count >= 68 and package_count <= 131:
            # 64 bytes of objective map data (packages 68-131)
            # Each byte contains 2 rows of 4 bits each
            objective_index = 2 * (package_count - 68)
            for i in range(4):
                sensors["map_objectives"][objective_index][i] = bool((int_value >> i) & 1)
                sensors["map_objectives"][objective_index + 1][i] = bool((int_value >> (4 + i)) & 1)
            package_count += 1
        elif package_count == 132:
            if int_value == 0xfe:
                # print("  -> End byte detected (0xFE), updating sensors")
                package_count = 0
            else:
                # print(f"  -> ERROR: Expected end byte (0xFE), got 0x{int_value:02X} - Resetting")
                package_count = 0  # Reset and wait for next valid start byte
        
        else:
            # print(f"  -> ERROR: Invalid package_count {package_count} - Resetting")
            package_count = 0
        se = f'''
        dificuldade: {sensors["difficulty"]}
        state: {sensors["state"]}
        minigame: {sensors["minigame"]}
        jogada: {sensors["jogada"]}
        '''
        # mapa: {sensors["map_obstacles"]}
        # player_position: {sensors["player_position"]}
        # print(se)

def close_serial():
    # Make sure to close the port when the script is done
    if 'ser' in locals() and ser.is_open:
        ser.close()
        print("Serial port closed.")

