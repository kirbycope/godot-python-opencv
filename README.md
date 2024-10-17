# godot-python-opencv
Use Godot, OpenCV, and PyInstaller to display the webcam video in a Godot Scene.

## Technologies Used
[Godot](https://godotengine.org/) is a cross-platform, free and open-source game engine released under the permissive MIT license. </br>
[OpenCV](https://opencv.org/) (Open Source Computer Vision Library) is a library of programming functions mainly for real-time computer vision. </br>
[PyInstaller](https://pyinstaller.org/en/stable/) bundles a Python application and all its dependencies into a single package.

## Running the Godot Application
1. Clone _this_ repo.
1. Import [project.godot](project.godot) using Godot
1. Edit the project
    1. Or, skip the next step and press "Run" instead
1. Press "Run Project (F5)"

## Testing the Webcam Server
When you make changes to the Python script, you'll need to tell the Godot application not to start the webcam server.
1. To activate the virtual environment, run
    - [macOS] `source venv/bin/activate`
    - [Windows] `venv\Scripts\activate`
1. Run the webcam software, `python webcam_server.py`
1. Edit the GDScript so that it doesn't try to start the server by commenting out `webcam_server_start()`
1. Start the scene (see _"Testing the Webcam Server"_, above)
    - The scene should connect automatically; when `_ready()` calls `webcam_server_connect()`
1. To exit the server, press [Ctrl]+[C]
1. To exit the virtual environment, run `deactivate`

## Packaging the Python Webcam Server for Godot
[PyInstaller](https://pyinstaller.org/en/stable/) bundles a Python application and all its dependencies into a single package. The user can run the packaged app without installing a Python interpreter or any modules. PyInstaller is tested against Windows, MacOS X, and Linux. However, it is not a cross-compiler; to make a Windows app you run PyInstaller on Windows, and to make a Linux app you run it on Linux. etc. **NOTE:** Whenever you make changes to the Python code, you must regenerate this executable.
1. Run `pyinstaller --onefile --noconsole webcam_server.py`
    - This will create a dist folder containing the executable.
    - The executeable is called in `webcam_server_start()` of [texture_rect.gd](texture_rect.gd)
----

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
