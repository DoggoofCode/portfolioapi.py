from fastapi import FastAPI
from pydantic import BaseModel
from datetime import datetime
import json as js

app = FastAPI()
try:
    with open("feedback.json", "r") as f:
        json_file = js.load(f)
except Exception:
    with open("feedback.json", "w") as f:
        js.dump({"feedback":[]}, f)
    with open("feedback.json", "r") as f:
        json_file = js.load(f)
    

# Define the packet structure
class Packet(BaseModel):
    message: str
    submittedAt: datetime

    @property
    def serialize(self) -> str:
        return {'message': self.message, 'submittedAt': self.submittedAt.isoformat()}
        
def update_json()->None:
    with open("feedback.json", "w") as f:
        print(json_file)
        js.dump(json_file, f)

@app.post("/api/feedback")
async def receive_feedback(packet: Packet):
    json_file["feedback"].append(packet.serialize)
    update_json()
    return {"status": "success", "received_packet": packet}

@app.get("/api/get_feedback")
async def get_packets():
    return {"packets": json_file}

@app.get("/")
async def root():
    return {"root": "/"}

