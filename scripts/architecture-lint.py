"""Проверяет зависимости проектов и исходники контрактов до сборки .NET."""
from pathlib import Path
import re
import sys
from xml.etree import ElementTree

from lib_csharp_source import iterate_code_lines

ROOT = Path(__file__).resolve().parents[1] / "backend"
LAYERS = {"Abstract", "Contracts", "Domain", "Application"}
FORBIDDEN = re.compile(
    r"\b(?:Microsoft\.(?:AspNetCore|EntityFrameworkCore)|Npgsql|MongoDB\.Driver|"
    r"StackExchange\.Redis|Confluent\.Kafka|Amazon\.S3|"
    r"Sellevate\.\w+\.(?:[\w.]+\.)?(?:Infrastructure|Implementation|Endpoints))\b"
)


def violations():
    for project in sorted(ROOT.glob("*/*/*.csproj")):
        for item in ElementTree.parse(project).iter("ProjectReference"):
            target = (project.parent / item.attrib["Include"].replace("\\", "/")).resolve()
            if not target.is_file() or not target.is_relative_to(ROOT / "building-blocks"):
                yield f"{project}: недопустимая зависимость {target}"

    for path in sorted(ROOT.rglob("*.cs")):
        parts = path.relative_to(ROOT).parts
        if {"obj", "bin", "Migrations"}.intersection(parts) or not LAYERS.intersection(parts[:-1]):
            continue
        for line, code in iterate_code_lines(path.read_text()):
            if match := FORBIDDEN.search(code):
                yield f"{path}:{line}: контракт зависит от {match[0]}"


if __name__ == "__main__":
    errors = list(violations())
    for error in errors:
        print(error, file=sys.stderr)
    sys.exit(bool(errors))
