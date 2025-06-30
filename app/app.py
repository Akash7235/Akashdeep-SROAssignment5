from flask import Flask, jsonify, request
import time

app = Flask(__name__)

# Simulated database
database_data = [
    {"id": 1, "name": "Apple"},
    {"id": 2, "name": "Orange"},
    {"id": 3, "name": "Pineapple"}
]

cache = None
cache_timestamp = 0
CACHE_TTL = 30  # seconds

def is_cache_valid():
    return cache is not None and (time.time() - cache_timestamp) < CACHE_TTL

@app.route('/data', methods=['GET'])
def get_data():
    global cache, cache_timestamp
    start = time.time()

    if is_cache_valid():
        source = "cache"
        data = cache
    else:
        source = "database"
        data = database_data
        cache = data
        cache_timestamp = time.time()

    duration = time.time() - start
    return jsonify({
        "source": source,
        "data": data,
        "response_time_seconds": duration
    })

@app.route('/invalidate', methods=['POST'])
def invalidate_cache():
    global cache, cache_timestamp
    cache = None
    cache_timestamp = 0
    return jsonify({"message": "Cache invalidated"})

@app.route('/update', methods=['POST'])
def update_data():
    global database_data, cache, cache_timestamp
    new_item = request.json
    database_data.append(new_item)
    cache = None
    cache_timestamp = 0
    return jsonify({"message": "Database updated, cache invalidated"})

if __name__ == '__main__':
    app.run(host='0.0.0.0', port=5000)