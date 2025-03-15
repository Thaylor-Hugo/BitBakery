# Server that update sensors values
from flask import Flask, jsonify
from flask_cors import CORS
import pygame
import threading
from analog_service import analog_loop, sensors, states, minigames
app = Flask(__name__)
CORS(app)  # Enable CORS


def pygame_loop():
    pygame.init()
    pygame.font.init()
    my_font = pygame.font.SysFont('Helvetica', 20)
    screen = pygame.display.set_mode((400, 100))
    while True:
        handle_pygame_events()
        pygame.display.flip()
        state_str = my_font.render("State: {0}".format(str(sensors["state"])), False, (255, 255, 255))
        minigame_str = my_font.render("Minigame: {0}".format(str(sensors["minigame"])), False, (255, 255, 255))
        leds_str = my_font.render("Leds: {0}".format(str(sensors["leds"])), False, (255, 255, 255))
        screen.fill((0, 0, 0))
        screen.blit(state_str, (0,0))
        screen.blit(minigame_str, (0,30))
        screen.blit(leds_str, (0,60))
        pygame.time.wait(50)


def handle_pygame_events():
    for event in pygame.event.get():
        if event.type == pygame.KEYDOWN:
            if event.key == pygame.K_1:
                sensors["leds"][0] ^= True  # Toggle boolean
            elif event.key == pygame.K_2:
                sensors["leds"][1] ^= True
            elif event.key == pygame.K_3:
                sensors["leds"][2] ^= True
            elif event.key == pygame.K_4:
                sensors["leds"][3] ^= True
            elif event.key == pygame.K_5:
                sensors["leds"][4] ^= True
            elif event.key == pygame.K_b:
                sensors["minigame"] = minigames[0]
            elif event.key == pygame.K_n:
                sensors["minigame"] = minigames[1]
            elif event.key == pygame.K_m:
                sensors["minigame"] = minigames[2]
            elif event.key == pygame.K_q:
                sensors["state"] = states[0]
            elif event.key == pygame.K_w:
                sensors["state"] = states[1]
            elif event.key == pygame.K_e:
                sensors["state"] = states[2]
            elif event.key == pygame.K_r:
                sensors["state"] = states[3]
            elif event.key == pygame.K_t:
                sensors["state"] = states[4]
            elif event.key == pygame.K_y:
                sensors["state"] = states[5]


@app.route('/api/sensors')
def get_sensors():
    return jsonify({"sensors": sensors})


if __name__ == '__main__':
    # Mock sensors values
    # pygame_thread = threading.Thread(target=pygame_loop, daemon=True)
    # pygame_thread.start()

    analog_thread = threading.Thread(target=analog_loop, daemon=True)
    analog_thread.start()

    # Start Flask server
    app.run(port=5328)
   