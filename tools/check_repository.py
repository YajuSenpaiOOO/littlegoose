"""Read-only repository and literal-resource audit; does not launch Godot."""
from pathlib import Path
import json
import re
import subprocess

ROOT = Path(__file__).resolve().parents[1]

def git(*args):
    return subprocess.check_output(["git", "-C", str(ROOT), *args])

def main():
    actual = Path(git("rev-parse", "--show-toplevel").decode().strip()).resolve()
    assert actual == ROOT, f"Unexpected Git root: {actual}"
    tracked = set(git("ls-files", "-z").decode("utf-8").split("\0")) - {""}
    forbidden = [p for p in tracked if p.startswith((".godot/", "assets/bake84/"))
                 or (p.startswith("docs/") and p.endswith((".png", ".png.import", ".log")))]
    assert not forbidden, f"Generated output staged: {forbidden[:8]}"
    required = ["project.godot", ".gitattributes", ".gitignore", "AGENTS.md",
                "CURRENT_HANDOFF.md", "docs/world-restart-layout.json",
                "scenes/world/world169.tscn", "scenes/world/world204.tscn",
                "native/combat113/combat113.windows.x86_64.dll"]
    assert all(p in tracked for p in required), "Required source/runtime file not tracked"
    # Follow only literal engine-resource references from both actual entries.
    # Dynamic string-built filenames still need normal game validation.
    pending = ["scenes/world/world169.tscn", "scenes/world/world204.tscn"]
    visited, missing, excluded = set(), set(), set()
    literal_load = re.compile(r'(?:preload|load)\s*\(\s*[\"\'](res://[^\"\']+)[\"\']\s*\)')
    literal_link = re.compile(r'(?:extends|path\s*=|#include)\s*[\"\'](res://[^\"\']+)[\"\']')
    while pending:
        relative = pending.pop()
        if relative in visited:
            continue
        visited.add(relative)
        path = ROOT / relative
        if not path.is_file():
            missing.add(relative)
            continue
        if relative not in tracked:
            excluded.add(relative)
        if path.suffix not in {".gd", ".gdshader", ".gdshaderinc", ".tscn", ".tres", ".gdextension"}:
            continue
        source = path.read_text(encoding="utf-8-sig")
        for target in literal_load.findall(source) + literal_link.findall(source):
            if "%" not in target and "{" not in target:
                pending.append(target.removeprefix("res://"))
    result = {"tracked_files": len(tracked), "literal_resource_closure": len(visited),
              "missing_literal_resources": sorted(missing), "untracked_dependencies": sorted(excluded),
              "runtime_validation": "Not run: repository setup must not disturb parallel profiling."}
    print(json.dumps(result, ensure_ascii=False, indent=2))
    return 1 if missing or excluded else 0

if __name__ == "__main__":
    raise SystemExit(main())
