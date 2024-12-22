from fastapi import FastAPI
from datetime import datetime

app = FastAPI()

@app.get("/current_time")
async def get_current_time():
     current_time = datetime.now().time().isoformat(timespec='seconds')
     return{"current_time": current_time}