#!/usr/bin/env python3
import argparse
import json
import sys
from pathlib import Path

COLORS_DIR = Path(__file__).resolve().parents[4] / "Rail" / "Assets.xcassets" / "Colors"
INFO = {"author": "xcode", "version": 1}


def components(value: str) -> dict:
    digits = value.removeprefix("#").upper()
    if len(digits) not in (6, 8) or any(c not in "0123456789ABCDEF" for c in digits):
        sys.exit(f"Color no válido: {value}. Usa RRGGBB o RRGGBBAA, como lo devuelve Figma.")
    alpha = int(digits[6:8], 16) / 255 if len(digits) == 8 else 1
    return {
        "alpha": f"{alpha:.3f}",
        "blue": f"0x{digits[4:6]}",
        "green": f"0x{digits[2:4]}",
        "red": f"0x{digits[0:2]}",
    }


def write_json(path: Path, data: dict) -> None:
    path.write_text(json.dumps(data, indent=2) + "\n")


def main() -> None:
    parser = argparse.ArgumentParser(
        description="Crea un color set Light/Dark en Assets.xcassets/Colors/<Grupo>/<nombre>.colorset",
    )
    parser.add_argument("group", help="Carpeta del grupo, p. ej. Brand, Glass, Fill")
    parser.add_argument("name", help="Nombre del símbolo, p. ej. brandTintFill (codeSyntax iOS sin 'Color.')")
    parser.add_argument("light", help="Valor Light en hex: RRGGBB o RRGGBBAA")
    parser.add_argument("dark", nargs="?", help="Valor Dark en hex; si falta se usa el Light")
    parser.add_argument("--force", action="store_true", help="Sobrescribe un color set existente")
    args = parser.parse_args()

    light = components(args.light)
    dark = components(args.dark or args.light)
    group_dir = COLORS_DIR / args.group
    colorset = group_dir / f"{args.name}.colorset"
    existing = list(COLORS_DIR.glob(f"*/{args.name}.colorset"))
    if existing and not args.force:
        sys.exit(f"Ya existe {existing[0].relative_to(COLORS_DIR.parent)}. Usa --force para sobrescribirlo.")

    if not group_dir.exists():
        group_dir.mkdir(parents=True)
        write_json(group_dir / "Contents.json", {"info": INFO})
    colorset.mkdir(exist_ok=True)

    write_json(colorset / "Contents.json", {
        "colors": [
            {"color": {"color-space": "srgb", "components": light}, "idiom": "universal"},
            {
                "appearances": [{"appearance": "luminosity", "value": "dark"}],
                "color": {"color-space": "srgb", "components": dark},
                "idiom": "universal",
            },
        ],
        "info": INFO,
    })
    print(f"Creado {colorset.relative_to(COLORS_DIR.parent)} → Color.{args.name}")


if __name__ == "__main__":
    main()
