#!/bin/bash
# setup_neron.sh - Crée Néron v0.1 complet sur Homebox

set -euo pipefail
clear

BASE_DIR="/opt/Labo/Neron"

# --- Couleurs ---
BOLD=$(tput bold)
RESET=$(tput sgr0)
RED=$(tput setaf 1)
GREEN=$(tput setaf 2)
YELLOW=$(tput setaf 3)
BLUE=$(tput setaf 4)
NC=$RESET

slow_echo() {
    local text="$1"
    local delay="${2:-0.01}"
    for ((i=0; i<${#text}; i++)); do
        printf "%s" "${text:$i:1}"
        sleep $delay
    done
    echo
}

# --- Création des dossiers ---
slow_echo "${BLUE}Création de la structure des dossiers...${NC}"
mkdir -p $BASE_DIR/{neron-core,neron-stt,neron-memory,neron-llm}
cd $BASE_DIR

# --- docker-compose.yml ---
slow_echo "${BLUE}Création de docker-compose.yml...${NC}"
cat > docker-compose.yml << 'EOF'
services:

  neron-core:
    build: ./neron-core
    container_name: neron-core
    ports:
      - "8080:8080"
    depends_on:
      - neron-llm
      - neron-stt
      - neron-memory

  neron-llm:
    image: ollama/ollama
    container_name: neron-llm
    volumes:
      - ollama:/root/.ollama
    ports:
      - "11434:11434"

  neron-stt:
    build: ./neron-stt
    container_name: neron-stt
    ports:
      - "8001:8001"

  neron-memory:
    build: ./neron-memory
    container_name: neron-memory
    volumes:
      - memory:/data

volumes:
  ollama:
  memory:
EOF

# --- neron-core ---
slow_echo "${BLUE}Création de neron-core...${NC}"
cat > neron-core/Dockerfile << 'EOF'
FROM python:3.10-slim
WORKDIR /app
COPY requirements.txt .
RUN pip install --no-cache-dir -r requirements.txt
COPY app.py .
EXPOSE 8080
CMD ["uvicorn", "app:app", "--host", "0.0.0.0", "--port", "8080"]
EOF

cat > neron-core/requirements.txt << 'EOF'
fastapi
uvicorn[standard]
requests
EOF

cat > neron-core/app.py << 'EOF'
from fastapi import FastAPI, UploadFile, File
import requests

app = FastAPI()

@app.get("/")
def root():
    return {"message": "Néron v0.1 actif"}

@app.post("/input/audio")
async def audio_input(file: UploadFile = File(...)):
    # Transcription STT
    stt_resp = requests.post(
        "http://neron-stt:8001/transcribe",
        files={"file": file.file}
    ).json()

    text = stt_resp.get("text", "")

    # Passage LLM
    llm_resp = requests.post(
        "http://neron-llm:11434/api/generate",
        json={"prompt": text, "max_tokens": 100}
    ).json()

    response_text = llm_resp.get("response", "")

    # Mémoire
    requests.post(
        "http://neron-memory:8002/store",
        json={"input": text, "response": response_text}
    )

    return {"response": response_text}
EOF

# --- neron-stt ---
slow_echo "${BLUE}Création de neron-stt...${NC}"
cat > neron-stt/Dockerfile << 'EOF'
FROM python:3.10-slim
WORKDIR /app
COPY requirements.txt .
RUN pip install --no-cache-dir -r requirements.txt
COPY app.py .
EXPOSE 8001
CMD ["uvicorn", "app:app", "--host", "0.0.0.0", "--port", "8001"]
EOF

cat > neron-stt/requirements.txt << 'EOF'
fastapi
uvicorn[standard]
whisper
ffmpeg-python
EOF

cat > neron-stt/app.py << 'EOF'
from fastapi import FastAPI, UploadFile, File
import whisper
import uuid
import subprocess
import os

app = FastAPI()
model = whisper.load_model("tiny")

@app.post("/transcribe")
async def transcribe(file: UploadFile = File(...)):
    tmp_path = f"/tmp/{uuid.uuid4()}.webm"
    wav_path = tmp_path.replace(".webm", ".wav")
    with open(tmp_path, "wb") as f:
        f.write(await file.read())
    subprocess.run(["ffmpeg", "-y", "-i", tmp_path, wav_path],
                   stdout=subprocess.DEVNULL, stderr=subprocess.DEVNULL)
    result = model.transcribe(wav_path)
    text = result.get("text", "")
    os.remove(tmp_path)
    os.remove(wav_path)
    return {"text": text}
EOF

# --- neron-memory ---
slow_echo "${BLUE}Création de neron-memory...${NC}"
cat > neron-memory/Dockerfile << 'EOF'
FROM python:3.10-slim
WORKDIR /app
COPY requirements.txt .
RUN pip install --no-cache-dir -r requirements.txt
COPY app.py .
EXPOSE 8002
CMD ["uvicorn", "app:app", "--host", "0.0.0.0", "--port", "8002"]
EOF

cat > neron-memory/requirements.txt << 'EOF'
fastapi
uvicorn[standard]
sqlite-utils
pydantic
EOF

cat > neron-memory/app.py << 'EOF'
from fastapi import FastAPI
from pydantic import BaseModel
import sqlite3

app = FastAPI()
db_path = "/data/memory.db"
conn = sqlite3.connect(db_path)
conn.execute("""CREATE TABLE IF NOT EXISTS memory (
    id INTEGER PRIMARY KEY AUTOINCREMENT,
    input TEXT,
    response TEXT
)""")
conn.commit()
conn.close()

class MemoryItem(BaseModel):
    input: str
    response: str

@app.post("/store")
def store(item: MemoryItem):
    conn = sqlite3.connect(db_path)
    conn.execute("INSERT INTO memory (input,response) VALUES (?,?)",
                 (item.input, item.response))
    conn.commit()
    conn.close()
    return {"status": "ok"}
EOF

# --- neron-llm placeholder ---
slow_echo "${BLUE}Création du dossier neron-llm...${NC}"
echo "# Placez ici votre conteneur Ollama ou Mistral" > neron-llm/README.md

# --- Script start_neron.sh ---
slow_echo "${BLUE}Création du script start_neron.sh...${NC}"
cat > start_neron.sh << 'EOF'
#!/bin/bash
set -euo pipefail
clear
BOLD=$(tput bold)
RESET=$(tput sgr0)
RED=$(tput setaf 1)
GREEN=$(tput setaf 2)
BLUE=$(tput setaf 4)
NC=$RESET

slow_echo() { local text="$1"; local delay="${2:-0.01}"; for ((i=0;i<${#text};i++)); do printf "%s" "${text:$i:1}"; sleep $delay; done; echo; }
check_docker() { command -v docker >/dev/null 2>&1 || { echo -e "${RED}Docker non installé${NC}"; exit 1; } }
show_status() { echo -e "${BLUE}--- Services Néron v0.1 ---${NC}"; docker-compose ps; echo -e "${BLUE}Core: http://localhost:8080${NC}"; echo -e "${BLUE}STT: http://localhost:8001${NC}"; echo -e "${BLUE}Memory: http://localhost:8002${NC}"; echo -e "${BLUE}LLM: http://localhost:11434${NC}"; }

slow_echo "${BLUE}Vérification Docker...${NC}"; check_docker; slow_echo "${GREEN}Docker OK${NC}"
slow_echo "${BLUE}Lancement des conteneurs...${NC}"; docker-compose up --build -d
slow_echo "${GREEN}Tous les services lancés!${NC}"; show_status
EOF

chmod +x start_neron.sh

slow_echo "${GREEN}Néron v0.1 créé avec succès dans ${BASE_DIR}!${NC}"
slow_echo "${YELLOW}Lance ./start_neron.sh pour démarrer Néron.${NC}"
