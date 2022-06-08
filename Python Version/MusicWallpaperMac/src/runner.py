import subprocess
from pathlib import Path

path = Path(__file__).parent
subprocess.check_call([str(path/ '.venv/bin/python'), str(path / 'main.py')])

