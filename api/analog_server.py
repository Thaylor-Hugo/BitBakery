# Server that update sensors values
from flask import Flask, jsonify
from flask_cors import CORS
import threading

# For mock sensors uncoment this line and coment the next one. Also change commented lines on main function
from sensors_mock import mock_loop, sensors
#from analog_service import analog_loop, close_analog, sensors

app = Flask(__name__)
CORS(app)  # Enable CORS


@app.route('/api/sensors')
def get_sensors():
    return jsonify({"sensors": sensors})


if __name__ == '__main__':
    Mock = sensors.values
    mock_thread = threading.Thread(target=mock_loop, daemon=True)
    mock_thread.start()
    app.run(port=5328)

    # Analog sensors values
    # try:
    #     analog_thread = threading.Thread(target=analog_loop, daemon=True)
    #     analog_thread.start()
    #     app.run(port=5328)
    # except KeyboardInterrupt:
    #     pass
    # finally:
    #     close_analog()

   