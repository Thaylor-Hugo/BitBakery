import pygame
import threading

sensors = {
    "state": "inicio",
    "minigame": "memorygame",
    "jogada": [False, False, False, False, False, False, False],
    "pontuacao": 0,
}

cake_states = ["inicio", "preparation", "show_play", "show_interval", "next_show", "initiate_play", "wait_play", 
                "register_play", "compare_play", "next_play", "end_state"]

genius_states =["inicial", "preparacao", "proxima_mostra", "espera_jogada", "registra_jogada", "compara_jogada", 
                "proxima_jogada", "foi_ultima_sequencia", "proxima_sequencia", "mostra_jogada", "intervalo_mostra", 
                "inicia_sequencia", "intervalo_rodada", "final_timeout", "final_acertou", "final_errou"]

minigames = ["memorygame", "cakegame", "clothesgame"]

inputs = {
    "jogada": [False, False, False, False, False, False, False],
    "minigame": "memorygame",
    "dificuldade": False,
    "jogar": False
}

def mock_loop():
    pygame.init()
    pygame.font.init()
    my_font = pygame.font.SysFont('Helvetica', 20)
    screen = pygame.display.set_mode((550, 300))
    bitbakery_thread = threading.Thread(target=bitbakery, daemon=True)
    bitbakery_thread.start()
    while True:
        handle_pygame_events()
        pygame.display.flip()
        
        # Inputs
        in_str = my_font.render("Inputs:", False, (255, 255, 255))
        jogada_in_str = my_font.render("Jogada: {0}".format(str(inputs["jogada"])), False, (255, 255, 255))
        minigame_in_str = my_font.render("Minigame: {0}".format(str(inputs["minigame"])), False, (255, 255, 255))
        dificuldade_in_str = my_font.render("Dificuldade: {0}".format(str(inputs["dificuldade"])), False, (255, 255, 255))
        jogar_in_str = my_font.render("Jogar: {0}".format(str(inputs["jogar"])), False, (255, 255, 255))

        # Outputs
        out_str = my_font.render("Outputs:", False, (255, 255, 255))
        state_str = my_font.render("State: {0}".format(str(sensors["state"])), False, (255, 255, 255))
        minigame_str = my_font.render("Minigame: {0}".format(str(sensors["minigame"])), False, (255, 255, 255))
        jogada_str = my_font.render("Jogada: {0}".format(str(sensors["jogada"])), False, (255, 255, 255))
        pontuacao_str = my_font.render("Pontuacao: {0}".format(str(sensors["pontuacao"])), False, (255, 255, 255))
        
        screen.fill((0, 0, 0))
        screen.blit(out_str, (0,0))
        screen.blit(state_str, (0,30))
        screen.blit(minigame_str, (0,60))
        screen.blit(jogada_str, (0,90))
        screen.blit(pontuacao_str, (0,120))

        screen.blit(in_str, (0,150))
        screen.blit(jogada_in_str, (0,180))
        screen.blit(minigame_in_str, (0,210))
        screen.blit(dificuldade_in_str, (0,240))
        screen.blit(jogar_in_str, (0,270))
        pygame.time.wait(50)


def bitbakery():
    memory = [[True, False, False, False, False, False, False],
                [False, True, False, False, False, False, False],
                [False, False, True, False, False, False, False],
                [False, False, False, True, False, False, False],
                [False, False, False, False, True, False, False],
                [False, False, False, False, False, True, False],
                [False, False, False, False, False, False, True]]
    jogando = False
    dificuldade = False
    camada_counter = 0
    edge_detected = False
    jogada = [False, False, False, False, False, False, False]
    while True:
        initial_time = pygame.time.get_ticks()
        if inputs["jogar"]:
            jogando = True
            sensors["state"] = "inicio"

        while jogando:
            match sensors["state"]:
                case "inicio":
                    sensors["state"] = "preparation"
                    sensors["pontuacao"] = 0
                    sensors["minigame"] = inputs["minigame"]
                    pygame.time.wait(1)
                    break
                case "preparation":
                    sensors["state"] = "show_play"
                    dificuldade = inputs["dificuldade"]
                    camada_counter = 0
                    pygame.time.wait(1)
                    break
                case "show_play":
                    sensors["jogada"] = memory[camada_counter]
                    pygame.time.wait(500)
                    sensors["state"] = "show_interval"
                    break
                case "show_interval":
                    sensors["jogada"] = [False, False, False, False, False, False, False]
                    pygame.time.wait(500)
                    sensors["state"] = "next_show"
                    break
                case "next_show":
                    camada_counter += 1
                    if camada_counter == len(memory):
                        sensors["state"] = "initiate_play"
                    else:
                        sensors["state"] = "show_play"
                    pygame.time.wait(1)
                    break
                case "initiate_play":
                    camada_counter = 0
                    sensors["state"] = "wait_play"
                    pygame.time.wait(1)
                    break
                case "wait_play":
                    sensors["jogada"] = inputs["jogada"]
                    if edge_detected:
                        if inputs["jogada"].count(True) == 0:
                            edge_detected = False
                    else:
                        if inputs["jogada"].count(True) == 1:
                            sensors["state"] = "register_play"
                            edge_detected = True
                    pygame.time.wait(1)
                    break
                case "register_play":
                    jogada = inputs["jogada"]
                    sensors["jogada"] = inputs["jogada"]
                    sensors["state"] = "compare_play"
                    pygame.time.wait(1)
                    break
                case "compare_play":
                    if jogada == memory[camada_counter]:
                        sensors["pontuacao"] += 1
                    
                    sensors["state"] = "next_play"
                    pygame.time.wait(1)
                    break
                case "next_play":
                    camada_counter += 1
                    if camada_counter == len(memory):
                        sensors["state"] = "end_state"
                    else:
                        sensors["state"] = "wait_play"
                    pygame.time.wait(1)
                    break
                case "end_state":
                    jogando = False
                    pygame.time.wait(1)
                    break
                case _:
                    sensors["state"] = "inicio"
                    pygame.time.wait(1)
                    break


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
                inputs["dificuldade"] = not inputs["dificuldade"] 
            elif event.key == pygame.K_j:
                inputs["jogar"] = not inputs["jogar"]
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

if __name__ == '__main__':
    mock_loop()