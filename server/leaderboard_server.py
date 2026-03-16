"""
Simple Leaderboard Server for TopDownRPG
=========================================
Run locally:   python leaderboard_server.py
Deploy to:     Render, Railway, Heroku, or any Python host

Endpoints:
  POST /api/submit        — submit/update player score
  GET  /api/leaderboard   — get sorted leaderboard (?weapon=shadow_blade to filter)

Data is stored in leaderboard_data.json next to this script.
"""

from flask import Flask, request, jsonify
from flask_cors import CORS
import json, os, time

app = Flask(__name__)
CORS(app)

DATA_FILE = os.path.join(os.path.dirname(os.path.abspath(__file__)), "leaderboard_data.json")


def _load_data() -> dict:
    if os.path.exists(DATA_FILE):
        with open(DATA_FILE, "r") as f:
            return json.load(f)
    return {}


def _save_data(data: dict):
    with open(DATA_FILE, "w") as f:
        json.dump(data, f, indent=2)


@app.route("/api/submit", methods=["POST"])
def submit_score():
    body = request.get_json(silent=True)
    if not body or "player_id" not in body:
        return jsonify({"error": "missing player_id"}), 400

    player_id = str(body["player_id"])
    data = _load_data()

    data[player_id] = {
        "player_name": str(body.get("player_name", "Unknown"))[:16],
        "total_trophies": max(int(body.get("total_trophies", 0)), 0),
        "weapon_trophies": body.get("weapon_trophies", {}),
        "body_skin": str(body.get("body_skin", "default")),
        "last_seen": int(time.time()),
    }

    _save_data(data)
    return jsonify({"ok": True})


@app.route("/api/leaderboard", methods=["GET"])
def get_leaderboard():
    weapon = request.args.get("weapon", "")
    data = _load_data()

    entries = []
    for pid, pdata in data.items():
        if weapon:
            trophies = int(pdata.get("weapon_trophies", {}).get(weapon, 0))
        else:
            trophies = int(pdata.get("total_trophies", 0))

        entries.append({
            "player_id": pid,
            "player_name": pdata.get("player_name", "Unknown"),
            "trophies": trophies,
            "body_skin": pdata.get("body_skin", "default"),
        })

    # Sort by trophies descending
    entries.sort(key=lambda x: x["trophies"], reverse=True)

    # Return top 100
    return jsonify(entries[:100])


if __name__ == "__main__":
    print("Leaderboard server starting on http://localhost:5000")
    app.run(host="0.0.0.0", port=5000, debug=True)
