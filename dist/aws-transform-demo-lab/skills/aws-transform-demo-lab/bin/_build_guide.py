#!/usr/bin/env python3
"""Markdown -> self-contained HTML with variable interpolation, copy buttons,
checkbox progress persisted in localStorage, and variable tooltips.

Markdown dialect (minimal, deliberately lazy):
  # H1 title
  ## H2 section
  ### H3 milestone (becomes a checkbox-trackable step)
  normal paragraphs
  - bullet
  ```bash :: short explanation of the command block
  atx -t --profile {{AWS_PROFILE}}
  ```
  {{VAR}} tokens interpolate from lab.env; unknown ones render as a tooltip asking to re-run setup.
"""
import argparse, html, os, pathlib, re, sys

VAR_DESCRIPTIONS = {
    "AWS_PROFILE":  "Isengard sandbox profile; the account AWS Transform runs against.",
    "AWS_REGION":   "Region hosting the atx ct server and Transform campaigns.",
    "GIT_REMOTE":   "Remote the 21-repo estate is pushed to; blank = local only.",
    "RUN_LOCATION": "local-mac | local-win | aws-cloudshell — chosen at setup.",
    "PARALLELISM":  "Max concurrent atx jobs (run-atx-all.sh, run-ara-moda.sh).",
    "LAB_ROOT":     "Absolute path to this skill on disk.",
    "WORKSPACE":    "Where estate split-out repos live (~/atx-demo-workspace by default).",
    "CAMPAIGN_ID":  "AWS Transform campaign id — fill in after you create the campaign in the web app.",
}

def load_env(env_path):
    env = {}
    for line in pathlib.Path(env_path).read_text().splitlines():
        if not line or line.startswith("#") or "=" not in line: continue
        k, v = line.split("=", 1); env[k.strip()] = v.strip()
    return env

def interp(text, env):
    def repl(m):
        key = m.group(1)
        val = env.get(key, "")
        desc = VAR_DESCRIPTIONS.get(key, "variable")
        if val:
            shown = html.escape(val); css = "var-set"
        else:
            shown = f"&lt;{key}&gt;"; css = "var-unset"
        return f'<span class="var {css}" title="{html.escape(desc)}">{shown}</span>'
    return re.sub(r"\{\{([A-Z_]+)\}\}", repl, text)

def md_to_html(md_text, env):
    out = []
    lines = md_text.splitlines()
    i = 0
    in_ul = False
    milestone_idx = 0
    while i < len(lines):
        line = lines[i]
        # fenced code
        m = re.match(r"^```(\w+)?(?:\s*::\s*(.*))?$", line)
        if m:
            lang = m.group(1) or ""
            caption = (m.group(2) or "").strip()
            i += 1
            buf = []
            while i < len(lines) and not lines[i].startswith("```"):
                buf.append(lines[i]); i += 1
            i += 1  # skip closing ```
            raw = "\n".join(buf)
            interpolated = interp(html.escape(raw), env)
            cap_html = f'<div class="cap">{html.escape(caption)}</div>' if caption else ""
            out.append(
                f'<div class="cmd">{cap_html}'
                f'<button class="copy" onclick="copyCmd(this)">copy</button>'
                f'<pre data-raw="{html.escape(raw)}"><code class="lang-{lang}">{interpolated}</code></pre>'
                f'</div>'
            )
            continue
        # headings
        if line.startswith("### "):
            if in_ul: out.append("</ul>"); in_ul = False
            milestone_idx += 1
            mid = f"m{milestone_idx}"
            title = interp(html.escape(line[4:]), env)
            out.append(
                f'<h3 id="{mid}" class="milestone">'
                f'<input type="checkbox" class="step" data-id="{mid}"> '
                f'<label for="{mid}">{title}</label></h3>'
            )
            i += 1; continue
        if line.startswith("## "):
            if in_ul: out.append("</ul>"); in_ul = False
            out.append(f"<h2>{interp(html.escape(line[3:]), env)}</h2>"); i += 1; continue
        if line.startswith("# "):
            if in_ul: out.append("</ul>"); in_ul = False
            out.append(f"<h1>{interp(html.escape(line[2:]), env)}</h1>"); i += 1; continue
        if line.startswith("- "):
            if not in_ul: out.append("<ul>"); in_ul = True
            out.append(f"<li>{interp(html.escape(line[2:]), env)}</li>"); i += 1; continue
        if not line.strip():
            if in_ul: out.append("</ul>"); in_ul = False
            i += 1; continue
        if in_ul: out.append("</ul>"); in_ul = False
        out.append(f"<p>{interp(html.escape(line), env)}</p>"); i += 1
    if in_ul: out.append("</ul>")
    return "\n".join(out)

TEMPLATE = """<!doctype html>
<html lang=en><meta charset=utf-8>
<title>__TITLE__</title>
<style>
  :root { --bg:#0b0f14; --fg:#e6edf3; --muted:#8b96a3; --accent:#5cc8ff; --ok:#3fb950; --warn:#f0883e; --box:#121820; --border:#223040; }
  body { font:16px/1.55 ui-sans-serif,system-ui,-apple-system,sans-serif; background:var(--bg); color:var(--fg); max-width:980px; margin:0 auto; padding:2rem 1.25rem 6rem; }
  h1 { font-size:1.9rem; border-bottom:1px solid var(--border); padding-bottom:.4rem; }
  h2 { font-size:1.35rem; margin-top:2rem; color:var(--accent); }
  h3.milestone { background:var(--box); border:1px solid var(--border); border-radius:8px; padding:.6rem .8rem; display:flex; align-items:center; gap:.6rem; font-size:1.05rem; }
  h3.milestone.done { opacity:.55; text-decoration:line-through; }
  h3.milestone input { transform:scale(1.25); accent-color:var(--ok); }
  .cmd { position:relative; margin:.6rem 0 1.1rem; }
  .cmd .cap { color:var(--muted); font-size:.85rem; margin-bottom:.25rem; font-style:italic; }
  pre { background:#0d1117; border:1px solid var(--border); border-radius:8px; padding:.8rem 1rem; overflow-x:auto; }
  code { font:13.5px/1.5 ui-monospace,SFMono-Regular,Menlo,monospace; }
  .copy { position:absolute; top:.35rem; right:.4rem; background:var(--box); color:var(--fg); border:1px solid var(--border); border-radius:5px; font-size:.75rem; padding:.2rem .5rem; cursor:pointer; }
  .copy:hover { background:var(--border); }
  .var { border-bottom:1px dotted var(--muted); cursor:help; }
  .var-set { color:var(--ok); }
  .var-unset { color:var(--warn); }
  .progress-bar { position:fixed; top:0; left:0; right:0; height:4px; background:transparent; z-index:10; }
  .progress-bar > div { height:100%; background:var(--ok); width:0; transition:width .2s; }
  .toolbar { position:fixed; bottom:1rem; right:1rem; background:var(--box); border:1px solid var(--border); border-radius:8px; padding:.6rem .8rem; font-size:.85rem; display:flex; gap:.6rem; align-items:center; }
  .toolbar button { background:var(--border); color:var(--fg); border:0; border-radius:5px; padding:.3rem .6rem; cursor:pointer; }
  ul { padding-left:1.4rem; }
  li { margin:.2rem 0; }
  a { color:var(--accent); }
</style>
<div class=progress-bar><div id=pb></div></div>
__BODY__
<div class=toolbar>
  <span id=count>0 / 0</span>
  <button onclick="resetProgress()">reset progress</button>
</div>
<script>
  const KEY = "demo-lab-progress::__KEY__";
  const steps = [...document.querySelectorAll(".step")];
  const saved = JSON.parse(localStorage.getItem(KEY) || "{}");
  steps.forEach(cb => {
    cb.checked = !!saved[cb.dataset.id];
    cb.closest("h3").classList.toggle("done", cb.checked);
    cb.addEventListener("change", () => {
      saved[cb.dataset.id] = cb.checked;
      localStorage.setItem(KEY, JSON.stringify(saved));
      cb.closest("h3").classList.toggle("done", cb.checked);
      updateProgress();
    });
  });
  function updateProgress() {
    const done = steps.filter(s => s.checked).length;
    document.getElementById("count").textContent = done + " / " + steps.length;
    document.getElementById("pb").style.width = steps.length ? (100*done/steps.length) + "%" : "0";
  }
  function resetProgress() {
    if (!confirm("Clear all checkboxes for this guide?")) return;
    localStorage.removeItem(KEY);
    steps.forEach(cb => { cb.checked = false; cb.closest("h3").classList.remove("done"); });
    updateProgress();
  }
  function copyCmd(btn) {
    const raw = btn.parentElement.querySelector("pre").dataset.raw;
    navigator.clipboard.writeText(raw).then(() => {
      const t = btn.textContent; btn.textContent = "copied"; setTimeout(()=>btn.textContent=t, 1200);
    });
  }
  updateProgress();
</script>
"""

def build(src_dir, out_dir, env):
    src = pathlib.Path(src_dir); out = pathlib.Path(out_dir)
    out.mkdir(parents=True, exist_ok=True)
    for md in sorted(src.glob("*.md")):
        text = md.read_text()
        title_match = re.search(r"^# (.+)$", text, re.M)
        title = title_match.group(1) if title_match else md.stem
        body = md_to_html(text, env)
        html_out = (TEMPLATE
                    .replace("__TITLE__", html.escape(title))
                    .replace("__KEY__", md.stem)
                    .replace("__BODY__", body))
        (out / f"{md.stem}.html").write_text(html_out)
        print(f"  built {md.stem}.html")

if __name__ == "__main__":
    ap = argparse.ArgumentParser()
    ap.add_argument("--src", required=True); ap.add_argument("--out", required=True); ap.add_argument("--env", required=True)
    a = ap.parse_args()
    build(a.src, a.out, load_env(a.env))

# ponytail: single-file generator, no jinja/pandoc. Add a real md engine only if we outgrow this (headings, lists, fences, vars — covers 100% of guide content).

# Self-check:
def _demo():
    env = {"AWS_PROFILE": "sbx", "AWS_REGION": "us-west-2"}
    out = md_to_html("# T\n## S\n### M\n- a\n```bash :: cap\nX {{AWS_PROFILE}} {{MISSING}}\n```\n", env)
    assert 'id="m1"' in out and "sbx" in out and "&lt;MISSING&gt;" in out and 'class="copy"' in out, out
    print("self-check ok")

if __name__ == "__main__" and os.environ.get("SELFTEST"):
    _demo()
