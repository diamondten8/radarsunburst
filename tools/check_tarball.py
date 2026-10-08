"""Check an unchanged release tarball; keep logs, SHA-256 and structured evidence."""
import argparse
import datetime
import hashlib
import json
import pathlib
import re
import shutil
import subprocess
import tempfile

parser = argparse.ArgumentParser(description=__doc__)
parser.add_argument("tarball", type=pathlib.Path)
parser.add_argument("--output", required=True, type=pathlib.Path)
parser.add_argument("--r", required=True)
args = parser.parse_args()
original = args.tarball.resolve(strict=True)
args.output.mkdir(parents=True, exist_ok=True)
run = pathlib.Path(tempfile.mkdtemp(prefix="artifact-", dir=args.output.resolve()))
tarball = run / original.name
shutil.copy2(original, tarball)
sha256 = hashlib.sha256(tarball.read_bytes()).hexdigest()
started = datetime.datetime.now(datetime.timezone.utc).isoformat()
command = [args.r, "CMD", "check", "--as-cran", str(tarball)]
with (run / "check-console.log").open("w", encoding="utf-8") as output:
    result = subprocess.run(command, cwd=run, stdout=output, stderr=subprocess.STDOUT)
logs = list(run.glob("*.Rcheck/00check.log"))
log = logs[0] if len(logs) == 1 else None
content = log.read_text(encoding="utf-8", errors="replace") if log else ""
counts = {kind: len(re.findall(r"\.\.\. (?:\[[^\n]*?\] )?" + kind + r"\b", content))
          for kind in ("ERROR", "WARNING", "NOTE")}
if not log or "* DONE" not in content:
    counts["ERROR"] += 1
version_match = re.search(r"^\* using R (.+)$", content, re.MULTILINE)
version = "R " + version_match.group(1) if version_match else "unavailable"
record = dict(mode="full-as-cran", started_utc=started, r_version=version,
              original_tarball=str(original), tarball=str(tarball), sha256=sha256,
              commands=[command], check_exit_code=result.returncode,
              check_log=str(log) if log else None, counts=counts,
              finished_utc=datetime.datetime.now(datetime.timezone.utc).isoformat())
(run / "summary.json").write_text(json.dumps(record, indent=2) + "\n", encoding="utf-8")
print(json.dumps(record, indent=2))
raise SystemExit(1 if result.returncode or any(counts.values()) else 0)
