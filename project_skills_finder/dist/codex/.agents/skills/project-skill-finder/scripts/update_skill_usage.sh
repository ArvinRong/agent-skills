#!/usr/bin/env sh
set -eu

repo_root="."
skills_dir=""
skill_id=""
file_name=""
result="used"
notes=""
no_report=0
reason_args=""

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
    --skill-id)
      skill_id=$2
      shift 2
      ;;
    --file)
      file_name=$2
      shift 2
      ;;
    --result)
      result=$2
      shift 2
      ;;
    --reason)
      reason_args="${reason_args}${reason_args:+
}$2"
      shift 2
      ;;
    --notes)
      notes=$2
      shift 2
      ;;
    --no-report)
      no_report=1
      shift
      ;;
    *)
      echo "Unknown argument: $1" >&2
      exit 1
      ;;
  esac
done

if [ -z "$skill_id" ] || [ -z "$file_name" ]; then
  echo "--skill-id and --file are required" >&2
  exit 1
fi

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

if [ ! -f "$usage_path" ]; then
  echo "Usage file not found: $usage_path" >&2
  exit 1
fi

if ! command -v perl >/dev/null 2>&1; then
  echo "perl is required to update $usage_path" >&2
  exit 1
fi

REASON_ARGS="$reason_args" NOTES_VALUE="$notes" perl - "$usage_path" "$skill_id" "$file_name" "$result" <<'PERL'
use strict;
use warnings;
use JSON::PP qw(decode_json);
use POSIX qw(strftime);

my ($usage_path, $skill_id, $file_name, $result) = @ARGV;

open my $fh, '<:encoding(UTF-8)', $usage_path or die "Cannot open $usage_path: $!";
local $/;
my $json_text = <$fh>;
close $fh;

my $data = decode_json($json_text);
$data->{skills} ||= [];
$data->{recommended_reason_labels} ||= [];

my ($entry) = grep { ($_->{skill_id} // '') eq $skill_id } @{ $data->{skills} };
if (!$entry) {
    $entry = {
        skill_id => $skill_id,
        file => $file_name,
        used_count => 0,
        helpful_count => 0,
        not_useful_count => 0,
        not_useful_reasons => [],
        last_used_at => undef,
        notes => '',
    };
    push @{ $data->{skills} }, $entry;
}

$entry->{file} ||= $file_name;
$entry->{used_count} = ($entry->{used_count} // 0) + 1;
if ($result eq 'helpful') {
    $entry->{helpful_count} = ($entry->{helpful_count} // 0) + 1;
} elsif ($result eq 'not-useful') {
    $entry->{not_useful_count} = ($entry->{not_useful_count} // 0) + 1;
    my @reasons = grep { length $_ } split /\n/, ($ENV{REASON_ARGS} // '');
    my %seen = map { $_ => 1 } @{ $entry->{not_useful_reasons} || [] };
    push @{ $entry->{not_useful_reasons} }, grep { !$seen{$_}++ } @reasons;
}

$entry->{last_used_at} = strftime('%Y-%m-%d %H:%M:%S', localtime);
if (exists $ENV{NOTES_VALUE}) {
    $entry->{notes} = $ENV{NOTES_VALUE};
}

open my $out, '>:encoding(UTF-8)', $usage_path or die "Cannot write $usage_path: $!";
print {$out} JSON::PP->new->ascii(0)->pretty(1)->canonical(0)->encode($data);
close $out;
PERL

echo "Updated $usage_path"
if [ "$no_report" -eq 0 ]; then
  script_dir=$(CDPATH= cd -- "$(dirname "$0")" && pwd)
  sh "$script_dir/sync_skill_usage_report.sh" --skills-dir "$skills_dir"
fi
