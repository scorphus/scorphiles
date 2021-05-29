#!/usr/bin/env python
import os
import sys
from datetime import datetime
from pathlib import Path
from shutil import rmtree
from signal import SIGINT, signal
from threading import Timer, get_ident

import ffmpeg
from pyautogui import screenshot
from typer import Argument, Option, Typer, echo

app = Typer()
should_stop = False
threads = {}

TIMELAPSE_HOME = Path(
    os.environ.get("DV_TIMELAPSE_HOME", Path.home() / ".dv_timelapse")
)


def capture_recursive(path, interval):
    global should_stop, threads
    if not should_stop:
        thread = Timer(interval, capture_recursive, [path, interval])
        thread.start()
        threads[thread.ident] = thread
        filename = datetime.now().strftime("%Y%m%d_%H%M%S_%f.png")
        try:
            screenshot(path / filename)
            echo(f"Captured {filename}")
        except OSError:
            (path / filename).unlink(missing_ok=True)
        finally:
            threads.pop(get_ident(), None)
            sys.exit()


@app.command()
def record(
    project: str = Argument(..., help="Name of the project."),
    interval: float = Option(
        1, "--interval", "-i", help="Interval between each screenshot."
    ),
    reset: bool = Option(
        False,
        "--reset",
        "-r",
        help="Reset project folder, i.e. remove old screenshots.",
    ),
):
    frames_path = TIMELAPSE_HOME / project / "frames"

    if reset and frames_path.exists():
        rmtree(frames_path)
    frames_path.mkdir(parents=True, exist_ok=True)

    capture_recursive(frames_path, interval)


@app.command()
def output(
    project: str = Argument(..., help="Name of the project."),
    video_path: Path = Argument(
        Path.cwd(),
        help="Path for timelapse video.",
        show_default="Current working directory",
    ),
    fps: int = Option(30, "--fps", "-f", help="Framerate of the output video."),
    clean: bool = Option(False, "--clean", "-c", help="Clean the screenshots folder."),
):
    frames_path = TIMELAPSE_HOME / project / "frames"
    if not frames_path.exists():
        echo("Please record some frames for the project first!")
        return

    video_path.mkdir(parents=True, exist_ok=True)

    ffmpeg.input(str(frames_path / "*.png"), pattern_type="glob", framerate=fps).output(
        str(video_path / f"{project}.mp4"), vcodec="libx264"
    ).run()

    if clean:
        rmtree(frames_path)


def stop_recording(*args):
    global should_stop, threads
    should_stop = True
    echo("Stopping Recording...")
    for thread in threads.values():
        if thread.is_alive():
            thread.cancel()


if __name__ == "__main__":
    signal(SIGINT, stop_recording)
    app()
