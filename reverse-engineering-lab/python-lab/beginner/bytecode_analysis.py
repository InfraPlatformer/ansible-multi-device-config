#!/usr/bin/env python3
"""
Python Bytecode Analysis - Beginner Exercise
Learn to analyze Python bytecode and understand how Python executes code.
"""

import dis
import marshal
import types

def simple_function():
    """A simple function to analyze bytecode"""
    x = 10
    y = 20
    result = x + y
    return result

def analyze_bytecode():
    """Analyze the bytecode of simple_function"""
    print("=== Bytecode Analysis Exercise ===")
    print("\n1. Function source code:")
    print(simple_function.__code__.co_code)
    
    print("\n2. Disassembled bytecode:")
    dis.dis(simple_function)
    
    print("\n3. Code object attributes:")
    code_obj = simple_function.__code__
    print(f"   - co_names: {code_obj.co_names}")
    print(f"   - co_consts: {code_obj.co_consts}")
    print(f"   - co_varnames: {code_obj.co_varnames}")
    print(f"   - co_filename: {code_obj.co_filename}")
    print(f"   - co_name: {code_obj.co_name}")

def obfuscated_function():
    """Example of obfuscated code"""
    # This is intentionally obfuscated
    a = [1, 2, 3, 4, 5]
    b = sum(a)
    c = b * 2
    d = c - 10
    return d

def analyze_obfuscated():
    """Analyze obfuscated function"""
    print("\n=== Obfuscated Code Analysis ===")
    print("\nSource code appears simple, but let's analyze:")
    dis.dis(obfuscated_function)
    
    print("\nWhat does this function actually do?")
    print("Hint: Trace through the bytecode operations")

def exercise_1():
    """Exercise 1: Basic bytecode understanding"""
    print("\n" + "="*50)
    print("EXERCISE 1: Basic Bytecode Understanding")
    print("="*50)
    
    # Your task: Analyze this function's bytecode
    def mystery_function():
        secret = "Hello"
        number = 42
        combined = secret + str(number)
        return combined
    
    print("Analyze the bytecode of mystery_function:")
    dis.dis(mystery_function)
    
    print("\nQuestions to answer:")
    print("1. What operations are performed?")
    print("2. What are the constants used?")
    print("3. What variables are created?")
    print("4. What does this function return?")

def exercise_2():
    """Exercise 2: Control flow analysis"""
    print("\n" + "="*50)
    print("EXERCISE 2: Control Flow Analysis")
    print("="*50)
    
    def conditional_function(x):
        if x > 10:
            return "big"
        elif x > 5:
            return "medium"
        else:
            return "small"
    
    print("Analyze the control flow:")
    dis.dis(conditional_function)
    
    print("\nQuestions:")
    print("1. How many conditional jumps are there?")
    print("2. What are the jump targets?")
    print("3. Trace the execution path for x=15, x=7, x=3")

def exercise_3():
    """Exercise 3: Loop analysis"""
    print("\n" + "="*50)
    print("EXERCISE 3: Loop Analysis")
    print("="*50)
    
    def loop_function(n):
        total = 0
        for i in range(n):
            total += i
        return total
    
    print("Analyze the loop structure:")
    dis.dis(loop_function)
    
    print("\nQuestions:")
    print("1. How is the loop implemented in bytecode?")
    print("2. What bytecode instructions handle the iteration?")
    print("3. What does this function calculate?")

if __name__ == "__main__":
    print("Python Reverse Engineering Lab - Beginner Level")
    print("=" * 60)
    
    # Run basic analysis
    analyze_bytecode()
    analyze_obfuscated()
    
    # Run exercises
    exercise_1()
    exercise_2()
    exercise_3()
    
    print("\n" + "="*60)
    print("Next steps:")
    print("1. Try modifying the functions and see how bytecode changes")
    print("2. Experiment with different Python constructs")
    print("3. Move to intermediate exercises")