#!/usr/bin/env python3
"""Test API endpoint against expected status codes."""

import sys
import json
import argparse
import requests
from urllib.parse import urljoin


def test_endpoint(base_url: str, endpoint: str, method: str = 'GET', 
                   data: dict = None, headers: dict = None, 
                   expected_status: int = 200) -> dict:
    """Test a single API endpoint."""
    url = urljoin(base_url, endpoint)
    
    try:
        if method.upper() == 'GET':
            response = requests.get(url, headers=headers, params=data)
        elif method.upper() == 'POST':
            response = requests.post(url, json=data, headers=headers)
        elif method.upper() == 'PUT':
            response = requests.put(url, json=data, headers=headers)
        elif method.upper() == 'DELETE':
            response = requests.delete(url, headers=headers)
        else:
            return {'error': f'Unsupported method: {method}'}
        
        result = {
            'endpoint': endpoint,
            'method': method,
            'expected_status': expected_status,
            'actual_status': response.status_code,
            'passed': response.status_code == expected_status,
            'response': response.text[:500],  # Truncate long responses
        }
        
        if response.headers.get('content-type') == 'application/json':
            try:
                result['response_json'] = response.json()
            except:
                pass
        
        return result
    
    except Exception as e:
        return {
            'endpoint': endpoint,
            'method': method,
            'error': str(e),
            'passed': False,
        }


def main():
    parser = argparse.ArgumentParser(description='Test API endpoints')
    parser.add_argument('base_url', help='Base URL (e.g., http://localhost:8018)')
    parser.add_argument('endpoints_json', help='JSON file with endpoints to test')
    parser.add_argument('--headers', help='JSON string of headers')
    args = parser.parse_args()
    
    with open(args.endpoints_json, 'r') as f:
        endpoints = json.load(f)
    
    headers = json.loads(args.headers) if args.headers else {}
    
    results = []
    for endpoint_spec in endpoints:
        result = test_endpoint(
            base_url=args.base_url,
            endpoint=endpoint_spec['endpoint'],
            method=endpoint_spec.get('method', 'GET'),
            data=endpoint_spec.get('data'),
            headers=headers,
            expected_status=endpoint_spec.get('expected_status', 200),
        )
        results.append(result)
        
        status = '✓' if result.get('passed') else '✗'
        print(f"{status} {result['method']} {result['endpoint']} - {result.get('actual_status', 'ERROR')}")
    
    print(f"\n--- Summary ---")
    passed = sum(1 for r in results if r.get('passed'))
    print(f"Passed: {passed}/{len(results)}")
    
    if any(not r.get('passed') for r in results):
        print("\nFailed tests:")
        for r in results:
            if not r.get('passed'):
                print(f"  ✗ {r['method']} {r['endpoint']}: expected {r.get('expected_status')}, got {r.get('actual_status')}")


if __name__ == '__main__':
    main()
