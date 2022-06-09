# Building Instructions for Python

Copy-paste the following commands into the terminal while in your directory of choice:

```
git clone https://github.com/Aaryaman-1409/MusicWallpaperMac/
cd "MusicWallpaperMac/Python Version/MusicWallpaperMac/src"
python3 -m venv .venv
source .venv/bin/activate
pip install -r requirements.txt
```

After this is done, to build into a portable .app copy-paste the following into terminal:

```
python3 setup.py py2app
open dist
```

The main.app file inside can then be moved around and run at any time. You can even delete the entire MusicWallpaperMac after the compilation, since the main.app file is entirely self-contained. 


If you don't want to build, you can also just directly run the script file by typing 
```python3 path/to/runner.py```
into the terminal.  It may take 10-15 secs for the program to resolve dependenices during the first run. On subsequent runs however, the program should start immediately. 


