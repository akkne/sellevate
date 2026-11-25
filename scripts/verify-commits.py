"""Проверка сообщений коммитов между двумя ревизиями Git."""
import re
import subprocess
import sys

base, head = sys.argv[1:]
pattern = re.compile(r"(?:feat|fix|docs|style|refactor|perf|test|build|ci|chore|revert)(?:\([\w./-]+\))?!?: \S[^\n]*")
for commit in subprocess.check_output(["git", "rev-list", f"{base}..{head}"], text=True).splitlines():
    message = subprocess.check_output(["git", "log", "-1", "--format=%B", commit], text=True).strip()
    if not pattern.fullmatch(message) or len(message) > 100 or re.search(r"co-authored-by|generated (?:with|by)|🤖", message, re.I):
        sys.exit(f"{commit}: нужен короткий заголовок Conventional Commits без подписи или описания")
