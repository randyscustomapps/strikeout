#!/usr/bin/env python3
"""Fill ios/ExportOptions.plist placeholders. Used by the signed workflow only."""
import pathlib
import sys

team, profile, dest = sys.argv[1:]
root = pathlib.Path(__file__).resolve().parents[1]
text = (root / "ExportOptions.plist").read_text(encoding="utf-8")
text = text.replace("__TEAM_ID__", team).replace("__PROFILE_NAME__", profile)
pathlib.Path(dest).write_text(text, encoding="utf-8")
