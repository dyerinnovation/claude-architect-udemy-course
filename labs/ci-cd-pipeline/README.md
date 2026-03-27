# Scenario Lab: CI/CD Pipeline Integration

## Overview

In this lab, you will integrate Claude Code into a continuous integration/continuous delivery (CI/CD) pipeline. You will configure Claude to run automated code analysis on new commits, output structured JSON findings with a defined schema, handle deduplication when re-running after new commits, and use CLAUDE.md for test generation context. This lab demonstrates how to scale Claude's capabilities into production workflows.

**Key Architecture Pattern:** CI/CD integration, structured output, JSON schema validation, deduplication strategies.

---

## Learning Objectives

By completing this lab, you will demonstrate the ability to:

1. **Run Claude Code with the -p flag** in a simulated CI job to process commits programmatically
2. **Output structured JSON findings** with a defined schema using --output-format json
3. **Design deduplication logic** to avoid reporting the same issue twice when re-running on overlapping commits
4. **Configure CLAUDE.md context** for test generation and validation in CI
5. **Parse and handle JSON schema validation** in CI environments
6. **Design idempotent, safe CI operations** that don't modify code without explicit approval
7. **Handle failures gracefully** in automated pipelines

**Exam Connections:** Domain 3 (Configuration & Team Workflows), Domain 4 (Prompt Engineering & Outputs)

---

## Prerequisites

### Tools & APIs
- **Claude Code** CLI installed
- **Docker** or **GitHub Actions** / **GitLab CI** / **Jenkins** for CI environment simulation
- **Python 3.8+** or **Node.js** for post-processing scripts
- **Git** repository with commit history

### Knowledge
- Understanding of CI/CD basics (pipelines, workflows, commits)
- Familiarity with Claude Code command-line flags (Module 3)
- Understanding of JSON schema and structured outputs

### Setup
```bash
# Install Claude Code
curl https://claude.com/install | bash

# Verify installation
claude --version

# Set API key for CI environment
export CLAUDE_API_KEY="your-api-key"

# Clone/navigate to a test project
git clone <repo> test-ci-project
cd test-ci-project
```

---

## Step-by-Step Instructions

### Step 1: Design JSON Schema for CI Output

Create a schema that defines how Claude Code reports findings to the CI pipeline.

**File: `.claude/ci-schema.json`**

```json
{
  "$schema": "http://json-schema.org/draft-07/schema#",
  "title": "Claude Code CI Analysis Report",
  "type": "object",
  "properties": {
    "metadata": {
      "type": "object",
      "properties": {
        "analysis_id": {
          "type": "string",
          "description": "Unique ID for this analysis (use git commit SHA)"
        },
        "timestamp": {
          "type": "string",
          "format": "date-time",
          "description": "ISO 8601 timestamp of analysis"
        },
        "commit_sha": {
          "type": "string",
          "description": "Git commit SHA being analyzed"
        },
        "branch": {
          "type": "string",
          "description": "Git branch name"
        },
        "files_analyzed": {
          "type": "integer",
          "description": "Number of files analyzed"
        }
      },
      "required": ["analysis_id", "timestamp", "commit_sha", "branch"]
    },
    "summary": {
      "type": "object",
      "properties": {
        "total_issues": {
          "type": "integer"
        },
        "critical": {
          "type": "integer"
        },
        "high": {
          "type": "integer"
        },
        "medium": {
          "type": "integer"
        },
        "low": {
          "type": "integer"
        },
        "analysis_passed": {
          "type": "boolean",
          "description": "true if no critical/high issues, false otherwise"
        }
      },
      "required": ["total_issues", "analysis_passed"]
    },
    "findings": {
      "type": "array",
      "items": {
        "type": "object",
        "properties": {
          "finding_id": {
            "type": "string",
            "description": "Unique ID: hash(file + line + rule)"
          },
          "file": {
            "type": "string",
            "description": "File path relative to repo root"
          },
          "line": {
            "type": "integer",
            "description": "Line number (0 if file-level)"
          },
          "column": {
            "type": "integer",
            "description": "Column number (optional)"
          },
          "severity": {
            "type": "string",
            "enum": ["critical", "high", "medium", "low"],
            "description": "Issue severity"
          },
          "rule": {
            "type": "string",
            "description": "Rule identifier (e.g., 'missing-error-handling')"
          },
          "title": {
            "type": "string",
            "description": "One-line issue summary"
          },
          "message": {
            "type": "string",
            "description": "Detailed description of the issue"
          },
          "suggestion": {
            "type": "string",
            "description": "How to fix it"
          },
          "code_snippet": {
            "type": "string",
            "description": "Affected code (first 200 chars)"
          }
        },
        "required": ["finding_id", "file", "severity", "rule", "title", "message"]
      }
    },
    "test_recommendations": {
      "type": "array",
      "items": {
        "type": "object",
        "properties": {
          "file": {
            "type": "string",
            "description": "Source file that needs tests"
          },
          "reason": {
            "type": "string",
            "enum": ["no_test_file", "low_coverage", "missing_edge_cases"],
            "description": "Why tests are needed"
          },
          "priority": {
            "type": "string",
            "enum": ["critical", "high", "medium"]
          }
        },
        "required": ["file", "reason", "priority"]
      }
    }
  },
  "required": ["metadata", "summary", "findings"]
}
```

**Task:** Review the schema. What information is used to create a unique `finding_id`? (Answer: Hash of file + line + rule, so the same issue always gets the same ID for deduplication.)

---

### Step 2: Create CI Configuration Files

Create configuration files for different CI platforms that run Claude Code.

**File: `.github/workflows/claude-code-review.yml` (GitHub Actions)**

```yaml
name: Claude Code Review

on:
  pull_request:
    types: [opened, synchronize]
  push:
    branches: [main, develop]

jobs:
  claude-analysis:
    runs-on: ubuntu-latest

    steps:
      - uses: actions/checkout@v3
        with:
          fetch-depth: 0  # Full history for commit analysis

      - name: Set up Claude Code
        run: |
          curl https://claude.com/install | bash
          echo "~/.claude/bin" >> $GITHUB_PATH

      - name: Run Claude Code Analysis
        env:
          CLAUDE_API_KEY: ${{ secrets.CLAUDE_API_KEY }}
        run: |
          # Run analysis on changed files
          claude -p \
            --output-format json \
            --json-schema .claude/ci-schema.json \
            --context CLAUDE.md \
            > analysis-report.json

          # Check if analysis passed
          exit_code=0
          if ! jq -e '.summary.analysis_passed' analysis-report.json > /dev/null; then
            exit_code=1
          fi

          exit $exit_code

      - name: Parse and Report Findings
        if: always()
        run: |
          python3 scripts/parse-findings.py analysis-report.json

      - name: Comment on PR
        if: github.event_name == 'pull_request' && always()
        uses: actions/github-script@v6
        with:
          script: |
            const fs = require('fs');
            const report = JSON.parse(fs.readFileSync('analysis-report.json', 'utf8'));

            let comment = '## Claude Code Review\n\n';
            comment += `**Analysis ID:** \`${report.metadata.analysis_id}\`\n`;
            comment += `**Files Analyzed:** ${report.metadata.files_analyzed}\n\n`;

            comment += `### Summary\n`;
            comment += `- Total Issues: ${report.summary.total_issues}\n`;
            comment += `- Critical: ${report.summary.critical}\n`;
            comment += `- High: ${report.summary.high}\n`;
            comment += `- Medium: ${report.summary.medium}\n`;
            comment += `- Low: ${report.summary.low}\n\n`;

            if (report.summary.analysis_passed) {
              comment += '✓ **Analysis Passed** - No critical or high issues found.\n';
            } else {
              comment += '✗ **Analysis Failed** - Critical or high issues detected.\n\n';

              // Show top critical/high issues
              const severe = report.findings.filter(f =>
                f.severity === 'critical' || f.severity === 'high'
              ).slice(0, 10);

              if (severe.length > 0) {
                comment += '### Issues\n';
                severe.forEach(f => {
                  comment += `- **${f.file}:${f.line}** [${f.severity.toUpperCase()}] ${f.title}\n`;
                });
              }
            }

            comment += `\n[Full report](${process.env.GITHUB_SERVER_URL}/${process.env.GITHUB_REPOSITORY}/actions/runs/${process.env.GITHUB_RUN_ID})`;

            github.rest.issues.createComment({
              issue_number: context.issue.number,
              owner: context.repo.owner,
              repo: context.repo.repo,
              body: comment
            });

      - name: Upload Report Artifact
        if: always()
        uses: actions/upload-artifact@v3
        with:
          name: claude-analysis-report
          path: analysis-report.json
```

**File: `.gitlab-ci.yml` (GitLab CI)**

```yaml
stages:
  - analysis
  - report

claude-code-analysis:
  stage: analysis
  image: ubuntu:latest

  before_script:
    - curl https://claude.com/install | bash
    - export PATH="~/.claude/bin:$PATH"

  script:
    # Run Claude Code analysis
    - |
      claude -p \
        --output-format json \
        --json-schema .claude/ci-schema.json \
        --context CLAUDE.md \
        > analysis-report.json

    # Validate against schema
    - |
      python3 -c "
      import json
      with open('analysis-report.json') as f:
        report = json.load(f)
      if not report['summary']['analysis_passed']:
        exit(1)
      "

  artifacts:
    reports:
      artifact: analysis-report.json
    paths:
      - analysis-report.json

  allow_failure: true

report-findings:
  stage: report
  image: python:3.9

  script:
    - python3 scripts/parse-findings.py analysis-report.json
    - python3 scripts/deduplicate.py analysis-report.json

  dependencies:
    - claude-code-analysis
```

**Task:** In the GitHub Actions workflow, what does `--context CLAUDE.md` accomplish? (Answer: It loads the project's CLAUDE.md file as context for the analysis, so Claude understands team standards.)

---

### Step 3: Implement Deduplication Logic

Create a Python script that deduplicates findings across multiple CI runs.

**File: `scripts/deduplicate.py`**

```python
#!/usr/bin/env python3
"""
Deduplicate Claude Code findings across CI runs.

Prevents the same issue from being reported multiple times when:
1. Re-running analysis on a commit (e.g., after fixing one issue, others remain)
2. Analyzing overlapping commits (e.g., commit A with issue, then commit B based on A)
"""

import json
import os
from pathlib import Path
from datetime import datetime, timedelta
from typing import Dict, List, Tuple

class FindingDeduplicator:
    """Manages deduplication of findings across CI runs."""

    def __init__(self, cache_dir: str = ".claude-ci-cache"):
        self.cache_dir = Path(cache_dir)
        self.cache_dir.mkdir(exist_ok=True)
        self.previous_findings = self._load_previous_findings()

    def _load_previous_findings(self) -> Dict[str, dict]:
        """Load findings from the most recent successful analysis."""
        findings_file = self.cache_dir / "previous_findings.json"

        if not findings_file.exists():
            return {}

        try:
            with open(findings_file, 'r') as f:
                return json.load(f)
        except (json.JSONDecodeError, IOError):
            return {}

    def _save_findings(self, findings: Dict[str, dict]):
        """Save findings for the next run."""
        findings_file = self.cache_dir / "previous_findings.json"

        with open(findings_file, 'w') as f:
            json.dump(findings, f, indent=2)

    def is_duplicate(self, finding: dict) -> bool:
        """
        Check if a finding is a duplicate of a previously reported issue.

        A finding is a duplicate if:
        1. Same finding_id exists in previous run
        2. Severity is same
        3. File hasn't changed significantly (same line)
        """
        finding_id = finding.get('finding_id')
        if not finding_id or finding_id not in self.previous_findings:
            return False

        prev_finding = self.previous_findings[finding_id]

        # Check if the line number matches (indicates same issue)
        if prev_finding.get('line') == finding.get('line'):
            return True

        # If line changed but finding_id same, it's likely a moved block → not duplicate
        return False

    def get_new_findings(self, current_findings: List[dict]) -> Tuple[List[dict], List[dict]]:
        """
        Separate new findings from duplicates.

        Returns: (new_findings, duplicate_findings)
        """
        new = []
        duplicates = []

        for finding in current_findings:
            if self.is_duplicate(finding):
                duplicates.append(finding)
            else:
                new.append(finding)

        return new, duplicates

    def process_report(self, report: dict) -> dict:
        """
        Process a full analysis report, removing duplicate findings.

        Returns the deduplicated report.
        """
        current_findings = report.get('findings', [])
        new_findings, duplicates = self.get_new_findings(current_findings)

        # Update report
        report['findings'] = new_findings
        report['summary']['total_issues'] = len(new_findings)
        report['summary']['new_issues'] = len(new_findings)
        report['summary']['duplicate_issues'] = len(duplicates)

        # Update counts by severity
        for severity in ['critical', 'high', 'medium', 'low']:
            report['summary'][severity] = len([
                f for f in new_findings if f.get('severity') == severity
            ])

        # Re-evaluate if analysis passed
        critical_or_high = len([
            f for f in new_findings
            if f.get('severity') in ['critical', 'high']
        ])
        report['summary']['analysis_passed'] = critical_or_high == 0

        # Save for next run
        finding_map = {f['finding_id']: f for f in new_findings}
        self._save_findings(finding_map)

        return report

def deduplicate_ci_report(report_path: str, output_path: str = None):
    """
    Deduplicate findings in a CI report and save the result.

    Args:
        report_path: Path to analysis-report.json
        output_path: Where to save deduplicated report (default: overwrite)
    """
    if output_path is None:
        output_path = report_path

    # Load report
    with open(report_path, 'r') as f:
        report = json.load(f)

    # Deduplicate
    deduplicator = FindingDeduplicator()
    deduplicated = deduplicator.process_report(report)

    # Save result
    with open(output_path, 'w') as f:
        json.dump(deduplicated, f, indent=2)

    # Print summary
    print(f"\n📊 Deduplication Summary")
    print(f"  New Issues: {deduplicated['summary'].get('new_issues', 0)}")
    print(f"  Duplicate Issues (not re-reported): {deduplicated['summary'].get('duplicate_issues', 0)}")
    print(f"  Total Reported: {deduplicated['summary']['total_issues']}")

    return deduplicated

if __name__ == "__main__":
    import sys

    if len(sys.argv) < 2:
        print("Usage: python deduplicate.py <report.json> [output.json]")
        sys.exit(1)

    report_path = sys.argv[1]
    output_path = sys.argv[2] if len(sys.argv) > 2 else None

    report = deduplicate_ci_report(report_path, output_path)

    # Exit with non-zero if critical/high issues exist
    if not report['summary']['analysis_passed']:
        sys.exit(1)
```

**File: `scripts/parse-findings.py`**

```python
#!/usr/bin/env python3
"""
Parse Claude Code analysis findings and generate human-readable reports.
"""

import json
import sys
from pathlib import Path
from typing import List

def print_findings_report(report: dict):
    """Print a formatted findings report."""

    print("\n" + "="*70)
    print("CLAUDE CODE ANALYSIS REPORT")
    print("="*70)

    meta = report.get('metadata', {})
    print(f"\nMetadata:")
    print(f"  Analysis ID: {meta.get('analysis_id')}")
    print(f"  Commit: {meta.get('commit_sha', 'unknown')[:8]}")
    print(f"  Branch: {meta.get('branch')}")
    print(f"  Timestamp: {meta.get('timestamp')}")
    print(f"  Files Analyzed: {meta.get('files_analyzed', 0)}")

    summary = report.get('summary', {})
    print(f"\nSummary:")
    print(f"  Total Issues: {summary.get('total_issues', 0)}")
    print(f"    - Critical: {summary.get('critical', 0)}")
    print(f"    - High: {summary.get('high', 0)}")
    print(f"    - Medium: {summary.get('medium', 0)}")
    print(f"    - Low: {summary.get('low', 0)}")

    if summary.get('analysis_passed'):
        print(f"\n✓ ANALYSIS PASSED - No critical or high issues")
    else:
        print(f"\n✗ ANALYSIS FAILED - Critical or high issues detected")

    findings = report.get('findings', [])
    if findings:
        print(f"\nFindings ({len(findings)} total):\n")

        # Group by severity
        for severity in ['critical', 'high', 'medium', 'low']:
            severity_findings = [f for f in findings if f.get('severity') == severity]
            if not severity_findings:
                continue

            print(f"  {severity.upper()} ({len(severity_findings)})")
            print(f"  {'-'*66}")

            for f in severity_findings:
                print(f"    📄 {f.get('file')}:{f.get('line', 0)}")
                print(f"    📋 {f.get('title')}")
                print(f"    💡 {f.get('suggestion', 'No suggestion')}")
                print()

    # Test recommendations
    test_recs = report.get('test_recommendations', [])
    if test_recs:
        print(f"\nTest Recommendations ({len(test_recs)} files):")
        for rec in test_recs:
            print(f"  - {rec.get('file')} ({rec.get('reason')})")

    print("\n" + "="*70 + "\n")

def main():
    if len(sys.argv) < 2:
        print("Usage: python parse-findings.py <report.json>")
        sys.exit(1)

    report_path = sys.argv[1]

    try:
        with open(report_path, 'r') as f:
            report = json.load(f)
    except (FileNotFoundError, json.JSONDecodeError) as e:
        print(f"Error reading report: {e}")
        sys.exit(1)

    print_findings_report(report)

    # Exit with error if analysis didn't pass
    if not report.get('summary', {}).get('analysis_passed', False):
        sys.exit(1)

if __name__ == "__main__":
    main()
```

**Task:** In the `deduplicate.py` script, when would a finding NOT be considered a duplicate even if the `finding_id` matches? (Answer: If the line number changed, indicating the code was moved rather than the same issue being re-reported.)

---

### Step 4: Configure CLAUDE.md for Test Generation Context

Update CLAUDE.md with test generation instructions for CI.

**File: `CLAUDE.md` (Test Generation Section)**

```markdown
# Test Generation Context for CI

When Claude Code runs with the -p flag in CI, it analyzes code and recommends tests.

## Test Generation Rules

### For Files with No Test Coverage
- Severity: HIGH
- Message: "File has no test coverage. Tests should be added."
- Recommended action: Generate tests using `/generate-test <file>`

### For Files with Low Coverage
- Severity: MEDIUM
- Threshold: <80% for functions, <75% for components
- Recommendation: "Expand tests to cover edge cases"

### Test Generation Priority
1. **Critical Path Files** (authentication, payments, data access) → Must have tests
2. **Public API Endpoints** → Must have integration tests
3. **Utility Functions** → Should have unit tests
4. **UI Components** → Should have interaction tests

## CI Integration

When Claude Code runs with:
```bash
claude -p --output-format json --context CLAUDE.md
```

It uses this file to:
1. Understand team testing standards
2. Identify files that need test coverage
3. Generate test recommendations in the JSON output
4. Fail the build if critical files have no tests

## Example: Test Recommendations in JSON

```json
{
  "test_recommendations": [
    {
      "file": "src/services/auth-service.ts",
      "reason": "no_test_file",
      "priority": "critical",
      "suggestion": "Generate tests with: claude /generate-test src/services/auth-service.ts"
    },
    {
      "file": "src/components/UserProfile.tsx",
      "reason": "low_coverage",
      "priority": "high",
      "coverage": "45%",
      "suggestion": "Add tests for user interaction flows"
    }
  ]
}
```

## Files Requiring Tests (Critical Path)
- Any file in `src/services/`
- Any file in `src/api/`
- Any file matching `**/auth/**`
- Any file matching `**/payment/**`

## Files Not Requiring Tests
- Configuration files (*.config.js, .env)
- Type definitions (*.d.ts)
- Mock data files
```

---

### Step 5: Create a Test CI Job

Create a simplified local simulation of a CI run.

**File: `scripts/run-ci-locally.sh`**

```bash
#!/bin/bash
set -e

echo "🔍 Running Claude Code Analysis (Local CI Simulation)"
echo "=================================================="

# Set environment
export CLAUDE_API_KEY="${CLAUDE_API_KEY:?Error: CLAUDE_API_KEY not set}"

# Create output directory
mkdir -p .ci-output

# Get current commit info
COMMIT_SHA=$(git rev-parse HEAD)
BRANCH=$(git rev-parse --abbrev-ref HEAD)

echo "Commit: $COMMIT_SHA"
echo "Branch: $BRANCH"
echo ""

# Run Claude Code analysis
echo "Running analysis..."
claude -p \
  --output-format json \
  --json-schema .claude/ci-schema.json \
  --context CLAUDE.md \
  > .ci-output/analysis-report.json

echo "✓ Analysis complete"

# Deduplicate findings
echo "Deduplicating findings..."
python3 scripts/deduplicate.py \
  .ci-output/analysis-report.json \
  .ci-output/analysis-deduped.json

echo "✓ Deduplication complete"

# Parse and display findings
echo ""
python3 scripts/parse-findings.py .ci-output/analysis-deduped.json

# Check if analysis passed
ANALYSIS_PASSED=$(jq -r '.summary.analysis_passed' .ci-output/analysis-deduped.json)

if [ "$ANALYSIS_PASSED" = "true" ]; then
  echo "✓ CI Analysis PASSED"
  exit 0
else
  echo "✗ CI Analysis FAILED"
  exit 1
fi
```

**Usage:**
```bash
chmod +x scripts/run-ci-locally.sh
./scripts/run-ci-locally.sh
```

---

### Step 6: Integration Test Scenario

Create a test scenario that demonstrates the full CI pipeline.

**File: `tests/ci-integration.test.js`**

```javascript
/**
 * Integration test for CI pipeline.
 *
 * This test verifies that:
 * 1. Claude Code generates valid JSON output
 * 2. JSON conforms to the schema
 * 3. Deduplication works across runs
 * 4. Findings are correctly parsed
 */

const fs = require('fs');
const path = require('path');
const { execSync } = require('child_process');
const Ajv = require('ajv');

describe('CI Pipeline Integration', () => {
  const schemaPath = path.join(__dirname, '../.claude/ci-schema.json');
  const reportPath = path.join(__dirname, '../.ci-output/analysis-report.json');
  const schema = JSON.parse(fs.readFileSync(schemaPath, 'utf8'));
  const ajv = new Ajv();

  test('Should generate valid JSON report', () => {
    // Run analysis
    try {
      execSync('./scripts/run-ci-locally.sh', {
        cwd: path.join(__dirname, '..')
      });
    } catch (e) {
      // Analysis may fail due to issues, but JSON should still be generated
    }

    expect(fs.existsSync(reportPath)).toBe(true);

    const report = JSON.parse(fs.readFileSync(reportPath, 'utf8'));
    expect(report).toHaveProperty('metadata');
    expect(report).toHaveProperty('summary');
    expect(report).toHaveProperty('findings');
  });

  test('Should conform to schema', () => {
    const report = JSON.parse(fs.readFileSync(reportPath, 'utf8'));
    const validate = ajv.compile(schema);

    expect(validate(report)).toBe(true);
    if (!validate(report)) {
      console.error('Schema validation errors:', validate.errors);
    }
  });

  test('Should have required metadata fields', () => {
    const report = JSON.parse(fs.readFileSync(reportPath, 'utf8'));
    const { metadata } = report;

    expect(metadata).toHaveProperty('analysis_id');
    expect(metadata).toHaveProperty('timestamp');
    expect(metadata).toHaveProperty('commit_sha');
    expect(metadata.commit_sha).toMatch(/^[a-f0-9]{40}$/);
  });

  test('Should deduplicatefindings correctly', () => {
    // Run analysis twice
    execSync('./scripts/run-ci-locally.sh', { cwd: path.join(__dirname, '..') });
    const report1 = JSON.parse(
      fs.readFileSync(path.join(__dirname, '../.ci-output/analysis-deduped.json'), 'utf8')
    );

    const findings1 = report1.findings.length;

    // Run again (should deduplicate)
    execSync('./scripts/run-ci-locally.sh', { cwd: path.join(__dirname, '..') });
    const report2 = JSON.parse(
      fs.readFileSync(path.join(__dirname, '../.ci-output/analysis-deduped.json'), 'utf8')
    );

    const findings2 = report2.findings.length;

    // Second run should have same or fewer findings
    expect(findings2).toBeLessThanOrEqual(findings1);
  });

  test('Should calculate correct summary', () => {
    const report = JSON.parse(fs.readFileSync(reportPath, 'utf8'));
    const { summary, findings } = report;

    // Total should match sum
    const calcTotal = findings.length;
    expect(summary.total_issues).toBe(calcTotal);

    // Severity counts should match
    const critical = findings.filter(f => f.severity === 'critical').length;
    expect(summary.critical).toBe(critical);
  });
});
```

---

## Expected Outcomes & Success Criteria

### Successful CI Pipeline
1. **JSON Output:** `claude -p --output-format json` produces valid JSON
2. **Schema Validation:** Output conforms to defined schema
3. **Deduplication:** Findings from previous runs don't appear again
4. **Test Recommendations:** CI identifies files needing tests
5. **Exit Codes:** Pipeline returns 0 (pass) or 1 (fail) correctly
6. **Report Artifacts:** Analysis report is saved for review

### Test Pass Criteria
- `./scripts/run-ci-locally.sh` completes without errors
- `analysis-report.json` is generated and valid
- JSON schema validation passes
- `parse-findings.py` produces readable report
- Deduplication script runs without errors
- Second run shows fewer or equal issues (deduplication working)

### Sample CI Output
```
🔍 Running Claude Code Analysis (Local CI Simulation)
==================================================
Commit: a1b2c3d4e5f6g7h8i9j0
Branch: feature/auth

Running analysis...
✓ Analysis complete

Deduplicating findings...
✓ Deduplication complete

======================================================================
CLAUDE CODE ANALYSIS REPORT
======================================================================

Metadata:
  Analysis ID: a1b2c3d4e5f6g7h8i9j0-20240326-143000
  Commit: a1b2c3d4
  Branch: feature/auth
  Timestamp: 2024-03-26T14:30:00Z
  Files Analyzed: 12

Summary:
  Total Issues: 5
    - Critical: 0
    - High: 2
    - Medium: 2
    - Low: 1

✓ ANALYSIS PASSED - No critical or high issues

Findings (5 total):

  HIGH (2)
  ------------------------------------------------------------------
    📄 src/services/auth.ts:45
    📋 Missing error handling for async operation
    💡 Wrap promise in try/catch or add .catch() handler

    📄 src/api/user-endpoints.ts:102
    📋 Hardcoded environment variable
    💡 Use process.env.API_URL instead of hardcoded string
```

---

## Common Mistakes to Avoid

1. **Not setting CLAUDE_API_KEY in CI environment:** Analysis fails silently
2. **Invalid JSON schema:** Validation fails; no meaningful errors reported
3. **Deduplication based on file path only:** Doesn't work when code moves between files
4. **Not checking analysis_passed exit code:** CI continues despite failures
5. **Reporting same issue multiple times:** Deduplication logic broken
6. **No artifact storage:** Reports lost after CI job completes
7. **Timeout in CI:** Analysis takes too long; job times out
8. **Overly strict rules:** All PRs fail; developers ignore CI

---

## Connection to Exam Concepts

**Domain 3: Configuration & Team Workflows**
- **Task 3.3:** Integrate Claude into team CI/CD processes
  - GitHub Actions and GitLab CI configurations demonstrate CI integration

**Domain 4: Prompt Engineering & Outputs**
- **Task 4.1:** Design structured outputs with JSON schema
  - ci-schema.json defines the output format and validates reports
- **Task 4.2:** Handle output validation and parsing
  - deduplicate.py and parse-findings.py process and validate JSON

**Relevant Course Modules:** Module 3 (Configuration), Module 4 (Structured Outputs)

---

## Estimated Time to Complete

- **Step 1 (JSON schema design):** 15 minutes
- **Step 2 (CI config files):** 20 minutes
- **Step 3 (Deduplication logic):** 25 minutes
- **Step 4 (CLAUDE.md context):** 10 minutes
- **Step 5 (Local CI script):** 15 minutes
- **Step 6 (Integration tests):** 15 minutes
- **Testing & verification:** 20 minutes
- **Total:** 120 minutes (2 hours)

**Suggested Checkpoint:** After Step 2, verify that `claude -p` produces JSON output matching the schema.

---

## Additional Challenges (Optional)

1. **Implement report trending:** Store reports from each commit and show improvement/regression over time
2. **Add PR comment bot:** Have CI automatically comment on PRs with findings
3. **Build a web dashboard:** Visualize CI findings over time with charts and filters
4. **Implement selective analysis:** Only analyze changed files in a PR (vs. entire codebase)
5. **Add cost tracking:** Calculate token usage per CI run and alert on cost spikes
6. **Build a violation feed:** Create RSS/webhook feed of issues across all branches
7. **Implement automatic fixes:** For simple issues (formatting), automatically commit fixes
8. **Add performance profiling:** Track how long Claude analysis takes; alert if it slows down
