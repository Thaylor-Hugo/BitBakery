import pygame
import threading
import random
import os

sensors = {
    "state": "inicio",
    "minigame": "cakegame",
    "jogada": [False, False, False, False, False, False, False],
    "difficulty": False,
    "player_position": [False, False, False, True],
    "map_obstacles": [[False, False, False, False] for _ in range(16)]  # 16 obstacles
}

cake_states = ["inicio", "preparation", "show_play", "show_interval", "next_show", "initiate_play", "wait_play", 
                "register_play", "compare_play", "next_play", "end_state"]

genius_states =["inicial", "preparacao", "proxima_mostra", "espera_jogada", "registra_jogada", "compara_jogada", 
                "proxima_jogada", "foi_ultima_sequencia", "proxima_sequencia", "mostra_jogada", "intervalo_mostra", 
                "inicia_sequencia", "intervalo_rodada", "final_timeout", "final_acertou", "final_errou"]

delivery_states = ["idle", "preparation", "playing", "playing", "game_over"]

minigames = ["memorygame", "cakegame", "deliverygame"]

inputs = {
    "jogada": [False, False, False, False, False, False, False],
    "minigame": "cakegame",
    "difficulty": False,
    "jogar": False,
    "reset": False,
    "velocidade": 0
}

def mock_loop():
    pygame.init()
    pygame.font.init()
    my_font = pygame.font.SysFont('Helvetica', 20)
    screen = pygame.display.set_mode((550, 400))
    bitbakery_thread = threading.Thread(target=bitbakery, daemon=True)
    bitbakery_thread.start()
    while True:
        handle_pygame_events()
        pygame.display.flip()

        sensors["difficulty"] = inputs["difficulty"]
        
        # Inputs
        in_str = my_font.render("Inputs:", False, (255, 255, 255))
        jogada_in_str = my_font.render("Jogada: {0}".format(str(inputs["jogada"])), False, (255, 255, 255))
        minigame_in_str = my_font.render("Minigame: {0}".format(str(inputs["minigame"])), False, (255, 255, 255))
        dificuldade_in_str = my_font.render("Dificuldade: {0}".format(str(inputs["difficulty"])), False, (255, 255, 255))
        jogar_in_str = my_font.render("Jogar: {0}".format(str(inputs["jogar"])), False, (255, 255, 255))
        velocidade_in_str = my_font.render("Velocidade: {0}".format(str(inputs["velocidade"])), False, (255, 255, 255))

        # Outputs
        out_str = my_font.render("Outputs:", False, (255, 255, 255))
        state_str = my_font.render("State: {0}".format(str(sensors["state"])), False, (255, 255, 255))
        minigame_str = my_font.render("Minigame: {0}".format(str(sensors["minigame"])), False, (255, 255, 255))
        jogada_str = my_font.render("Jogada: {0}".format(str(sensors["jogada"])), False, (255, 255, 255))
        player_pos_str = my_font.render("Player Position: {0}".format(str(sensors["player_position"])), False, (255, 255, 255))
        
        # Tutorial
        tutorial_str = my_font.render("Tutorial: 1-6 buttons | q,w,e minigames | z,x velocity", False, (255, 255, 255))
        tutorial_str2 = my_font.render("m difficulty | j play/pause | r reset", False, (255, 255, 255))
        
        screen.fill((0, 0, 0))
        screen.blit(out_str, (0,0))
        screen.blit(state_str, (0,30))
        screen.blit(minigame_str, (0,60))
        screen.blit(jogada_str, (0,90))
        screen.blit(player_pos_str, (0,120))

        screen.blit(in_str, (0,150))
        screen.blit(jogada_in_str, (0,180))
        screen.blit(minigame_in_str, (0,210))
        screen.blit(dificuldade_in_str, (0,240))
        screen.blit(jogar_in_str, (0,270))
        screen.blit(velocidade_in_str, (0,300))
        screen.blit(tutorial_str, (0,330))
        screen.blit(tutorial_str2, (0,360))
        pygame.time.wait(50)


def bitbakery():
    jogando = False
    camada_counter = 0
    edge_detected = False
    time_counter = 0
    base_speed = 0
    base_speed_counter = 0
    obstacle_count = 0
    while True:
        initial_time = pygame.time.get_ticks()
        if inputs["jogar"]:
            jogando = True
            sensors["state"] = "inicio"

        sensors["minigame"] = inputs["minigame"]
        while jogando:
            if inputs["reset"]: 
                jogando = False
                sensors["state"] = "inicio"
                pygame.time.wait(1)
                break
            if sensors["minigame"] == "cakegame":
                camada_counter, edge_detected, jogando = cake_game(camada_counter, edge_detected, jogando)
            elif sensors["minigame"] == "deliverygame":
                edge_detected, jogando, time_counter, base_speed, base_speed_counter, obstacle_count = delivery_game(edge_detected, jogando, time_counter, base_speed, base_speed_counter, obstacle_count)
            elif sensors["minigame"] == "memorygame":
                jogando = False  # Implement memory game logic here


def delivery_game(edge_detected, jogando, time_counter, base_speed, base_speed_counter, obstacle_count):
    if sensors["state"] == "inicio":
        sensors["state"] = "preparation"
        pygame.time.wait(1)
    elif sensors["state"] == "preparation":
        sensors["map_obstacles"] = [[False, False, False, False] for _ in range(16)]
        base_speed = 0
        base_speed_counter = 0
        time_counter = 0
        obstacle_count = 0
        sensors["player_position"] = [False, False, False, True]
        sensors["state"] = "playing"
        pygame.time.wait(1)
    elif sensors["state"] == "playing":
        sensors["jogada"] = inputs["jogada"]
        if edge_detected:
            if inputs["jogada"].count(True) == 0:
                edge_detected = False
        if (sensors["jogada"][0] or sensors["jogada"][1]) and not edge_detected:
            if sensors["jogada"][0] and not sensors["player_position"][0]:
                for i in range(3):
                    sensors["player_position"][i] = sensors["player_position"][i+1]
                sensors["player_position"][3] = False
            elif sensors["jogada"][1] and not sensors["player_position"][3]:
                for i in range(3,0,-1):
                    sensors["player_position"][i] = sensors["player_position"][i-1]
                sensors["player_position"][0] = False
            edge_detected = True
        time_counter += 1
        base_speed_counter += 1
        if base_speed_counter >= 30000:
            base_speed = max(3, base_speed + 1)
            base_speed_counter = 0
        if time_counter >= get_timer(base_speed):
            obstacle_count += 1
            if obstacle_count == 4:
                set_obstacle = True
                obstacle_count = 0
            else:
                set_obstacle = False
            move_map(set_obstacle)
            time_counter = 0
        for i in range(4):
            if sensors["player_position"][i] and sensors["map_obstacles"][0][i]:
                sensors["state"] = "game_over"
        pygame.time.wait(1)
        pass
    elif sensors["state"] == "game_over":
        jogando = False
        pygame.time.wait(1)
    map_obs = f"""-------------------------------------
    {sensors["map_obstacles"][15]}
    {sensors["map_obstacles"][14]}
    {sensors["map_obstacles"][13]}
    {sensors["map_obstacles"][12]}
    {sensors["map_obstacles"][11]}
    {sensors["map_obstacles"][10]}
    {sensors["map_obstacles"][9]}
    {sensors["map_obstacles"][8]}
    {sensors["map_obstacles"][7]}
    {sensors["map_obstacles"][6]}
    {sensors["map_obstacles"][5]}
    {sensors["map_obstacles"][4]}
    {sensors["map_obstacles"][3]}
    {sensors["map_obstacles"][2]}
    {sensors["map_obstacles"][1]}
    {sensors["map_obstacles"][0]}
    -------------------------------------
    {sensors["player_position"]}
    -------------------------------------"""
    print(map_obs)
    return edge_detected, jogando, time_counter, base_speed, base_speed_counter, obstacle_count


def cake_game(camada_counter, edge_detected, jogando):
    memory = [[True, False, False, False, False, False, False],
        [False, True, False, False, False, False, False],
        [False, False, True, False, False, False, False],
        [False, False, False, True, False, False, False],
        [False, False, False, False, True, False, False],
        [False, False, False, False, False, True, False],
        [False, False, False, False, False, True, False],
        [False, False, False, False, True, False, False],
        [False, False, False, True, False, False, False],
        [False, False, True, False, False, False, False],
        [False, True, False, False, False, False, False],
        [False, False, False, False, True, False, False],
        [False, False, False, True, False, False, False],
        [False, False, True, False, False, False, False],
        [False, True, False, False, False, False, False],
        [True, False, False, False, False, False, False]
    ]
    if sensors["state"] == "inicio":
        sensors["state"] = "preparation"
        sensors["minigame"] = inputs["minigame"]
        pygame.time.wait(1)
    elif sensors["state"] == "preparation":
        sensors["state"] = "show_play"
        camada_counter = 0
        pygame.time.wait(1)
    elif sensors["state"] == "show_play":
        sensors["jogada"] = memory[camada_counter]
        pygame.time.wait(500)
        sensors["state"] = "show_interval"
    elif sensors["state"] == "show_interval":
        sensors["jogada"] = [False, False, False, False, False, False, False]
        pygame.time.wait(500)
        sensors["state"] = "next_show"
    elif sensors["state"] == "next_show":
        camada_counter += 1
        if camada_counter == len(memory):
            sensors["state"] = "initiate_play"
        else:
            sensors["state"] = "show_play"
        pygame.time.wait(1)
    elif sensors["state"] == "initiate_play":
        camada_counter = 0
        sensors["state"] = "wait_play"
        pygame.time.wait(1)
    elif sensors["state"] == "wait_play":
        sensors["jogada"] = inputs["jogada"]
        if edge_detected:
            if inputs["jogada"].count(True) == 0:
                edge_detected = False
        else:
            if inputs["jogada"].count(True) == 1:
                sensors["state"] = "register_play"
                edge_detected = True
        pygame.time.wait(1)
    elif sensors["state"] == "register_play":
        sensors["jogada"] = inputs["jogada"]
        sensors["state"] = "compare_play"
        pygame.time.wait(1)
    elif sensors["state"] == "compare_play":
        sensors["state"] = "next_play"
        pygame.time.wait(1)
    elif sensors["state"] == "next_play":
        camada_counter += 1
        if camada_counter == len(memory):
            sensors["state"] = "end_state"
        else:
            sensors["state"] = "wait_play"
        pygame.time.wait(1)
    elif sensors["state"] == "end_state":
        jogando = False
        pygame.time.wait(1)
    elif sensors["state"] == _:
        sensors["state"] = "inicio"
        pygame.time.wait(1)
    return camada_counter, edge_detected, jogando


def get_timer(base_speed):
    timer = 800  # Default timer
    if base_speed == 0:
        if inputs["velocidade"] == 0:
            timer = 800
        elif inputs["velocidade"] == 1:
            timer = 700
        elif inputs["velocidade"] == 2:
            timer = 600
        elif inputs["velocidade"] == 3:
            timer = 500
    elif base_speed == 1:
        if inputs["velocidade"] == 0:
            timer = 700
        elif inputs["velocidade"] == 1:
            timer = 600
        elif inputs["velocidade"] == 2:
            timer = 500
        elif inputs["velocidade"] == 3:
            timer = 400
    elif base_speed == 2:
        if inputs["velocidade"] == 0:
            timer = 600
        elif inputs["velocidade"] == 1:
            timer = 500
        elif inputs["velocidade"] == 2:
            timer = 400
        elif inputs["velocidade"] == 3:
            timer = 300
    elif base_speed == 3:
        if inputs["velocidade"] == 0:
            timer = 500
        elif inputs["velocidade"] == 1:
            timer = 400
        elif inputs["velocidade"] == 2:
            timer = 300
        elif inputs["velocidade"] == 3:
            timer = 200
    return timer


def move_map(set_obstacle=True):
    if set_obstacle:
        obstacles = random.randint(1, 14)
    else:
        obstacles = 0
    new_obstacle = [bool((obstacles >> i) & 1) for i in range(4)]
    for i in range(15):
        sensors["map_obstacles"][i] = sensors["map_obstacles"][i+1]
    sensors["map_obstacles"][15] = new_obstacle   


def handle_pygame_events():
    for event in pygame.event.get():
        if event.type == pygame.KEYDOWN:
            if event.key == pygame.K_1:
                inputs["jogada"][0] ^= True  # Toggle boolean
            elif event.key == pygame.K_2:
                inputs["jogada"][1] ^= True
            elif event.key == pygame.K_3:
                inputs["jogada"][2] ^= True
            elif event.key == pygame.K_4:
                inputs["jogada"][3] ^= True
            elif event.key == pygame.K_5:
                inputs["jogada"][4] ^= True
            elif event.key == pygame.K_6:
                inputs["jogada"][5] ^= True
            elif event.key == pygame.K_7:
                inputs["jogada"][6] ^= True
            elif event.key == pygame.K_m:
                inputs["difficulty"] = not inputs["difficulty"] 
            elif event.key == pygame.K_j:
                inputs["jogar"] = not inputs["jogar"]
            elif event.key == pygame.K_q:
                inputs["minigame"] = "memorygame"
            elif event.key == pygame.K_w:
                inputs["minigame"] = "cakegame"
            elif event.key == pygame.K_e:
                inputs["minigame"] = "deliverygame"
            elif event.key == pygame.K_z:
                inputs["velocidade"] = max(0, inputs["velocidade"] - 1)
            elif event.key == pygame.K_x:
                inputs["velocidade"] = min(3, inputs["velocidade"] + 1)
            elif event.key == pygame.K_r:
                inputs["reset"] = True
        elif event.type == pygame.KEYUP:
            if event.key == pygame.K_1:
                inputs["jogada"][0] ^= True
            elif event.key == pygame.K_2:
                inputs["jogada"][1] ^= True
            elif event.key == pygame.K_3:    
                inputs["jogada"][2] ^= True
            elif event.key == pygame.K_4:
                inputs["jogada"][3] ^= True
            elif event.key == pygame.K_5:
                inputs["jogada"][4] ^= True
            elif event.key == pygame.K_6:
                inputs["jogada"][5] ^= True
            elif event.key == pygame.K_7:
                inputs["jogada"][6] ^= True
            elif event.key == pygame.K_r:
                inputs["reset"] = False


if __name__ == '__main__':
    mock_loop()
