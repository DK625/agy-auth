#!/usr/bin/env python3
# -*- coding: utf-8 -*-
"""
Cross-Platform Statusline for Google Antigravity CLI (agy)
Zero-dependency, high-performance script utilizing Python Standard Library.
"""

import sys
import json
import os
import math
from datetime import datetime

# Ensure stdout/stdin uses UTF-8 encoding
if sys.platform == "win32":
    try:
        sys.stdout.reconfigure(encoding="utf-8")
        sys.stdin.reconfigure(encoding="utf-8")
    except Exception:
        pass

# ─── Unicode Characters ──────────────────────────────────────────────────────────
CHAR_CIRCLE_FULL  = "●"
CHAR_CIRCLE_EMPTY = "○"
CHAR_DIAMOND     = "◆"
CHAR_GEAR        = "⚙"
CHAR_WRENCH      = "🔧"
CHAR_HOURGLASS   = "⌛"
CHAR_BLOCK_FULL   = "█"
CHAR_BLOCK_DARK   = "▓"
CHAR_BLOCK_MED    = "▒"
CHAR_BLOCK_LIGHT  = "░"
CHAR_DOT         = "·"
CHAR_SLASH       = "/"
CHAR_PIPE        = "│"
CHAR_CORNER_TOP   = "╭"
CHAR_LINE        = "─"
CHAR_CORNER_BOT   = "╰"
CHAR_JOIN        = "├"
CHAR_RESET       = "⟳"

# ─── ANSI Colors & Formatting ───────────────────────────────────────────────────
ESC = "\033"
R = f"{ESC}[0m"          # Reset
B = f"{ESC}[1m"          # Bold
D = f"{ESC}[2m"          # Dim
I = f"{ESC}[3m"          # Italic

FG_GREEN          = f"{ESC}[32m"
FG_YELLOW         = f"{ESC}[33m"
FG_CYAN           = f"{ESC}[36m"
FG_MAGENTA        = f"{ESC}[35m"
FG_WHITE          = f"{ESC}[37m"
FG_GRAY           = f"{ESC}[90m"
FG_BRIGHT_RED     = f"{ESC}[91m"
FG_BRIGHT_GREEN   = f"{ESC}[92m"
FG_BRIGHT_YELLOW  = f"{ESC}[93m"
FG_BRIGHT_BLUE    = f"{ESC}[94m"
FG_BRIGHT_MAGENTA = f"{ESC}[95m"
FG_BRIGHT_CYAN    = f"{ESC}[96m"
FG_BRIGHT_WHITE   = f"{ESC}[97m"

NUM_COLOR = f"{FG_BRIGHT_WHITE}{B}"

# ─── Configuration Constants ────────────────────────────────────────────────────
CONFIG_LAYOUT_WIDE_COLS = 120
CONFIG_LAYOUT_MED_COLS  = 100
CONFIG_BAR_LEN_CTX      = 15
CONFIG_BAR_LEN_QUOTA    = 10
CONFIG_CTX_WARN_PCT     = 60
CONFIG_CTX_CRIT_PCT     = 90

def get_safe_float(val, default=0.0):
    try:
        return float(val) if val is not None else default
    except (ValueError, TypeError):
        return default

def get_quota_color(pct):
    if pct <= 10:
        return FG_BRIGHT_RED
    if pct <= 25:
        return FG_BRIGHT_YELLOW
    if pct <= 50:
        return FG_BRIGHT_CYAN
    return FG_BRIGHT_GREEN

def get_quota_bar(pct, width=CONFIG_BAR_LEN_QUOTA):
    clamped = max(0.0, min(100.0, pct))
    filled = int(round((clamped * width) / 100.0))
    empty = max(0, width - filled)
    color = get_quota_color(int(clamped))
    return f"{color}{CHAR_CIRCLE_FULL * filled}{FG_GRAY}{CHAR_CIRCLE_EMPTY * empty}{R}"

def format_reset_time(iso_str, time_format):
    if not iso_str or iso_str == "null":
        return ""
    try:
        iso_clean = iso_str.replace("Z", "+00:00")
        dt = datetime.fromisoformat(iso_clean).astimezone()
        return dt.strftime(time_format).lower()
    except Exception:
        return ""

def get_quota_line(label, quota_dict, time_format):
    if not quota_dict:
        return None
    rem_frac = get_safe_float(quota_dict.get("remaining_fraction"), 1.0)
    pct = max(0, min(100, int(round(rem_frac * 100))))
    q_bar = get_quota_bar(pct)
    pct_fmt = f"{pct:>3}%"
    p_color = get_quota_color(pct)
    
    reset_str = format_reset_time(quota_dict.get("reset_time"), time_format)
    reset_badge = f" {FG_GRAY}{CHAR_RESET}{R} {FG_WHITE}{reset_str}{R}" if reset_str else ""
    return f"{FG_WHITE}{label}{R} {q_bar} {p_color}{pct_fmt}{R}{reset_badge}"

def main():
    try:
        raw_input = sys.stdin.read().strip()
        if not raw_input:
            print("agy")
            sys.exit(0)
        data = json.loads(raw_input)
    except Exception:
        print("agy")
        sys.exit(0)

    # ─── Load Optional Configuration (~/.gemini/statusline.json) ────────────────
    config = {
        "show_quota": True,
        "show_additional_stats": True,
        "hide_zero_stats": True,
        "show_state_indicator": True
    }
    config_path = os.path.expanduser("~/.gemini/statusline.json")
    if os.path.exists(config_path):
        try:
            with open(config_path, "r", encoding="utf-8") as f:
                user_conf = json.load(f)
                config.update(user_conf)
        except Exception:
            pass

    # ─── Extract Fields ─────────────────────────────────────────────────────────
    state = data.get("agent_state") or "idle"
    ctx_obj = data.get("context_window") or {}
    used_pct = get_safe_float(ctx_obj.get("used_percentage"), 0.0)
    
    vcs = data.get("vcs") or {}
    vcs_branch = vcs.get("branch") or ""
    vcs_dirty = bool(vcs.get("dirty", False))
    
    sandbox = data.get("sandbox") or {}
    sandbox_enabled = bool(sandbox.get("enabled", False))
    
    artifact_count = int(get_safe_float(data.get("artifact_count"), 0))
    subagents = data.get("subagents")
    subagent_count = len(subagents) if isinstance(subagents, list) else (1 if subagents else 0)
    task_count = int(get_safe_float(data.get("task_count"), 0))
    
    model = data.get("model") or {}
    model_name = model.get("display_name") or ""
    model_id = str(model.get("id") or "").lower()
    plan_tier = data.get("plan_tier") or ""
    cols = int(get_safe_float(data.get("terminal_width"), 80))

    cwd = data.get("cwd") or ""
    dir_name = os.path.basename(os.path.normpath(cwd)) if cwd else ""

    # ─── Build Line 1: State / Model / VCS Branch ───────────────────────────────
    parts_1 = []
    if config["show_state_indicator"]:
        state_map = {
            "idle": f"{FG_BRIGHT_GREEN}{B}{CHAR_CIRCLE_FULL} READY{R}",
            "thinking": f"{FG_BRIGHT_YELLOW}{B}{CHAR_DIAMOND} THINKING{R}",
            "working": f"{FG_BRIGHT_CYAN}{B}{CHAR_GEAR} WORKING{R}",
            "tool_use": f"{FG_BRIGHT_MAGENTA}{B}{CHAR_WRENCH} TOOL{R}",
        }
        parts_1.append(state_map.get(state, f"{FG_WHITE}{B}{CHAR_HOURGLASS} {state.upper()}{R}"))

    if model_name:
        parts_1.append(f"{FG_BRIGHT_MAGENTA}{I}{model_name}{R}")

    if dir_name:
        git_badge = f"{FG_BRIGHT_CYAN}{dir_name}{R}"
        if vcs_branch:
            if vcs_dirty:
                git_badge += f" {FG_BRIGHT_GREEN}({FG_BRIGHT_RED}{vcs_branch}{FG_BRIGHT_YELLOW}*{FG_BRIGHT_GREEN}){R}"
            else:
                git_badge += f" {FG_BRIGHT_GREEN}({FG_BRIGHT_BLUE}{vcs_branch}{FG_BRIGHT_GREEN}){R}"
        parts_1.append(git_badge)

    line1 = f" {FG_GRAY}{CHAR_SLASH}{R} ".join(parts_1)

    # ─── Build Line 2: Context Bar & Stats ──────────────────────────────────────
    rem_pct = max(0.0, min(100.0, 100.0 - used_pct))
    filled_ctx = int(math.floor((rem_pct * CONFIG_BAR_LEN_CTX) / 100.0))
    remainder_ctx = (rem_pct * CONFIG_BAR_LEN_CTX) % 100.0

    bar_color = FG_BRIGHT_WHITE
    if rem_pct <= (100 - CONFIG_CTX_CRIT_PCT):
        bar_color = FG_BRIGHT_RED
    elif rem_pct <= (100 - CONFIG_CTX_WARN_PCT):
        bar_color = FG_BRIGHT_YELLOW

    bar_chars = []
    for idx in range(CONFIG_BAR_LEN_CTX):
        if idx < filled_ctx:
            bar_chars.append(CHAR_BLOCK_FULL)
        elif idx == filled_ctx:
            if remainder_ctx >= 75:
                bar_chars.append(CHAR_BLOCK_DARK)
            elif remainder_ctx >= 50:
                bar_chars.append(CHAR_BLOCK_MED)
            elif remainder_ctx >= 25:
                bar_chars.append(CHAR_BLOCK_LIGHT)
            else:
                bar_chars.append(CHAR_DOT)
        else:
            bar_chars.append(CHAR_DOT)

    ctx_badge = f"{FG_GRAY}ctx {bar_color}{''.join(bar_chars)} {NUM_COLOR}{rem_pct:.1f}%{R}"
    stat_parts = [ctx_badge]

    if config["show_additional_stats"]:
        if not config["hide_zero_stats"] or artifact_count > 0:
            stat_parts.append(f"{FG_GRAY}artifacts {NUM_COLOR}{artifact_count}{R}")
        if not config["hide_zero_stats"] or subagent_count > 0:
            stat_parts.append(f"{FG_GRAY}subagents {NUM_COLOR}{subagent_count}{R}")
        if not config["hide_zero_stats"] or task_count > 0:
            stat_parts.append(f"{FG_GRAY}tasks {NUM_COLOR}{task_count}{R}")
        if sandbox_enabled:
            stat_parts.append(f"{FG_GRAY}sandbox {FG_BRIGHT_GREEN}{B}ON{R}")
        elif not config["hide_zero_stats"]:
            stat_parts.append(f"{FG_GRAY}sandbox off{R}")

    line2 = " " + f" {FG_GRAY}{CHAR_DOT}{R} ".join(stat_parts)

    # ─── Build Quotas ───────────────────────────────────────────────────────────
    quota_lines = []
    quotas = data.get("quota") or {}
    if config["show_quota"] and quotas:
        is_3p = any(x in model_id for x in ["claude", "anthropic", "3p"])
        pool_prefix = "3p" if is_3p else "gemini"
        pool_label = "claude" if is_3p else "gemini"

        q_5h = quotas.get(f"{pool_prefix}-5h")
        q_wk = quotas.get(f"{pool_prefix}-weekly")

        line_5h = get_quota_line(f"{pool_label} 5h", q_5h, "%H:%M")
        if line_5h:
            quota_lines.append(line_5h)

        line_wk = get_quota_line(f"{pool_label} 7d", q_wk, "%b %d, %H:%M")
        if line_wk:
            quota_lines.append(line_wk)

    if plan_tier and plan_tier != "null":
        quota_lines.insert(0, f"{FG_GRAY}plan:{R} {FG_WHITE}{plan_tier}{R}")

    # ─── Render Layout Based on Terminal Width ──────────────────────────────────
    if cols >= CONFIG_LAYOUT_WIDE_COLS:
        print(f"{line1}{FG_GRAY}  {CHAR_PIPE}  {R}{line2}")
    elif cols >= CONFIG_LAYOUT_MED_COLS:
        print(f"{FG_GRAY}{CHAR_CORNER_TOP}{CHAR_LINE}{R} {line1}")
        print(f"{FG_GRAY}{CHAR_CORNER_BOT}{CHAR_LINE}{R}{line2}")
    else:
        print(f"{FG_GRAY}{CHAR_CORNER_TOP}{CHAR_LINE}{R} {line1}")
        print(f"{FG_GRAY}{CHAR_JOIN}{CHAR_LINE}{R} {ctx_badge}")
        if len(stat_parts) > 1:
            extra = " " + f" {FG_GRAY}{CHAR_DOT}{R} ".join(stat_parts[1:])
            print(f"{FG_GRAY}{CHAR_CORNER_BOT}{CHAR_LINE}{R}{extra}")
        else:
            print(f"{FG_GRAY}{CHAR_CORNER_BOT}{CHAR_LINE}{R}")

    for ql in quota_lines:
        print(ql)
    print("")

if __name__ == "__main__":
    main()
