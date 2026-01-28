#!/bin/bash

set -e

echo "=== Starting Static Analysis ==="
echo "Timestamp: $(date)"

# Create reports directory if it doesn't exist
mkdir -p reports

# Run Kubesec analysis
echo "Running Kubesec analysis..."
for file in manifests/*.yaml; do
    if [ -f "$file" ]; then
        filename=$(basename "$file" .yaml)
        echo "Analyzing $file..."
        kubesec scan "$file" > "reports/kubesec-${filename}-report.json"
        
        # Extract score for summary
        score=$(jq -r '.[0].score // "N/A"' "reports/kubesec-${filename}-report.json")
        echo "  Score: $score"
    fi
done

# Run KubeLinter analysis
echo "Running KubeLinter analysis..."
kube-linter lint manifests/ --format json > reports/kube-linter-full-report.json
kube-linter lint manifests/ --format plain > reports/kube-linter-summary.txt

# Generate summary report
echo "Generating summary report..."
cat > reports/analysis-summary.md << 'SUMMARY'
# Static Analysis Summary

## Analysis Date
$(date)

## Files Analyzed
$(find manifests/ -name "*.yaml" | wc -l) YAML files

## Kubesec Results
$(for file in reports/kubesec-*-report.json; do
    if [ -f "$file" ]; then
        filename=$(basename "$file" -report.json | sed 's/kubesec-//')
        score=$(jq -r '.[0].score // "N/A"' "$file")
        echo "- $filename: Score $score"
    fi
done)

## KubeLinter Issues
$(jq -r '.Reports | length' reports/kube-linter-full-report.json) total issues found

## Critical Issues
$(jq -r '.Reports[] | select(.Level == "error") | .Check' reports/kube-linter-full-report.json | sort | uniq -c | sort -nr)

SUMMARY

echo "=== Static Analysis Complete ==="
echo "Reports generated in ./reports/ directory"
