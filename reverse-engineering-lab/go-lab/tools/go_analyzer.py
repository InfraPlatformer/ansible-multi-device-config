#!/usr/bin/env python3
"""
Go Binary Analyzer Tool
Analyze Go binaries for reverse engineering purposes
"""

import subprocess
import re
import os
import sys
from pathlib import Path

class GoBinaryAnalyzer:
    """Analyze Go binaries for reverse engineering"""
    
    def __init__(self, binary_path):
        self.binary_path = binary_path
        self.analysis_results = {}
        
    def analyze(self):
        """Run comprehensive analysis"""
        print(f"Analyzing Go binary: {self.binary_path}")
        print("=" * 60)
        
        # Basic file info
        self._analyze_file_info()
        
        # String analysis
        self._analyze_strings()
        
        # Symbol analysis
        self._analyze_symbols()
        
        # Import analysis
        self._analyze_imports()
        
        # Function analysis
        self._analyze_functions()
        
        # Go-specific analysis
        self._analyze_go_specific()
        
        return self.analysis_results
    
    def _analyze_file_info(self):
        """Analyze basic file information"""
        print("\n=== File Information ===")
        
        try:
            # File size
            size = os.path.getsize(self.binary_path)
            print(f"File size: {size:,} bytes")
            
            # File type
            result = subprocess.run(['file', self.binary_path], 
                                  capture_output=True, text=True)
            print(f"File type: {result.stdout.strip()}")
            
            # Check if it's a Go binary
            if 'Go' in result.stdout:
                print("✓ Confirmed Go binary")
            else:
                print("⚠ Not a Go binary")
                
        except Exception as e:
            print(f"Error analyzing file info: {e}")
    
    def _analyze_strings(self):
        """Extract and analyze strings"""
        print("\n=== String Analysis ===")
        
        try:
            result = subprocess.run(['strings', self.binary_path], 
                                  capture_output=True, text=True)
            strings = result.stdout.split('\n')
            
            # Filter interesting strings
            interesting_strings = []
            for s in strings:
                if len(s) > 5 and any(keyword in s.lower() for keyword in 
                    ['http', 'api', 'secret', 'password', 'key', 'token', 'url']):
                    interesting_strings.append(s)
            
            print(f"Total strings: {len(strings)}")
            print(f"Interesting strings: {len(interesting_strings)}")
            
            if interesting_strings:
                print("\nInteresting strings found:")
                for s in interesting_strings[:10]:  # Show first 10
                    print(f"  {s}")
            
            self.analysis_results['strings'] = strings
            self.analysis_results['interesting_strings'] = interesting_strings
            
        except Exception as e:
            print(f"Error analyzing strings: {e}")
    
    def _analyze_symbols(self):
        """Analyze symbol table"""
        print("\n=== Symbol Analysis ===")
        
        try:
            # Use objdump to get symbols
            result = subprocess.run(['objdump', '-t', self.binary_path], 
                                  capture_output=True, text=True)
            
            symbols = result.stdout.split('\n')
            go_symbols = [s for s in symbols if 'go' in s.lower() or 'main' in s.lower()]
            
            print(f"Total symbols: {len(symbols)}")
            print(f"Go-related symbols: {len(go_symbols)}")
            
            if go_symbols:
                print("\nGo-related symbols:")
                for s in go_symbols[:10]:  # Show first 10
                    print(f"  {s}")
            
            self.analysis_results['symbols'] = symbols
            self.analysis_results['go_symbols'] = go_symbols
            
        except Exception as e:
            print(f"Error analyzing symbols: {e}")
    
    def _analyze_imports(self):
        """Analyze imported functions"""
        print("\n=== Import Analysis ===")
        
        try:
            # Use objdump to get imports
            result = subprocess.run(['objdump', '-R', self.binary_path], 
                                  capture_output=True, text=True)
            
            imports = result.stdout.split('\n')
            interesting_imports = []
            
            for imp in imports:
                if any(keyword in imp.lower() for keyword in 
                      ['network', 'crypto', 'os', 'syscall', 'http']):
                    interesting_imports.append(imp)
            
            print(f"Total imports: {len(imports)}")
            print(f"Interesting imports: {len(interesting_imports)}")
            
            if interesting_imports:
                print("\nInteresting imports:")
                for imp in interesting_imports[:10]:
                    print(f"  {imp}")
            
            self.analysis_results['imports'] = imports
            self.analysis_results['interesting_imports'] = interesting_imports
            
        except Exception as e:
            print(f"Error analyzing imports: {e}")
    
    def _analyze_functions(self):
        """Analyze function calls"""
        print("\n=== Function Analysis ===")
        
        try:
            # Use objdump to disassemble
            result = subprocess.run(['objdump', '-d', self.binary_path], 
                                  capture_output=True, text=True)
            
            # Look for function calls
            call_pattern = re.compile(r'call.*<([^>]+)>')
            calls = call_pattern.findall(result.stdout)
            
            # Look for interesting function names
            interesting_calls = []
            for call in calls:
                if any(keyword in call.lower() for keyword in 
                      ['main', 'init', 'runtime', 'syscall']):
                    interesting_calls.append(call)
            
            print(f"Total function calls: {len(calls)}")
            print(f"Interesting calls: {len(interesting_calls)}")
            
            if interesting_calls:
                print("\nInteresting function calls:")
                for call in interesting_calls[:10]:
                    print(f"  {call}")
            
            self.analysis_results['function_calls'] = calls
            self.analysis_results['interesting_calls'] = interesting_calls
            
        except Exception as e:
            print(f"Error analyzing functions: {e}")
    
    def _analyze_go_specific(self):
        """Analyze Go-specific features"""
        print("\n=== Go-Specific Analysis ===")
        
        try:
            # Look for Go runtime symbols
            result = subprocess.run(['strings', self.binary_path], 
                                  capture_output=True, text=True)
            
            go_runtime_strings = []
            for line in result.stdout.split('\n'):
                if any(keyword in line.lower() for keyword in 
                      ['runtime', 'golang', 'go1.', 'main.main', 'main.init']):
                    go_runtime_strings.append(line)
            
            print(f"Go runtime strings: {len(go_runtime_strings)}")
            
            if go_runtime_strings:
                print("\nGo runtime strings:")
                for s in go_runtime_strings[:10]:
                    print(f"  {s}")
            
            # Check for Go version
            version_match = re.search(r'go1\.\d+', result.stdout)
            if version_match:
                print(f"Go version: {version_match.group()}")
            
            self.analysis_results['go_runtime_strings'] = go_runtime_strings
            
        except Exception as e:
            print(f"Error analyzing Go-specific features: {e}")
    
    def generate_report(self, output_file=None):
        """Generate analysis report"""
        if not output_file:
            output_file = f"{self.binary_path}_analysis_report.txt"
        
        with open(output_file, 'w') as f:
            f.write(f"Go Binary Analysis Report\n")
            f.write(f"Binary: {self.binary_path}\n")
            f.write("=" * 60 + "\n\n")
            
            for section, data in self.analysis_results.items():
                f.write(f"{section.upper()}:\n")
                if isinstance(data, list):
                    for item in data:
                        f.write(f"  {item}\n")
                else:
                    f.write(f"  {data}\n")
                f.write("\n")
        
        print(f"\nReport saved to: {output_file}")

def main():
    if len(sys.argv) != 2:
        print("Usage: python go_analyzer.py <go_binary>")
        sys.exit(1)
    
    binary_path = sys.argv[1]
    
    if not os.path.exists(binary_path):
        print(f"File not found: {binary_path}")
        sys.exit(1)
    
    analyzer = GoBinaryAnalyzer(binary_path)
    analyzer.analyze()
    
    # Ask user if they want a report
    response = input("\nGenerate report? (y/n): ").lower()
    if response == 'y':
        analyzer.generate_report()

if __name__ == "__main__":
    main()