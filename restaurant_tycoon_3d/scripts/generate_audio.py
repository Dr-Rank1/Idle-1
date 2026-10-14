#!/usr/bin/env python3
import os
import wave
import struct
import math
import random

def create_wav(filename, samples, sample_rate=44100):
    os.makedirs(os.path.dirname(filename), exist_ok=True)
    with wave.open(filename, 'w') as wav_file:
        wav_file.setnchannels(1) # mono
        wav_file.setsampwidth(2) # 16-bit
        wav_file.setframerate(sample_rate)
        
        raw_data = bytearray()
        for s in samples:
            # clamp to -1.0 .. 1.0
            s = max(-1.0, min(1.0, s))
            val = int(s * 32767.0)
            raw_data.extend(struct.pack('<h', val))
        wav_file.writeframes(raw_data)
    print(f"Generated {filename} ({len(samples)} samples)")

def generate_coin_sfx():
    # Crisp, bright double-chime coin payout (B5 987 Hz -> E6 1318 Hz)
    sr = 44100
    duration = 0.35
    total_samples = int(sr * duration)
    samples = []
    
    for i in range(total_samples):
        t = i / sr
        env1 = math.exp(-t * 22.0)
        s1 = math.sin(2.0 * math.pi * 987.77 * t) * env1
        
        # Second higher sparkle chime starts at 0.08s
        s2 = 0.0
        if t > 0.08:
            t2 = t - 0.08
            env2 = math.exp(-t2 * 18.0)
            s2 = (math.sin(2.0 * math.pi * 1318.5 * t2) + 0.4 * math.sin(2.0 * math.pi * 2637.0 * t2)) * env2
            
        sample = (s1 * 0.45 + s2 * 0.55) * 0.7
        samples.append(sample)
        
    create_wav("assets/audio/coin_payout.wav", samples, sr)

def generate_order_bell_sfx():
    # Kitchen service bell "Ding!" (2093 Hz C7 with lingering rich metallic overtones)
    sr = 44100
    duration = 0.6
    total_samples = int(sr * duration)
    samples = []
    
    for i in range(total_samples):
        t = i / sr
        env = math.exp(-t * 8.5)
        # Fund 2093Hz + 4186Hz overtone + metallic 5420Hz ring
        s = math.sin(2.0 * math.pi * 2093.0 * t) * 0.65
        s += math.sin(2.0 * math.pi * 4186.0 * t) * 0.25
        s += math.sin(2.0 * math.pi * 5420.0 * t) * 0.15
        sample = s * env * 0.65
        samples.append(sample)
        
    create_wav("assets/audio/order_bell.wav", samples, sr)

def generate_upgrade_fanfare_sfx():
    # Joyful arpeggio fanfare (C5 523 -> E5 659 -> G5 784 -> C6 1046)
    sr = 44100
    duration = 0.75
    total_samples = int(sr * duration)
    samples = []
    
    notes = [
        (0.00, 523.25, 0.14),
        (0.12, 659.25, 0.14),
        (0.24, 783.99, 0.14),
        (0.36, 1046.50, 0.38)
    ]
    
    for i in range(total_samples):
        t = i / sr
        sample = 0.0
        for start_t, freq, note_dur in notes:
            if t >= start_t and t < start_t + note_dur + 0.15:
                dt = t - start_t
                env = math.exp(-dt * 7.0)
                # rich brass/synth wave
                w = math.sin(2.0 * math.pi * freq * dt) * 0.7
                w += math.sin(2.0 * math.pi * freq * 2.0 * dt) * 0.25
                w += math.sin(2.0 * math.pi * freq * 3.0 * dt) * 0.1
                sample += w * env * 0.4
        samples.append(sample)
        
    create_wav("assets/audio/upgrade_fanfare.wav", samples, sr)

def generate_angry_exit_sfx():
    # Low comical frustrated descending 'womp'
    sr = 44100
    duration = 0.4
    total_samples = int(sr * duration)
    samples = []
    
    for i in range(total_samples):
        t = i / sr
        freq = 240.0 - (t / duration) * 110.0 # drops from 240 to 130 Hz
        env = math.sin(math.pi * (t / duration)) ** 1.5
        s = math.sin(2.0 * math.pi * freq * t) + 0.3 * math.sin(4.0 * math.pi * freq * t)
        sample = s * env * 0.5
        samples.append(sample)
        
    create_wav("assets/audio/angry_exit.wav", samples, sr)

def generate_restaurant_ambience():
    # 6-second seamlessly looping cozy restaurant atmosphere:
    # Warm filtered room presence + gentle occasional soft porcelain/glass clinks + sizzle murmur
    sr = 44100
    duration = 6.0
    total_samples = int(sr * duration)
    samples = [0.0] * total_samples
    
    random.seed(42)
    
    # 1. Low warm ambient background drone (hum & murmur)
    for i in range(total_samples):
        t = i / sr
        # Low frequency gentle waves
        b = math.sin(2.0 * math.pi * 110.0 * t) * 0.04
        b += math.sin(2.0 * math.pi * 146.8 * t + 0.4) * 0.03
        b += math.sin(2.0 * math.pi * 220.0 * t + 0.8) * 0.02
        samples[i] = b
        
    # 2. Pink noise texture (chatter presence)
    b0 = 0.0
    b1 = 0.0
    b2 = 0.0
    for i in range(total_samples):
        white = random.uniform(-1.0, 1.0)
        b0 = 0.99765 * b0 + white * 0.0990460
        b1 = 0.96300 * b1 + white * 0.2965164
        b2 = 0.57000 * b2 + white * 1.0526913
        pink = b0 + b1 + b2 + white * 0.1848
        samples[i] += pink * 0.015
        
    # 3. Soft gentle porcelain / glass clinks at random times
    clink_times = [0.75, 1.9, 3.2, 4.45, 5.3]
    clink_freqs = [2400.0, 3100.0, 2750.0, 3600.0, 2900.0]
    for ct, cf in zip(clink_times, clink_freqs):
        start_idx = int(ct * sr)
        clink_samples = int(0.12 * sr)
        for j in range(clink_samples):
            idx = (start_idx + j) % total_samples
            dt = j / sr
            env = math.exp(-dt * 45.0)
            c = math.sin(2.0 * math.pi * cf * dt) * env * 0.08
            samples[idx] += c

    create_wav("assets/audio/restaurant_ambience.wav", samples, sr)

def generate_button_click_sfx():
    # Tactile woody bubble pop / tap (650 Hz down to 250 Hz in 0.04s)
    sr = 44100
    duration = 0.05
    total_samples = int(sr * duration)
    samples = []
    for i in range(total_samples):
        t = i / sr
        freq = 680.0 - (t / duration) * 380.0
        env = math.exp(-t * 80.0)
        s = math.sin(2.0 * math.pi * freq * t) * env * 0.45
        samples.append(s)
    create_wav("assets/audio/button_click.wav", samples, sr)

def generate_claim_reward_sfx():
    # Sparkly triumphal harp arpeggio (F5 -> A5 -> C6 -> E6 -> G6)
    sr = 44100
    duration = 0.65
    total_samples = int(sr * duration)
    samples = []
    notes = [
        (0.00, 698.46, 0.12),
        (0.08, 880.00, 0.12),
        (0.16, 1046.50, 0.12),
        (0.24, 1318.51, 0.12),
        (0.32, 1567.98, 0.32)
    ]
    for i in range(total_samples):
        t = i / sr
        sample = 0.0
        for start_t, freq, note_dur in notes:
            if t >= start_t:
                dt = t - start_t
                env = math.exp(-dt * 9.0)
                w = math.sin(2.0 * math.pi * freq * dt) * 0.65
                w += math.sin(2.0 * math.pi * freq * 2.0 * dt) * 0.25
                sample += w * env * 0.4
        samples.append(sample)
    create_wav("assets/audio/quest_claim.wav", samples, sr)

if __name__ == "__main__":
    generate_coin_sfx()
    generate_order_bell_sfx()
    generate_upgrade_fanfare_sfx()
    generate_angry_exit_sfx()
    generate_restaurant_ambience()
    generate_button_click_sfx()
    generate_claim_reward_sfx()
    print("All audio generated successfully!")
