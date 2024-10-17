# godot-python-opencv
Use Godot, OpenCV, and PyInstaller to display the webcam video in a Godot Scene.

## Project Creation (Historical)
1. Open the root folder using [VS Code](https://code.visualstudio.com/)
    - If you use GitHub Desktop, select the "Open in Visual Studio" button
1. Open the [integrated terminal](https://code.visualstudio.com/docs/editor/integrated-terminal)
1. To create a [virtual environment](https://docs.python.org/3/library/venv.html), run `python -m venv venv`
    1. This creates a folder called "venv" that contains a local copy of Python and its package manager, "pip".
1. To activate the virtual environment, run
    - [macOS] `source venv/bin/activate`
    - [Windows] `venv\Scripts\activate`
1. To install required packages, run `pip install opencv-python websockets numpy pyinstaller`
1. Verify package installation by running `pip list`
1. To exit the venv, run `deactivate`

## Testing the Webcam
1. Run the webcam software, `python webcam_server.py`
1. Start the Godot Scene. It should connect.

## Packaging the Python Webcam Code for Godot
[PyInstaller](https://pyinstaller.org/en/stable/) bundles a Python application and all its dependencies into a single package. The user can run the packaged app without installing a Python interpreter or any modules. PyInstaller is tested against Windows, MacOS X, and Linux. However, it is not a cross-compiler; to make a Windows app you run PyInstaller on Windows, and to make a Linux app you run it on Linux. etc.
1. Run `pyinstaller --onefile --noconsole webcam_server.py`
    - This will create a dist folder containing the executable.
