import os
import wave
import math
import random
import struct

def make_wav(filepath, duration, sample_rate=44100, generator_func=None):
    os.makedirs(os.path.dirname(filepath), exist_ok=True)
    num_samples = int(duration * sample_rate)
    with wave.open(filepath, 'w') as wav_file:
        wav_file.setnchannels(1) # Mono
        wav_file.setsampwidth(2) # 16-bit PCM
        wav_file.setframerate(sample_rate)
        
        frames = bytearray()
        for i in range(num_samples):
            t = i / float(sample_rate)
            val = generator_func(t, duration) if generator_func else 0.0
            val = max(-1.0, min(1.0, val))
            sample = int(val * 32767.0)
            frames.extend(struct.pack('<h', sample))
        wav_file.writeframes(frames)

# Generator functions for various SFX types
def gen_laser(t, dur):
    freq = 800.0 * (1.0 - (t / dur) ** 0.5) + 100.0
    env = (1.0 - t / dur)
    return math.sin(2.0 * math.pi * freq * t) * env * 0.5

def gen_slash(t, dur):
    noise = random.uniform(-1.0, 1.0)
    freq = 600.0 * (1.0 - t / dur) + 150.0
    env = math.sin(math.pi * t / dur)
    return (noise * 0.6 + math.sin(2.0 * math.pi * freq * t) * 0.4) * env * 0.6

def gen_hit(t, dur):
    freq = 150.0 * (1.0 - t / dur) + 40.0
    noise = random.uniform(-1.0, 1.0)
    env = math.exp(-t * 25.0)
    return (math.sin(2.0 * math.pi * freq * t) * 0.6 + noise * 0.4) * env * 0.7

def gen_crit(t, dur):
    freq = 1200.0 * (1.0 - t / dur) + 300.0
    env = math.exp(-t * 15.0)
    harmon = math.sin(2.0 * math.pi * freq * t) + 0.5 * math.sin(4.0 * math.pi * freq * t)
    return harmon * env * 0.5

def gen_jump(t, dur):
    freq = 150.0 + 400.0 * (t / dur)**2
    env = 1.0 - t / dur
    return math.sin(2.0 * math.pi * freq * t) * env * 0.4

def gen_dash(t, dur):
    noise = random.uniform(-1.0, 1.0)
    env = math.sin(math.pi * t / dur)
    return noise * env * 0.4

def gen_pickup(t, dur):
    f1 = 440.0 if t < dur * 0.5 else 880.0
    env = 1.0 - t / dur
    return math.sin(2.0 * math.pi * f1 * t) * env * 0.4

def gen_level_up(t, dur):
    notes = [261.63, 329.63, 392.00, 523.25] # C E G C
    idx = min(int(t / (dur / 4.0)), 3)
    freq = notes[idx]
    env = 1.0 - (t % (dur / 4.0)) / (dur / 4.0)
    return math.sin(2.0 * math.pi * freq * t) * env * 0.5

def gen_explosion(t, dur):
    noise = random.uniform(-1.0, 1.0)
    env = math.exp(-t * 8.0)
    sub = math.sin(2.0 * math.pi * 50.0 * t)
    return (noise * 0.7 + sub * 0.3) * env * 0.8

def gen_boss_roar(t, dur):
    noise = random.uniform(-1.0, 1.0)
    mod = math.sin(2.0 * math.pi * 12.0 * t)
    freq = 80.0 + mod * 30.0
    env = math.sin(math.pi * t / dur)
    return (noise * 0.5 + math.sin(2.0 * math.pi * freq * t) * 0.5) * env * 0.8

def gen_bgm_ambient(t, dur):
    # Ambient sci-fi drone with subtle chord modulation
    f1 = 110.0 + math.sin(2.0 * math.pi * 0.1 * t) * 2.0 # A2
    f2 = 164.81 + math.sin(2.0 * math.pi * 0.15 * t) * 3.0 # E3
    f3 = 220.0 + math.sin(2.0 * math.pi * 0.08 * t) * 4.0 # A3
    synth = 0.4 * math.sin(2.0 * math.pi * f1 * t) + 0.3 * math.sin(2.0 * math.pi * f2 * t) + 0.2 * math.sin(2.0 * math.pi * f3 * t)
    return synth * 0.3

def main():
    base_dir = "d:/DULIEU/lamgame/Roguelands/audio"
    print("Generating procedural WAV audio assets in res://audio/ ...")
    
    make_wav(f"{base_dir}/sfx/attack_laser.wav", 0.15, generator_func=gen_laser)
    make_wav(f"{base_dir}/sfx/attack_slash.wav", 0.18, generator_func=gen_slash)
    make_wav(f"{base_dir}/sfx/hit.wav", 0.12, generator_func=gen_hit)
    make_wav(f"{base_dir}/sfx/crit.wav", 0.20, generator_func=gen_crit)
    make_wav(f"{base_dir}/sfx/jump.wav", 0.18, generator_func=gen_jump)
    make_wav(f"{base_dir}/sfx/dash.wav", 0.20, generator_func=gen_dash)
    make_wav(f"{base_dir}/sfx/pickup.wav", 0.22, generator_func=gen_pickup)
    make_wav(f"{base_dir}/sfx/level_up.wav", 0.60, generator_func=gen_level_up)
    make_wav(f"{base_dir}/sfx/explosion.wav", 0.45, generator_func=gen_explosion)
    make_wav(f"{base_dir}/sfx/boss_roar.wav", 1.20, generator_func=gen_boss_roar)
    
    make_wav(f"{base_dir}/music/ambient_hub.wav", 4.0, generator_func=gen_bgm_ambient)
    make_wav(f"{base_dir}/music/planet_combat.wav", 4.0, generator_func=gen_bgm_ambient)
    
    print("Audio asset generation complete!")

if __name__ == "__main__":
    main()
