#!/usr/bin/env sh
set -eu

repo_root="."
skills_dir=""

while [ "$#" -gt 0 ]; do
  case "$1" in
    --repo-root)
      repo_root=$2
      shift 2
      ;;
    --skills-dir)
      skills_dir=$2
      shift 2
      ;;
    *)
      echo "Unknown argument: $1" >&2
      exit 1
      ;;
  esac
done

if [ -z "$skills_dir" ]; then
  if [ -d "$repo_root/docs/skills" ]; then
    skills_dir="$repo_root/docs/skills"
  elif [ -d "$repo_root/skills" ]; then
    skills_dir="$repo_root/skills"
  else
    echo "Could not find docs/skills or skills under $repo_root" >&2
    exit 1
  fi
fi

usage_path="$skills_dir/SKILL_USAGE.json"
report_path="$skills_dir/SKILL_USAGE.md"

if [ ! -f "$usage_path" ]; then
  echo "Usage file not found: $usage_path" >&2
  exit 1
fi

if ! command -v perl >/dev/null 2>&1; then
  echo "perl is required to render $report_path" >&2
  exit 1
fi

perl - "$usage_path" "$report_path" <<'PERL'
use strict;
use warnings;
use JSON::PP qw(decode_json);

my ($usage_path, $report_path) = @ARGV;

open my $fh, '<:encoding(UTF-8)', $usage_path or die "Cannot open $usage_path: $!";
local $/;
my $json_text = <$fh>;
close $fh;

my $data = decode_json($json_text);
$data->{skills} ||= [];
$data->{recommended_reason_labels} ||= [];

open my $report, '>:encoding(UTF-8)', $report_path or die "Cannot write $report_path: $!";
print {$report} "# Skill Usage\n\n";
print {$report} "This Markdown file is an optional human-readable report derived from `SKILL_USAGE.json`.\n\n";
print {$report} "Prefer `SKILL_USAGE.json` as the structured source of truth for updates and automation. Regenerate this file after updating the JSON data.\n\n";
print {$report} "| Skill ID | File | used_count | helpful_count | not_useful_count | not_useful_reasons | last_used_at | notes |\n";
print {$report} "|---|---|---:|---:|---:|---|---|---|\n";
for my $item (@{ $data->{skills} }) {
    my $reasons = (@{ $item->{not_useful_reasons} || [] }) ? join(',', @{ $item->{not_useful_reasons} }) : '-';
    my $last_used_at = $item->{last_used_at} // '-';
    my $notes = $item->{notes};
    $notes = '-' if !defined($notes) || $notes eq '';
    $notes =~ s/\R/ /g;
    print {$report} sprintf("| `%s` | `%s` | %d | %d | %d | %s | %s | %s |\n",
        $item->{skill_id} // '-',
        $item->{file} // '-',
        $item->{used_count} // 0,
        $item->{helpful_count} // 0,
        $item->{not_useful_count} // 0,
        $reasons,
        $last_used_at,
        $notes,
    );
}
print {$report} "\n## Recommended reason labels\n\n";
for my $label (@{ $data->{recommended_reason_labels} || [] }) {
    print {$report} "- `$label`\n";
}
close $report;
PERL

echo "Refreshed $report_path"
