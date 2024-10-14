from fastapi import FastAPI, HTTPException
from fastapi.responses import FileResponse
import os

app = FastAPI()

# Path to the base directory where your static files are stored
static_dir = "/srv/"

@app.get("/srv/{file_path:path}")
async def serve_static_file(file_path: str):
    # Construct the full path to the file in /srv/
    full_path = os.path.join(static_dir, file_path)

    # Check if the file exists and is a file
    if os.path.exists(full_path) and os.path.isfile(full_path):
        return FileResponse(full_path)
    else:
        raise HTTPException(status_code=404, detail=f"File '{full_path}' not found")

# Example usage
# Start FastAPI server with `uvicorn` (e.g. uvicorn filename:app --reload)

