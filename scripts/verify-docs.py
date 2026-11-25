"""Проверяет адреса локальных Markdown-ссылок в документации и правилах."""
from pathlib import Path
import re
import sys
from urllib.parse import unquote, urlsplit

root = Path(__file__).resolve().parents[1]
import subprocess

files = [root / name for name in subprocess.check_output(
    ["git", "ls-files", "-z", "*.md"], cwd=root
).decode().split("\0") if name]
errors = []
for path in files:
    fenced = False
    for number, line in enumerate(path.read_text().splitlines(), 1):
        if line.lstrip().startswith(("```", "~~~")):
            fenced = not fenced
            continue
        if fenced:
            continue
        for destination in re.findall(r"\]\((<[^>]+>|[^)\s]+)\)", line):
            url = urlsplit(destination.strip("<>"))
            if url.scheme or url.netloc or not url.path:
                continue
            target = (path.parent / unquote(url.path)).resolve()
            if not target.is_relative_to(root) or not target.exists():
                errors.append(f"{path.relative_to(root)}:{number}: {destination}")
print("\n".join(errors))
sys.exit(bool(errors))
