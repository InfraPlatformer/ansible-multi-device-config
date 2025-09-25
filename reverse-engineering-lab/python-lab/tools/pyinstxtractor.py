#!/usr/bin/env python3
"""
PyInstaller Extractor Tool
Extract and analyze PyInstaller executables
"""

import os
import sys
import struct
import marshal
import zlib
import tempfile
import shutil

class PyInstExtractor:
    def __init__(self, pyi_path):
        self.pyi_path = pyi_path
        self.toc = []
        self.pyver = None
        
    def open(self):
        """Open and analyze PyInstaller executable"""
        try:
            with open(self.pyi_path, 'rb') as f:
                # Read PyInstaller header
                f.seek(-24, 2)  # Go to end of file
                magic = f.read(8)
                if magic != b'MEI\014\013\012\013\016':
                    raise ValueError("Not a PyInstaller executable")
                
                # Read table of contents
                f.seek(-24, 2)
                (magic, lengthofPackage, tocLen, self.pyver, pyver, pylibname) = \
                    struct.unpack('!8sIIii64s', f.read(88))
                
                # Read TOC
                f.seek(-(24 + lengthofPackage), 2)
                tocdata = f.read(lengthofPackage)
                
                # Parse TOC entries
                pos = 0
                while pos < len(tocdata):
                    (entrySize,) = struct.unpack('!I', tocdata[pos:pos+4])
                    pos += 4
                    
                    entry = struct.unpack('!64sIIII', tocdata[pos:pos+80])
                    pos += 80
                    
                    self.toc.append({
                        'name': entry[0].rstrip(b'\x00').decode('utf-8'),
                        'pos': entry[1],
                        'length': entry[2],
                        'uncompressed': entry[3],
                        'cmprsd': entry[4]
                    })
                
                return True
                
        except Exception as e:
            print(f"Error opening PyInstaller executable: {e}")
            return False
    
    def extract_file(self, entry, output_dir):
        """Extract a single file from PyInstaller archive"""
        try:
            with open(self.pyi_path, 'rb') as f:
                f.seek(entry['pos'])
                data = f.read(entry['length'])
                
                if entry['cmprsd']:
                    data = zlib.decompress(data)
                
                output_path = os.path.join(output_dir, entry['name'])
                os.makedirs(os.path.dirname(output_path), exist_ok=True)
                
                with open(output_path, 'wb') as out:
                    out.write(data)
                
                return True
                
        except Exception as e:
            print(f"Error extracting {entry['name']}: {e}")
            return False
    
    def extract_all(self, output_dir):
        """Extract all files from PyInstaller archive"""
        if not os.path.exists(output_dir):
            os.makedirs(output_dir)
        
        extracted = 0
        for entry in self.toc:
            if self.extract_file(entry, output_dir):
                extracted += 1
                print(f"Extracted: {entry['name']}")
        
        print(f"\nExtracted {extracted} files to {output_dir}")
        return extracted

def analyze_pyinstaller(pyi_path):
    """Analyze a PyInstaller executable"""
    print(f"Analyzing PyInstaller executable: {pyi_path}")
    print("=" * 60)
    
    extractor = PyInstExtractor(pyi_path)
    
    if not extractor.open():
        return False
    
    print(f"Python version: {extractor.pyver}")
    print(f"Number of files: {len(extractor.toc)}")
    print("\nFiles in archive:")
    
    for entry in extractor.toc:
        print(f"  {entry['name']} ({entry['length']} bytes)")
    
    return extractor

def main():
    if len(sys.argv) != 2:
        print("Usage: python pyinstxtractor.py <pyinstaller_executable>")
        sys.exit(1)
    
    pyi_path = sys.argv[1]
    
    if not os.path.exists(pyi_path):
        print(f"File not found: {pyi_path}")
        sys.exit(1)
    
    # Analyze the executable
    extractor = analyze_pyinstaller(pyi_path)
    
    if extractor:
        # Ask user if they want to extract
        response = input("\nExtract files? (y/n): ").lower()
        if response == 'y':
            output_dir = f"{pyi_path}_extracted"
            extractor.extract_all(output_dir)
            print(f"\nFiles extracted to: {output_dir}")

if __name__ == "__main__":
    main()