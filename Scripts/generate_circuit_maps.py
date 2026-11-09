#!/usr/bin/env python3
"""Generates CircuitMaps SVGs from the f1-circuits GeoJSON repository.

Usage: generate_circuit_maps.py <path-to-f1-circuits> [output-dir]
"""
import json
import math
import sys
from pathlib import Path

CIRCUIT_IDS = {
    "albert_park": "au-1953",
    "shanghai": "cn-2004",
    "suzuka": "jp-1962",
    "miami": "us-2022",
    "villeneuve": "ca-1978",
    "monaco": "mc-1929",
    "catalunya": "es-1991",
    "red_bull_ring": "at-1969",
    "silverstone": "gb-1948",
    "spa": "be-1925",
    "hungaroring": "hu-1986",
    "zandvoort": "nl-1948",
    "monza": "it-1922",
    "madring": "es-2026",
    "baku": "az-2016",
    "sepang": "my-1999",
    "marina_bay": "sg-2008",
    "americas": "us-2012",
    "rodriguez": "mx-1962",
    "interlagos": "br-1940",
    "vegas": "us-2023",
    "losail": "qa-2004",
    "yas_marina": "ae-2009",
}

SIZE = 100.0
PADDING = 4.0
STROKE_WIDTH = 2.4

DEFAULT_OUTPUT = (
    Path(__file__).resolve().parent.parent
    / "Packages/F1Core/Sources/F1Core/Resources/CircuitMaps"
)


def lines(geometry):
    if geometry["type"] == "LineString":
        return [geometry["coordinates"]]
    if geometry["type"] == "MultiLineString":
        return geometry["coordinates"]
    raise ValueError(f"Unsupported geometry {geometry['type']}")


def build_svg(geojson):
    paths = [line for feature in geojson["features"] for line in lines(feature["geometry"])]
    points = [p for line in paths for p in line]
    mean_lat = sum(p[1] for p in points) / len(points)
    scale_x = math.cos(math.radians(mean_lat))

    xs = [p[0] * scale_x for p in points]
    ys = [-p[1] for p in points]
    min_x, min_y = min(xs), min(ys)
    span = max(max(xs) - min_x, max(ys) - min_y)
    factor = (SIZE - 2 * PADDING) / span
    width = (max(xs) - min_x) * factor + 2 * PADDING
    height = (max(ys) - min_y) * factor + 2 * PADDING

    def project(p):
        x = (p[0] * scale_x - min_x) * factor + PADDING
        y = (-p[1] - min_y) * factor + PADDING
        return f"{x:.2f} {y:.2f}"

    d = " ".join("M" + " L".join(project(p) for p in line) for line in paths)
    return (
        f'<svg xmlns="http://www.w3.org/2000/svg" viewBox="0 0 {width:.2f} {height:.2f}" '
        f'width="{width:.2f}" height="{height:.2f}">\n'
        f'  <path d="{d}" fill="none" stroke="black" stroke-width="{STROKE_WIDTH}" '
        f'stroke-linecap="round" stroke-linejoin="round"/>\n'
        f"</svg>\n"
    )


def main():
    source = Path(sys.argv[1])
    output = Path(sys.argv[2]) if len(sys.argv) > 2 else DEFAULT_OUTPUT
    output.mkdir(parents=True, exist_ok=True)
    for circuit_id, geo_id in CIRCUIT_IDS.items():
        geojson = json.loads((source / "circuits" / f"{geo_id}.geojson").read_text())
        (output / f"{circuit_id}.svg").write_text(build_svg(geojson))
        print(f"{circuit_id} <- {geo_id}")


if __name__ == "__main__":
    main()
