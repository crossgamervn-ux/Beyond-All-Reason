import subprocess
import threading
import json
import time
import sys

# Change this to the actual path of your spring executable and start script
SPRING_EXE = "./spring.exe"
START_SCRIPT = "script.txt"

class IoTController:
    def __init__(self):
        self.process = None
        self.telemetry_data = {}
        self.running = True

    def start_engine(self):
        # Start the engine and pipe standard input/output
        # Stderr is piped to stdout to keep logs unified
        self.process = subprocess.Popen(
            [SPRING_EXE, START_SCRIPT],
            stdin=subprocess.PIPE,
            stdout=subprocess.PIPE,
            stderr=subprocess.STDOUT,
            text=True,
            bufsize=1
        )

        # Start a background thread to constantly read engine output
        self.reader_thread = threading.Thread(target=self._read_output, daemon=True)
        self.reader_thread.start()

    def _read_output(self):
        while self.running and self.process.poll() is None:
            line = self.process.stdout.readline()
            if not line:
                break

            line = line.strip()
            # Intercept our custom telemetry prefix
            if "IOT_TELEMETRY:" in line:
                try:
                    # Extract the JSON part of the string
                    json_str = line.split("IOT_TELEMETRY: ")[1]
                    self.telemetry_data = json.loads(json_str)
                    print(f"[Python] Parsed {len(self.telemetry_data)} units from telemetry.")
                except Exception as e:
                    print(f"[Python] Failed to parse telemetry: {e}")
            else:
                # Optional: print standard engine logs
                # print(f"[Engine] {line}")
                pass

    def send_command(self, unit_id, command, x=0, y=0, z=0):
        if self.process and self.process.poll() is None:
            # The engine reads stdin as chat messages.
            # We prefix with "a " (all-chat) to ensure it gets processed by GotChatMsg
            cmd_str = f"a /iot {command} {unit_id} {x} {y} {z}\n"
            self.process.stdin.write(cmd_str)
            self.process.stdin.flush()
            print(f"[Python] Sent command: {cmd_str.strip()}")

    def stop(self):
        self.running = False
        if self.process:
            self.process.terminate()

if __name__ == "__main__":
    controller = IoTController()

    print("Starting engine wrapper...")
    # NOTE: You will need a valid spring.exe and script.txt to run this successfully.
    # controller.start_engine()

    try:
        # Example Loop
        while True:
            # if controller.telemetry_data:
                # Do something with the data, e.g. send to ESP32 via serial/mqtt
                # print(controller.telemetry_data)

                # Example: issue a move command to the first unit we find
                # unit_id = list(controller.telemetry_data.keys())[0]
                # controller.send_command(unit_id, "MOVE", 500, 0, 500)

            time.sleep(2)
            print("Looping... (Engine start is commented out for safety)")

    except KeyboardInterrupt:
        print("Stopping...")
        controller.stop()