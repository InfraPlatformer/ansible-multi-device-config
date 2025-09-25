#!/usr/bin/env python3
"""
API Reverse Engineering Tool
Analyze and reverse engineer REST APIs and GraphQL endpoints
"""

import requests
import json
import re
import time
from urllib.parse import urljoin, urlparse
from bs4 import BeautifulSoup
import argparse

class APIAnalyzer:
    """Analyze APIs for reverse engineering purposes"""
    
    def __init__(self, base_url):
        self.base_url = base_url
        self.session = requests.Session()
        self.endpoints = []
        self.parameters = set()
        self.headers = set()
        self.responses = []
        
    def analyze(self):
        """Run comprehensive API analysis"""
        print(f"Analyzing API: {self.base_url}")
        print("=" * 60)
        
        # Basic connectivity test
        self._test_connectivity()
        
        # Discover endpoints
        self._discover_endpoints()
        
        # Analyze responses
        self._analyze_responses()
        
        # Security analysis
        self._security_analysis()
        
        # Generate report
        self._generate_report()
        
    def _test_connectivity(self):
        """Test basic connectivity"""
        print("\n=== Connectivity Test ===")
        
        try:
            response = self.session.get(self.base_url, timeout=10)
            print(f"Status: {response.status_code}")
            print(f"Headers: {dict(response.headers)}")
            
            if response.status_code == 200:
                print("✓ API is accessible")
            else:
                print(f"⚠ API returned status {response.status_code}")
                
        except requests.exceptions.RequestException as e:
            print(f"✗ Connection failed: {e}")
    
    def _discover_endpoints(self):
        """Discover API endpoints"""
        print("\n=== Endpoint Discovery ===")
        
        # Common API endpoints to try
        common_endpoints = [
            '/api',
            '/api/v1',
            '/api/v2',
            '/api/docs',
            '/api/swagger',
            '/swagger.json',
            '/api.json',
            '/graphql',
            '/api/graphql',
            '/health',
            '/status',
            '/version',
            '/info',
            '/metrics',
            '/admin',
            '/users',
            '/auth',
            '/login',
            '/logout',
            '/register',
            '/profile',
            '/settings',
            '/config',
            '/data',
            '/files',
            '/upload',
            '/download'
        ]
        
        discovered = []
        for endpoint in common_endpoints:
            url = urljoin(self.base_url, endpoint)
            try:
                response = self.session.get(url, timeout=5)
                if response.status_code not in [404, 403]:
                    discovered.append({
                        'endpoint': endpoint,
                        'status': response.status_code,
                        'headers': dict(response.headers),
                        'content_type': response.headers.get('content-type', ''),
                        'size': len(response.content)
                    })
                    print(f"✓ {endpoint} -> {response.status_code}")
                    
            except requests.exceptions.RequestException:
                continue
        
        self.endpoints = discovered
        print(f"Discovered {len(discovered)} endpoints")
    
    def _analyze_responses(self):
        """Analyze API responses"""
        print("\n=== Response Analysis ===")
        
        for endpoint in self.endpoints:
            url = urljoin(self.base_url, endpoint['endpoint'])
            
            try:
                response = self.session.get(url, timeout=10)
                
                # Analyze content type
                content_type = response.headers.get('content-type', '')
                print(f"\nEndpoint: {endpoint['endpoint']}")
                print(f"Content-Type: {content_type}")
                
                # Analyze JSON responses
                if 'application/json' in content_type:
                    try:
                        data = response.json()
                        self._analyze_json_structure(data, endpoint['endpoint'])
                    except json.JSONDecodeError:
                        print("  Invalid JSON response")
                
                # Analyze HTML responses
                elif 'text/html' in content_type:
                    self._analyze_html_response(response.text, endpoint['endpoint'])
                
                # Analyze other content types
                else:
                    print(f"  Content-Type: {content_type}")
                    print(f"  Size: {len(response.content)} bytes")
                
                # Extract parameters and headers
                self._extract_parameters(response)
                self._extract_headers(response)
                
            except requests.exceptions.RequestException as e:
                print(f"  Error analyzing {endpoint['endpoint']}: {e}")
    
    def _analyze_json_structure(self, data, endpoint):
        """Analyze JSON structure"""
        print(f"  JSON Structure for {endpoint}:")
        
        if isinstance(data, dict):
            for key, value in data.items():
                value_type = type(value).__name__
                print(f"    {key}: {value_type}")
                
                # Look for interesting patterns
                if key.lower() in ['token', 'key', 'secret', 'password', 'auth']:
                    print(f"      ⚠ Potential sensitive field: {key}")
                
                if isinstance(value, str) and len(value) > 50:
                    print(f"      ⚠ Long string value: {value[:50]}...")
        
        elif isinstance(data, list):
            print(f"    Array with {len(data)} items")
            if data and isinstance(data[0], dict):
                print("    Sample item structure:")
                for key in data[0].keys():
                    print(f"      {key}")
    
    def _analyze_html_response(self, html, endpoint):
        """Analyze HTML responses"""
        print(f"  HTML Analysis for {endpoint}:")
        
        try:
            soup = BeautifulSoup(html, 'html.parser')
            
            # Look for forms
            forms = soup.find_all('form')
            if forms:
                print(f"    Found {len(forms)} forms")
                for form in forms:
                    action = form.get('action', '')
                    method = form.get('method', 'GET')
                    print(f"      Form: {method} {action}")
            
            # Look for links
            links = soup.find_all('a', href=True)
            api_links = [link['href'] for link in links if '/api' in link['href']]
            if api_links:
                print(f"    Found {len(api_links)} API links")
                for link in api_links[:5]:  # Show first 5
                    print(f"      {link}")
            
            # Look for JavaScript
            scripts = soup.find_all('script')
            if scripts:
                print(f"    Found {len(scripts)} script tags")
                
        except Exception as e:
            print(f"    Error parsing HTML: {e}")
    
    def _extract_parameters(self, response):
        """Extract parameters from response"""
        # Look for parameter patterns in response text
        param_patterns = [
            r'(\w+)=([^&\s]+)',
            r'["\'](\w+)["\']:\s*["\']([^"\']+)["\']',
            r'<input[^>]*name=["\'](\w+)["\'][^>]*>',
            r'<param[^>]*name=["\'](\w+)["\'][^>]*>'
        ]
        
        for pattern in param_patterns:
            matches = re.findall(pattern, response.text)
            for match in matches:
                if len(match) == 2:
                    self.parameters.add(match[0])
    
    def _extract_headers(self, response):
        """Extract headers from response"""
        for header in response.headers:
            self.headers.add(header)
    
    def _security_analysis(self):
        """Perform security analysis"""
        print("\n=== Security Analysis ===")
        
        # Check for common security headers
        security_headers = [
            'X-Frame-Options',
            'X-Content-Type-Options',
            'X-XSS-Protection',
            'Strict-Transport-Security',
            'Content-Security-Policy'
        ]
        
        print("Security headers:")
        for header in security_headers:
            if header in self.headers:
                print(f"  ✓ {header}")
            else:
                print(f"  ✗ {header} (missing)")
        
        # Check for sensitive information
        print("\nSensitive information check:")
        sensitive_patterns = [
            r'password["\']?\s*[:=]\s*["\']([^"\']+)["\']',
            r'token["\']?\s*[:=]\s*["\']([^"\']+)["\']',
            r'key["\']?\s*[:=]\s*["\']([^"\']+)["\']',
            r'secret["\']?\s*[:=]\s*["\']([^"\']+)["\']'
        ]
        
        for pattern in sensitive_patterns:
            matches = re.findall(pattern, str(self.responses))
            if matches:
                print(f"  ⚠ Found potential sensitive data: {pattern}")
    
    def _generate_report(self):
        """Generate analysis report"""
        print("\n=== Analysis Report ===")
        
        report = {
            'base_url': self.base_url,
            'endpoints': self.endpoints,
            'parameters': list(self.parameters),
            'headers': list(self.headers),
            'timestamp': time.strftime('%Y-%m-%d %H:%M:%S')
        }
        
        # Save report
        report_file = f"api_analysis_report_{int(time.time())}.json"
        with open(report_file, 'w') as f:
            json.dump(report, f, indent=2)
        
        print(f"Report saved to: {report_file}")
        
        # Print summary
        print(f"\nSummary:")
        print(f"  Endpoints discovered: {len(self.endpoints)}")
        print(f"  Parameters found: {len(self.parameters)}")
        print(f"  Headers found: {len(self.headers)}")

def main():
    parser = argparse.ArgumentParser(description='API Reverse Engineering Tool')
    parser.add_argument('url', help='Base URL to analyze')
    parser.add_argument('--timeout', type=int, default=10, help='Request timeout')
    parser.add_argument('--headers', help='Custom headers (JSON format)')
    
    args = parser.parse_args()
    
    analyzer = APIAnalyzer(args.url)
    
    if args.headers:
        try:
            headers = json.loads(args.headers)
            analyzer.session.headers.update(headers)
        except json.JSONDecodeError:
            print("Invalid headers format")
            return
    
    analyzer.analyze()

if __name__ == "__main__":
    main()