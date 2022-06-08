import numpy as np
from sklearn.cluster import KMeans
from PIL import Image
from pathlib import Path
from time import sleep
import subprocess
from rumps import App
from threading import Thread
import binascii
import re
import io


def main():
    app_status = app_status_checker(reset_desktop=True)
    default_wallpaper = Path("/Users/aaryamansmacbook/Documents/My Desktop/Wallpapers/Desktop Wallpaper.jpg")
    buffer = 1
    path = Path(__file__).parent
    previous_album = ""

    while True:
        x_res, y_res = 2560, 1600  # screen resolution
        output_size = (800, 800)  # how many pixels should the artwork take in the final image
        try:
            artwork, previous_album = get_artwork(previous_album, app_status)
            app_status.app_running = True
            app_status.app_closed = False
        except ValueError:
            sleep(1)
            continue
        except ConnectionError:
            if app_status.reset_desktop:
                set_desktop(default_wallpaper)
            sleep(1)
            continue

        buffer = 1 ^ buffer
        # xor with 1 basically switches 0 to 1 and 1 to 0
        # mac doesn't recognize updating the tmp file to change desktop. So we have to switch between tmp0 and tmp1,
        # everytime the program runs. The buffer is just a store that switches between 0 and 1.

        art_work_path = path / f'images/tmp{buffer}.png'
        color = tuple(dominant_color_k_means(artwork))

        resized = artwork.resize(output_size)
        final = Image.new('RGB', (x_res, y_res), color)
        final.paste(resized, ((x_res - output_size[0]) // 2,
                              (y_res - output_size[1]) // 2))

        final.save(art_work_path)
        set_desktop(art_work_path)

    return 0


def get_artwork(previous_album, app_status):
    pattern = re.compile('«data JPEG(.*)»|«data tdta(.*)»')
    get_art_script = str(Path(__file__).parent / 'Applescripts/get_art.applescript')
    process = subprocess.run(['osascript', get_art_script], capture_output=True)

    if process.stdout.decode("utf-8").strip() == '1':
        if not app_status.app_running:
            raise ValueError("Music app not open")
        else:
            app_status.app_closed = True
            app_status.app_running = False
            raise ConnectionError("App closed by user")

    if process.stdout is None:
        raise ValueError("No Music Playing")

    raw_output, album_name = (process.stdout.decode("utf-8").split(',', 1))
    hex_repr = re.search(pattern, raw_output)

    if not hex_repr:
        raise ValueError("Invalid Cover Art")
    if album_name == previous_album:
        raise ValueError("Same as previous album. No need to waste time")

    image = Image.open(io.BytesIO(binascii.unhexlify(hex_repr.group(1))))
    return image, album_name


def set_desktop(art_work_path):
    command = 'tell application "System Events" to set picture of current desktop to "{path_here}"'
    command = command.replace("{path_here}", f'{art_work_path}')
    subprocess.run(['osascript', "-e", command])


def dominant_color_k_means(image):
    image = image.resize((100, 100))
    width, height = image.size
    reshape = np.array(image).reshape((width * height, 3))
    # reshapes into a list of pixels, where each pixel is a list of 3 elements (r,g,b)

    cluster = KMeans(n_clusters=5).fit(reshape)
    # clusters the pixels into 3D space to find most dominant rgb color vectors

    labels = cluster.labels_
    # array of labels from 0 to 4. For example, if 10 data points fit in the 4th cluster, there will be 10 4s in the
    # array

    labels, counts = (lambda x, y: (list(x), list(y)))(*np.unique(labels[labels >= 0], return_counts=True))
    # make labels array unique, and stores count of each label in a separate array at same index

    dominant_color_index = labels[counts.index(max(counts))]
    # Find the index which corresponds to the highest count. Then find the label with that index

    dominant_color = cluster.cluster_centers_[dominant_color_index]
    # find cluster center with label corresponding to the highest count
    return [round(x) for x in dominant_color]


class app_status_checker:
    def __init__(self, reset_desktop=True):
        self.app_closed_by_user = False
        self.app_running = False
        self.reset_desktop = reset_desktop


if __name__ == "__main__":
    t = Thread(target=main)
    t.start()
    app = App('Music Wallpaper App', title='🎷', menu=['Music Wallpaper'])
    app.run()
