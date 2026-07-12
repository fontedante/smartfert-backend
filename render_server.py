import time
import requests
import joblib
import pandas as pd
import threading
from flask import Flask, jsonify
import os

app = Flask(__name__)

# --- URL & API Constants ---
FIREBASE_URL = "https://pioneerspalm-78855-default-rtdb.firebaseio.com/soil_monitoring/realtime.json"
LATITUDE = -6.6839
LONGITUDE = 107.7253
OPEN_METEO_URL = (
    f"https://api.open-meteo.com/v1/forecast"
    f"?latitude={LATITUDE}&longitude={LONGITUDE}"
    f"&current=precipitation,weather_code,temperature_2m,relative_humidity_2m"
    f"&daily=precipitation_sum,precipitation_probability_max"
    f"&timezone=Asia/Jakarta"
    f"&past_days=3"
    f"&forecast_days=1"
)

WEATHER_DESCRIPTIONS = {
    0: "Cerah ☀️", 1: "Sebagian Cerah 🌤️", 2: "Berawan Sebagian ⛅",
    3: "Mendung ☁️", 45: "Berkabut 🌫️", 48: "Kabut Tebal 🌫️",
    51: "Gerimis Ringan 🌦️", 53: "Gerimis Sedang 🌦️", 55: "Gerimis Lebat 🌧️",
    61: "Hujan Ringan 🌧️", 63: "Hujan Sedang 🌧️", 65: "Hujan Lebat 🌧️",
    80: "Hujan Sebentar 🌦️", 81: "Hujan Sedang 🌦️", 82: "Hujan Lebat ⛈️",
    95: "Badai Petir ⛈️", 96: "Badai + Hujan Es ⛈️", 99: "Badai Besar ⛈️",
}

def get_weather_data():
    try:
        resp = requests.get(OPEN_METEO_URL, timeout=10)
        resp.raise_for_status()
        weather = resp.json()
        current = weather.get('current', {})
        daily = weather.get('daily', {})

        daily_precip = daily.get('precipitation_sum', [0.0])
        daily_forecast_mm = daily_precip[-1] if len(daily_precip) > 0 else 0.0
        hujan_3hari_terakhir = sum(daily_precip[:-1]) if len(daily_precip) > 1 else 0.0

        return {
            'hujan_3hari_terakhir': float(hujan_3hari_terakhir),
            'weather_desc': WEATHER_DESCRIPTIONS.get(current.get('weather_code', 0), "Tidak diketahui"),
            'temperature': current.get('temperature_2m', None),
            'daily_forecast_mm': float(daily_forecast_mm),
            'rain_probability': daily.get('precipitation_probability_max', [0])[-1],
        }
    except Exception as e:
        print(f"[!] Gagal mengambil data cuaca: {e}")
        return None

# --- Background AI Polling Loop ---
def run_ai_loop():
    try:
        model = joblib.load('gb_model_v3.pkl')
        print("=> AI Model Loaded Successfully in Background Thread!")
    except Exception as e:
        print(f"=> Fatal Error loading model: {e}")
        return

    last_timestamp = None

    while True:
        try:
            response = requests.get(FIREBASE_URL)
            data = response.json()

            if data and 'timestamp' in data:
                current_timestamp = data['timestamp']

                if current_timestamp != last_timestamp:
                    print(f"\n[+] NEW DATA DETECTED: {current_timestamp}")
                    
                    weather = get_weather_data()
                    hujan_3hari = weather['hujan_3hari_terakhir'] if weather else 0.0
                    days_since = int(data.get('days_since_last_fert', 104))
                    
                    input_data = pd.DataFrame([{
                        'ec': float(data.get('ec', 1.0)),
                        'moisture': float(data.get('moisture', 50.0)),
                        'ph': float(data.get('ph', 5.5)),
                        'hari sejak terakhir pemupukan': days_since
                    }])

                    prediction = model.predict(input_data)
                    dosis = max(0.0, round(float(prediction[0]), 2))

                    print(f"    AI Predicted Dose: {dosis} grams")

                    update_data = {
                        "ml_fertilizer_dose_grams": dosis,
                        "weather_hujan_3hari_mm": hujan_3hari,
                        "weather_description": weather['weather_desc'] if weather else "Tidak tersedia",
                        "weather_daily_forecast_mm": weather['daily_forecast_mm'] if weather else 0,
                        "weather_rain_probability": weather['rain_probability'] if weather else 0,
                    }
                    requests.patch(FIREBASE_URL, json=update_data)
                    print("    [V] Saved to Firebase!")

                    last_timestamp = current_timestamp

            time.sleep(3)
        except Exception as e:
            print(f"Connection glitch: {e}")
            time.sleep(5)


# Start the AI loop immediately when the module loads
# (This ensures it runs even when deployed under Gunicorn)
ai_thread = threading.Thread(target=run_ai_loop, daemon=True)
ai_thread.start()

# --- Flask Web Server ---
@app.route('/')
def home():
    return jsonify({
        "status": "online",
        "service": "SmartFert AI Backend",
        "message": "The AI is secretly polling Firebase in the background! 🤫"
    })

if __name__ == '__main__':
    port = int(os.environ.get("PORT", 10000))
    app.run(host='0.0.0.0', port=port)
