#!/usr/bin/env python3
"""Report donor profile source URL and freshness metadata status.

This is intentionally report-only by default. It gives maintainers a repeatable audit lane without
making normal validation depend on network access or third-party uptime.
"""

from __future__ import annotations

import argparse
import json
import re
import sys
from dataclasses import asdict, dataclass
from datetime import date
from pathlib import Path
from urllib.error import HTTPError, URLError
from urllib.request import Request, urlopen


SOURCE_RE = re.compile(r"^Source:\s+(https?://\S+)\s*$", re.MULTILINE)
LAST_CHECKED_RE = re.compile(r"^(?:Last checked|last_checked):\s*([0-9]{4}-[0-9]{2}-[0-9]{2})\s*$", re.MULTILINE)


@dataclass
class ProfileReport:
    path: str
    source_url: str | None
    last_checked: str | None
    age_days: int | None
    url_status: str | None
    issues: list[str]


def parse_args() -> argparse.Namespace:
    parser = argparse.ArgumentParser(description=__doc__)
    parser.add_argument("donor_library", type=Path, help="Path to references/donor-library")
    parser.add_argument("--max-age-days", type=int, default=180)
    parser.add_argument("--check-urls", action="store_true", help="Probe source URLs with HTTP HEAD/GET.")
    parser.add_argument("--strict-metadata", action="store_true", help="Fail on missing/stale freshness metadata.")
    parser.add_argument("--strict-urls", action="store_true", help="Fail on source URL probe failures.")
    parser.add_argument("--summary-only", action="store_true", help="Only print aggregate counts.")
    parser.add_argument("--json-output", type=Path, default=None)
    return parser.parse_args()


def source_url_status(url: str, timeout: float = 8.0) -> str:
    for method in ("HEAD", "GET"):
        request = Request(url, method=method, headers={"User-Agent": "CppStudio donor freshness audit"})
        try:
            with urlopen(request, timeout=timeout) as response:
                return f"{response.status}"
        except HTTPError as error:
            if method == "HEAD" and error.code in {403, 405}:
                continue
            return f"http-error:{error.code}"
        except URLError as error:
            return f"url-error:{error.reason}"
        except TimeoutError:
            return "timeout"
    return "unknown"


def parse_profile(path: Path, root: Path, today: date, max_age_days: int, check_urls: bool) -> ProfileReport:
    text = path.read_text(encoding="utf-8")
    source_match = SOURCE_RE.search(text)
    checked_match = LAST_CHECKED_RE.search(text)
    source_url = source_match.group(1) if source_match else None
    last_checked = checked_match.group(1) if checked_match else None
    age_days: int | None = None
    issues: list[str] = []

    if source_url is None:
        issues.append("missing_source_url")
    if last_checked is None:
        issues.append("missing_last_checked")
    else:
        try:
            checked_date = date.fromisoformat(last_checked)
            age_days = (today - checked_date).days
            if age_days < 0:
                issues.append("last_checked_in_future")
            elif age_days > max_age_days:
                issues.append("stale_last_checked")
        except ValueError:
            issues.append("invalid_last_checked")

    url_status = source_url_status(source_url) if check_urls and source_url else None
    if url_status and not (url_status.isdigit() and int(url_status) < 400):
        issues.append("source_url_probe_failed")

    return ProfileReport(
        path=path.relative_to(root).as_posix(),
        source_url=source_url,
        last_checked=last_checked,
        age_days=age_days,
        url_status=url_status,
        issues=issues,
    )


def main() -> int:
    args = parse_args()
    donor_root = args.donor_library.resolve()
    profiles_root = donor_root / "profiles"
    if not profiles_root.is_dir():
        print(f"Missing donor profile directory: {profiles_root}", file=sys.stderr)
        return 2

    today = date.today()
    profile_paths = [path for path in sorted(profiles_root.glob("*.md")) if path.name != "README.md"]
    reports = [
        parse_profile(path, donor_root, today, args.max_age_days, args.check_urls)
        for path in profile_paths
    ]
    issue_counts: dict[str, int] = {}
    for report in reports:
        for issue in report.issues:
            issue_counts[issue] = issue_counts.get(issue, 0) + 1

    payload = {
        "schema_version": 1,
        "donor_library": str(donor_root),
        "profile_count": len(reports),
        "issue_counts": issue_counts,
        "reports": [asdict(report) for report in reports],
    }
    if args.json_output is not None:
        args.json_output.parent.mkdir(parents=True, exist_ok=True)
        args.json_output.write_text(json.dumps(payload, indent=2) + "\n", encoding="utf-8")

    print(f"Donor freshness profiles: {len(reports)}")
    if issue_counts:
        for issue, count in sorted(issue_counts.items()):
            print(f"{issue}: {count}")
    else:
        print("No donor freshness issues found")

    if not args.summary_only:
        for report in reports:
            if report.issues:
                print(f"{report.path}: {', '.join(report.issues)}")

    strict_failure = False
    metadata_issues = {"missing_last_checked", "invalid_last_checked", "last_checked_in_future", "stale_last_checked"}
    if args.strict_metadata and any(metadata_issues & set(report.issues) for report in reports):
        strict_failure = True
    if args.strict_urls and any("source_url_probe_failed" in report.issues for report in reports):
        strict_failure = True
    return 1 if strict_failure else 0


if __name__ == "__main__":
    raise SystemExit(main())
