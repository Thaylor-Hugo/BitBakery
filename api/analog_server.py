# Server that update sensors values
from flask import Flask, jsonify
from flask_cors import CORS
import threading

# For mock sensors uncoment this line and coment the next one. Also change commented lines on main function
# from sensors_mock import mock_loop, sensors
from analog_service import analog_loop, sensors, states, minigames

app = Flask(__name__)
CORS(app)  # Enable CORS


@app.route('/api/sensors')
def get_sensors():
    return jsonify({"sensors": sensors})


if __name__ == '__main__':
    # Mock sensors values
    # mock_thread = threading.Thread(target=mock_loop, daemon=True)
    # mock_thread.start()

    # Analog sensors values
    analog_thread = threading.Thread(target=analog_loop, daemon=True)
    analog_thread.start()

    # Start Flask server
    app.run(port=5328)
   