#Install the requirements and start the FastAPI server
cd "$(dirname "${BASH_SOURCE[0]}")"
sudo apt install pkg-config libmysqlclient-dev python3-dev build-essential -y
python3 -m venv .venv/
source .venv/bin/activate
pip install -r requirements.txt
uvicorn earthquake_ml_api:app