#!/usr/bin/env python3
"""
Obfuscation Analysis - Intermediate Exercise
Learn to analyze and deobfuscate Python code
"""

import dis
import base64
import zlib
import marshal
import types
import string

class ObfuscationAnalyzer:
    """Analyze various Python obfuscation techniques"""
    
    def __init__(self):
        self.techniques = {
            'base64': self._analyze_base64,
            'zlib': self._analyze_zlib,
            'marshal': self._analyze_marshal,
            'string_obfuscation': self._analyze_string_obfuscation,
            'control_flow': self._analyze_control_flow
        }
    
    def analyze_code(self, code_string):
        """Analyze code for obfuscation techniques"""
        print("=== Obfuscation Analysis ===")
        
        for technique, analyzer in self.techniques.items():
            if analyzer(code_string):
                print(f"✓ Detected {technique} obfuscation")
            else:
                print(f"✗ No {technique} obfuscation detected")
    
    def _analyze_base64(self, code):
        """Check for base64 encoded strings"""
        import re
        base64_pattern = r'[A-Za-z0-9+/]{20,}={0,2}'
        matches = re.findall(base64_pattern, code)
        
        for match in matches:
            try:
                decoded = base64.b64decode(match).decode('utf-8')
                if any(keyword in decoded.lower() for keyword in ['import', 'def', 'class', 'exec']):
                    print(f"  Found base64 encoded code: {match[:20]}...")
                    return True
            except:
                continue
        return False
    
    def _analyze_zlib(self, code):
        """Check for zlib compressed data"""
        import re
        # Look for zlib.decompress calls
        if 'zlib.decompress' in code:
            print("  Found zlib decompression")
            return True
        return False
    
    def _analyze_marshal(self, code):
        """Check for marshal.loads calls"""
        if 'marshal.loads' in code:
            print("  Found marshal deserialization")
            return True
        return False
    
    def _analyze_string_obfuscation(self, code):
        """Check for string obfuscation techniques"""
        # Check for XOR operations on strings
        if 'chr(' in code and 'ord(' in code:
            print("  Found character-based string obfuscation")
            return True
        
        # Check for string concatenation patterns
        if code.count('"') > 10 or code.count("'") > 10:
            print("  Found potential string fragmentation")
            return True
        
        return False
    
    def _analyze_control_flow(self, code):
        """Check for control flow obfuscation"""
        # Check for excessive use of exec/eval
        if code.count('exec(') > 3 or code.count('eval(') > 3:
            print("  Found dynamic code execution")
            return True
        
        # Check for complex conditional structures
        if code.count('if') > 5 and code.count('else') > 3:
            print("  Found complex control flow")
            return True
        
        return False

def create_obfuscated_samples():
    """Create sample obfuscated code for analysis"""
    
    # Sample 1: Base64 obfuscation
    sample1 = '''
import base64
code = "cHJpbnQoIkhlbGxvIFdvcmxkIik="
exec(base64.b64decode(code).decode())
'''
    
    # Sample 2: String obfuscation
    sample2 = '''
def decode_string(s):
    return ''.join(chr(ord(c) ^ 1) for c in s)

secret = decode_string("Ifmmp!Xpsme")
print(secret)
'''
    
    # Sample 3: Control flow obfuscation
    sample3 = '''
def obfuscated_logic(x):
    if x > 0:
        if x < 10:
            if x % 2 == 0:
                return "even small positive"
            else:
                return "odd small positive"
        else:
            return "large positive"
    else:
        return "negative or zero"
'''
    
    return {
        'base64_sample': sample1,
        'string_sample': sample2,
        'control_flow_sample': sample3
    }

def exercise_1_base64():
    """Exercise 1: Base64 obfuscation analysis"""
    print("\n" + "="*60)
    print("EXERCISE 1: Base64 Obfuscation Analysis")
    print("="*60)
    
    # Create obfuscated sample
    import base64
    
    original_code = '''
def secret_function():
    print("This is a secret message")
    return "success"
'''
    
    obfuscated_code = f'''
import base64
code = "{base64.b64encode(original_code.encode()).decode()}"
exec(base64.b64decode(code).decode())
'''
    
    print("Obfuscated code:")
    print(obfuscated_code)
    
    print("\nYour task:")
    print("1. Identify the obfuscation technique")
    print("2. Decode the hidden code")
    print("3. Understand what it does")
    
    analyzer = ObfuscationAnalyzer()
    analyzer.analyze_code(obfuscated_code)

def exercise_2_string_obfuscation():
    """Exercise 2: String obfuscation analysis"""
    print("\n" + "="*60)
    print("EXERCISE 2: String Obfuscation Analysis")
    print("="*60)
    
    # XOR obfuscation example
    obfuscated_code = '''
def decode_message(encoded_msg):
    return ''.join(chr(ord(c) ^ 0x42) for c in encoded_msg)

message = decode_message("K\\x1a\\x1e\\x1e\\x1f\\x1c\\x1a\\x1e\\x1f\\x1c\\x1a\\x1e\\x1f")
print(message)
'''
    
    print("Obfuscated code:")
    print(obfuscated_code)
    
    print("\nYour task:")
    print("1. Identify the obfuscation technique")
    print("2. Determine the XOR key")
    print("3. Decode the message")
    
    analyzer = ObfuscationAnalyzer()
    analyzer.analyze_code(obfuscated_code)

def exercise_3_control_flow():
    """Exercise 3: Control flow obfuscation"""
    print("\n" + "="*60)
    print("EXERCISE 3: Control Flow Obfuscation")
    print("="*60)
    
    obfuscated_code = '''
def complex_logic(x, y):
    result = 0
    if x > 0:
        if y > 0:
            if x > y:
                result = x + y
            else:
                result = y - x
        else:
            result = x * 2
    else:
        if y > 0:
            result = y * 2
        else:
            result = 0
    return result
'''
    
    print("Obfuscated code:")
    print(obfuscated_code)
    
    print("\nYour task:")
    print("1. Simplify the control flow")
    print("2. Identify the actual logic")
    print("3. Rewrite in a cleaner form")
    
    # Show bytecode analysis
    print("\nBytecode analysis:")
    exec(obfuscated_code)
    dis.dis(complex_logic)

def deobfuscation_tools():
    """Demonstrate deobfuscation tools"""
    print("\n" + "="*60)
    print("DEOBFUSCATION TOOLS")
    print("="*60)
    
    print("Common deobfuscation techniques:")
    print("1. Base64 decoding: base64.b64decode()")
    print("2. String XOR: chr(ord(c) ^ key)")
    print("3. Control flow: Simplify nested conditions")
    print("4. Dynamic analysis: Use debugger to trace execution")
    
    print("\nTools to use:")
    print("- Python debugger (pdb)")
    print("- Bytecode analysis (dis module)")
    print("- String manipulation")
    print("- Regular expressions")

if __name__ == "__main__":
    print("Python Reverse Engineering Lab - Intermediate Level")
    print("=" * 60)
    
    # Create samples
    samples = create_obfuscated_samples()
    
    # Run exercises
    exercise_1_base64()
    exercise_2_string_obfuscation()
    exercise_3_control_flow()
    
    # Show tools
    deobfuscation_tools()
    
    print("\n" + "="*60)
    print("Next steps:")
    print("1. Practice with real obfuscated samples")
    print("2. Learn advanced deobfuscation techniques")
    print("3. Move to advanced exercises")