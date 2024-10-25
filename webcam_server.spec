# -*- mode: python ; coding: utf-8 -*-


a = Analysis(
    ['webcam_server.py'],
    pathex=[],
    binaries=[],
    datas=[
        ('venv/Lib/site-packages/mediapipe/modules/pose_landmark/pose_landmark_cpu.binarypb', 'mediapipe/modules/pose_landmark'),
        ('venv/Lib/site-packages/mediapipe/modules/pose_detection/pose_detection.tflite', 'mediapipe/modules/pose_detection'),
        ('venv/Lib/site-packages/mediapipe/modules/pose_landmark/pose_landmark_full.tflite', 'mediapipe/modules/pose_landmark'),
    ],
    hiddenimports=[],
    hookspath=[],
    hooksconfig={},
    runtime_hooks=[],
    excludes=[],
    noarchive=False,
    optimize=0,
)
pyz = PYZ(a.pure)

exe = EXE(
    pyz,
    a.scripts,
    a.binaries,
    a.datas,
    [],
    name='webcam_server',
    debug=False,
    bootloader_ignore_signals=False,
    strip=False,
    upx=True,
    upx_exclude=[],
    runtime_tmpdir=None,
    console=False,
    disable_windowed_traceback=False,
    argv_emulation=False,
    target_arch=None,
    codesign_identity=None,
    entitlements_file=None,
)
