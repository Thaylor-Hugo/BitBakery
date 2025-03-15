import pygame

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


def mock_loop():
    pygame.init()
    pygame.font.init()
    my_font = pygame.font.SysFont('Helvetica', 20)
    screen = pygame.display.set_mode((550, 120))
    while True:
        handle_pygame_events()
        pygame.display.flip()
        state_str = my_font.render("State: {0}".format(str(sensors["state"])), False, (255, 255, 255))
        minigame_str = my_font.render("Minigame: {0}".format(str(sensors["minigame"])), False, (255, 255, 255))
        jogada_str = my_font.render("Jogada: {0}".format(str(sensors["jogada"])), False, (255, 255, 255))
        pontuacao_str = my_font.render("Pontuacao: {0}".format(str(sensors["pontuacao"])), False, (255, 255, 255))
        screen.fill((0, 0, 0))
        screen.blit(state_str, (0,0))
        screen.blit(minigame_str, (0,30))
        screen.blit(jogada_str, (0,60))
        screen.blit(pontuacao_str, (0,90))
        pygame.time.wait(50)


def handle_pygame_events():
    for event in pygame.event.get():
        if event.type == pygame.KEYDOWN:
            if event.key == pygame.K_1:
                sensors["jogada"][0] ^= True  # Toggle boolean
            elif event.key == pygame.K_2:
                sensors["jogada"][1] ^= True
            elif event.key == pygame.K_3:
                sensors["jogada"][2] ^= True
            elif event.key == pygame.K_4:
                sensors["jogada"][3] ^= True
            elif event.key == pygame.K_5:
                sensors["jogada"][4] ^= True
            elif event.key == pygame.K_6:
                sensors["jogada"][5] ^= True
            elif event.key == pygame.K_7:
                sensors["jogada"][6] ^= True
            elif event.key == pygame.K_b:
                sensors["minigame"] = minigames[0]
            elif event.key == pygame.K_n:
                sensors["minigame"] = minigames[1]
            elif event.key == pygame.K_m:
                sensors["minigame"] = minigames[2]
            elif event.key == pygame.K_q:
                if (sensors["minigame"] == "cakegame"):
                    sensors["state"] = cake_states[0]
                elif (sensors["minigame"] == "memorygame"):
                    sensors["state"] = genius_states[0]
            elif event.key == pygame.K_w:
                if (sensors["minigame"] == "cakegame"):
                    sensors["state"] = cake_states[1]
                elif (sensors["minigame"] == "memorygame"):
                    sensors["state"] = genius_states[1]
            elif event.key == pygame.K_e:
                if (sensors["minigame"] == "cakegame"):
                    sensors["state"] = cake_states[2]
                elif (sensors["minigame"] == "memorygame"):
                    sensors["state"] = genius_states[2]
            elif event.key == pygame.K_r:
                if (sensors["minigame"] == "cakegame"):
                    sensors["state"] = cake_states[3]
                elif (sensors["minigame"] == "memorygame"):
                    sensors["state"] = genius_states[3]
            elif event.key == pygame.K_t:
                if (sensors["minigame"] == "cakegame"):
                    sensors["state"] = cake_states[4]
                elif (sensors["minigame"] == "memorygame"):
                    sensors["state"] = genius_states[4]
            elif event.key == pygame.K_y:
                if (sensors["minigame"] == "cakegame"):
                    sensors["state"] = cake_states[5]
                elif (sensors["minigame"] == "memorygame"):
                    sensors["state"] = genius_states[5]
            elif event.key == pygame.K_u:
                if (sensors["minigame"] == "cakegame"):
                    sensors["state"] = cake_states[6]
                elif (sensors["minigame"] == "memorygame"):
                    sensors["state"] = genius_states[6]
            elif event.key == pygame.K_i:
                if (sensors["minigame"] == "cakegame"):
                    sensors["state"] = cake_states[7]
                elif (sensors["minigame"] == "memorygame"):
                    sensors["state"] = genius_states[7]
            elif event.key == pygame.K_o:
                if (sensors["minigame"] == "cakegame"):
                    sensors["state"] = cake_states[8]
                elif (sensors["minigame"] == "memorygame"):
                    sensors["state"] = genius_states[8]
            elif event.key == pygame.K_p:
                if (sensors["minigame"] == "cakegame"):
                    sensors["state"] = cake_states[9]
                elif (sensors["minigame"] == "memorygame"):
                    sensors["state"] = genius_states[9]
            elif event.key == pygame.K_a:
                if (sensors["minigame"] == "cakegame"):
                    sensors["state"] = cake_states[10]
                elif (sensors["minigame"] == "memorygame"):
                    sensors["state"] = genius_states[10]
            elif event.key == pygame.K_s:
                if (sensors["minigame"] == "memorygame"):
                    sensors["state"] = genius_states[11]
            elif event.key == pygame.K_d:
                if (sensors["minigame"] == "memorygame"):
                    sensors["state"] = genius_states[12]
            elif event.key == pygame.K_f:
                if (sensors["minigame"] == "memorygame"):
                    sensors["state"] = genius_states[13]
            elif event.key == pygame.K_g:
                if (sensors["minigame"] == "memorygame"):
                    sensors["state"] = genius_states[14]
            elif event.key == pygame.K_h:
                if (sensors["minigame"] == "memorygame"):
                    sensors["state"] = genius_states[15]
            elif event.key == pygame.K_z:
                sensors["pontuacao"] += 1
            elif event.key == pygame.K_x:
                sensors["pontuacao"] -= 1

