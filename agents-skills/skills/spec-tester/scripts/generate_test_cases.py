#!/usr/bin/env python3
"""Generate test cases from DTO validation rules."""

import sys
import re
import json
import argparse


def extract_rules_from_dto(file_path: str) -> dict:
    """Extract validation rules from a Spatie DTO class."""
    with open(file_path, 'r') as f:
        content = f.read()
    
    rules = {}
    
    # Look for static rules() method
    rules_match = re.search(r'public static function rules\([^)]*\): array\s*\{([^}]+)\}', content, re.DOTALL)
    if rules_match:
        rules_text = rules_match.group(1)
        # Extract individual rules
        for line in rules_text.split('\n'):
            match = re.match(r"'(\w+)'\s*=>\s*'([^']+)'", line)
            if match:
                rules[match.group(1)] = match.group(2)
    
    return rules


def generate_test_cases(rules: dict, class_name: str) -> list:
    """Generate test cases based on validation rules."""
    test_cases = []
    
    for field, rule_str in rules.items():
        # Parse rules
        rule_list = [r.strip() for r in rule_str.split('|')]
        
        # Test required
        if 'required' in rule_list:
            test_cases.append({
                'field': field,
                'test': 'missing_field',
                'description': f'Test {field} is required',
                'data': {field: None},
                'expected_error': field,
            })
        
        # Test string
        if 'string' in rule_list:
            test_cases.append({
                'field': field,
                'test': 'wrong_type',
                'description': f'Test {field} must be string',
                'data': {field: 123},
                'expected_error': field,
            })
        
        # Test integer
        if 'integer' in rule_list or 'numeric' in rule_list:
            test_cases.append({
                'field': field,
                'test': 'wrong_type',
                'description': f'Test {field} must be numeric',
                'data': {field: 'not_a_number'},
                'expected_error': field,
            })
        
        # Test email
        if 'email' in rule_list:
            test_cases.append({
                'field': field,
                'test': 'invalid_email',
                'description': f'Test {field} must be valid email',
                'data': {field: 'not_an_email'},
                'expected_error': field,
            })
        
        # Test max
        max_match = re.search(r'max:(\d+)', rule_str)
        if max_match:
            max_val = int(max_match.group(1))
            test_cases.append({
                'field': field,
                'test': 'exceeds_max',
                'description': f'Test {field} max length {max_val}',
                'data': {field: 'a' * (max_val + 1)},
                'expected_error': field,
            })
    
    return test_cases


def main():
    parser = argparse.ArgumentParser(description='Generate test cases from DTO')
    parser.add_argument('dto_file', help='Path to DTO file')
    parser.add_argument('--output', help='Output file for test cases (JSON)')
    args = parser.parse_args()
    
    rules = extract_rules_from_dto(args.dto_file)
    if not rules:
        print("No validation rules found in DTO", file=sys.stderr)
        sys.exit(1)
    
    class_name = re.search(r'class (\w+)', open(args.dto_file).read())
    class_name = class_name.group(1) if class_name else 'Unknown'
    
    test_cases = generate_test_cases(rules, class_name)
    
    output = {
        'dto_class': class_name,
        'dto_file': args.dto_file,
        'rules': rules,
        'test_cases': test_cases,
    }
    
    if args.output:
        with open(args.output, 'w') as f:
            json.dump(output, f, indent=2)
        print(f"Test cases written to {args.output}")
    else:
        print(json.dumps(output, indent=2))


if __name__ == '__main__':
    main()
