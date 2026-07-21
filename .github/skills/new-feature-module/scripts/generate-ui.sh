#!/usr/bin/env bash
# generate-ui.sh — Generate custom UI template overrides from a UI manifest.
#
# Membaca file manifest YAML yang mendeskripsikan layout custom (hasil analisis
# wireframe oleh analyst), lalu generate template override yang bisa digunakan
# oleh scaffold.sh --custom-ui.
#
# Usage:
#   .github/skills/new-feature-module/scripts/generate-ui.sh <feature> <manifest>
#   .github/skills/new-feature-module/scripts/generate-ui.sh blog .github/specs/blog-ui.yaml
#
# Arguments:
#   <feature>   Nama fitur (kebab-case)
#   <manifest>  Path ke file YAML/JSON manifest UI
#
# Output:
#   /tmp/<feature>-ui/  — folder dengan template override untuk scaffold --custom-ui
#
# Must be run from the repo root.

set -euo pipefail

FEATURE="${1:-}"
MANIFEST="${2:-}"

if [[ -z "$FEATURE" || -z "$MANIFEST" ]]; then
  echo "Usage: generate-ui.sh <feature> <manifest>" >&2
  echo "  Example: generate-ui.sh blog .github/specs/blog-ui.yaml" >&2
  exit 1
fi

if [[ ! -f "$MANIFEST" ]]; then
  echo "Error: manifest not found: ${MANIFEST}" >&2
  exit 1
fi

OUTDIR="/tmp/${FEATURE}-ui"
mkdir -p "$OUTDIR/templates"

echo "── Generating custom UI for: ${FEATURE} ──"
echo "  Manifest: ${MANIFEST}"
echo "  Output:   ${OUTDIR}"
echo ""

# ── Parse manifest ──────────────────────────────────────────────
# Support both JSON and YAML (YAML via python3, JSON via jq)
PARSE_CMD=""
MANIFEST_TYPE=""

if command -v python3 &>/dev/null; then
  # Try YAML first, fallback to JSON
  PARSE_CMD="python3"
  MANIFEST_TYPE="yaml"
elif command -v jq &>/dev/null; then
  PARSE_CMD="jq"
  MANIFEST_TYPE="json"
else
  echo "Error: need python3 or jq to parse manifest" >&2
  exit 1
fi

# Helper: read a nested value from manifest
get_val() {
  local path="$1" default="${2:-}"
  if [[ "$MANIFEST_TYPE" == "json" || "$MANIFEST" == *.json ]]; then
    local v
    v=$(jq -r "$path // \"__NULL__\"" "$MANIFEST" 2>/dev/null || echo "__NULL__")
    [[ "$v" == "__NULL__" ]] && echo "$default" || echo "$v"
  elif command -v python3 &>/dev/null; then
    python3 -c "
import json, sys
try:
    # Try YAML first
    import yaml
    with open('$MANIFEST') as f: data = yaml.safe_load(f)
except ImportError:
    # Fallback to JSON
    with open('$MANIFEST') as f: data = json.load(f)

parts = '$path'.lstrip('.').split('.')
v = data
for p in parts:
    if '[' in p:
        k, i = p.split('[')
        i = int(i.strip(']'))
        v = v.get(k, [])[i] if isinstance(v, dict) else v[i]
    else:
        v = v.get(p, {}) if isinstance(v, dict) else {}
if v is None or v == {}:
    print('__NULL__')
else:
    print(json.dumps(v) if not isinstance(v, str) else v)
" 2>/dev/null || echo "$default"
  fi
}

# ── Detect layout type ──────────────────────────────────────────
LAYOUT=$(get_val "pages.list.layout" "stack")
echo "  Layout: ${LAYOUT}"

# ── Generate shell.html.tmpl ────────────────────────────────────
cat > "${OUTDIR}/shell.html.tmpl" << 'SHELL'
<!DOCTYPE html>
<html lang="en">
<head>
  <meta charset="UTF-8">
  <meta name="viewport" content="width=device-width, initial-scale=1.0">
  <title>{{.Title}}</title>
  <link rel="stylesheet" href="/static/css/app.min.css">
  {{if .Description}}<meta name="description" content="{{.Description}}">{{end}}
  <link rel="preload" href="/static/vendor/react.production.min.js" as="script" crossorigin>
  <link rel="preload" href="/static/vendor/react-dom.production.min.js" as="script" crossorigin>
  <script>
    (function(){try{var t=localStorage.getItem("theme")||"dark";document.documentElement.className=t==="light"?"light":""}catch(e){}})();
  </script>
  <style>body{opacity:0;animation:fadeIn .15s ease-out forwards}@keyframes fadeIn{to{opacity:1}}</style>
  <script>window.__PAGE__={{if .PageType}}"{{.PageType}}"{{else}}"list"{{end}};</script>
</head>
<body>
  <div id="__FEATURE__-root">{{if .InitialHTML}}{{.InitialHTML}}{{end}}</div>
  {{if .InitialDataJSON}}
  <script id="__FEATURE__-initial-data" type="application/json">{{.InitialDataJSON}}</script>
  <script>(function(){var e=document.getElementById("__FEATURE__-initial-data");window.__INITIAL_DATA__=JSON.parse(e.textContent);e.remove()})();</script>
  {{end}}
  <script src="/static/vendor/react.production.min.js"></script>
  <script src="/static/vendor/react-dom.production.min.js"></script>
  <script type="module" src="/static/__FEATURE__/dist/__FEATURE__.tsx.js"></script>
  <script>window.__MODULE_LOADED__=true;</script>
</body>
</html>
SHELL
echo "  ✓ shell.html.tmpl (default)"

# ── Generate detail.html.tmpl ───────────────────────────────────
mkdir -p "${OUTDIR}/templates"
cat > "${OUTDIR}/templates/detail.html.tmpl" << 'DETAIL'
<!DOCTYPE html>
<html lang="en">
<head>
  <meta charset="UTF-8">
  <meta name="viewport" content="width=device-width, initial-scale=1.0">
  <title>{{.Title}}</title>
  <link rel="stylesheet" href="/static/css/app.min.css">
  {{if .Description}}<meta name="description" content="{{.Description}}">{{end}}
  <link rel="preload" href="/static/vendor/react.production.min.js" as="script" crossorigin>
  <link rel="preload" href="/static/vendor/react-dom.production.min.js" as="script" crossorigin>
  <script>
    (function(){try{var t=localStorage.getItem("theme")||"dark";document.documentElement.className=t==="light"?"light":""}catch(e){}})();
  </script>
  <style>body{opacity:0;animation:fadeIn .15s ease-out forwards}@keyframes fadeIn{to{opacity:1}}</style>
  <script>window.__PAGE__={{if .PageType}}"{{.PageType}}"{{else}}"detail"{{end}};</script>
  {{if .ErrorMessage}}<script>window.__NOT_FOUND__=true;</script>{{end}}
</head>
<body>
  <div id="__FEATURE__-root">{{if .InitialHTML}}{{.InitialHTML}}{{else if .ErrorMessage}}<div class="max-w-[42rem] mx-auto px-4 py-6"><div class="text-center py-12 text-text-tertiary"><p class="text-sm m-0">{{.ErrorMessage}}</p><a href="/__FEATURE__" class="inline-flex items-center justify-center gap-1.5 h-9 px-3 rounded-lg text-xs font-medium border border-border-subtle bg-transparent text-text-secondary cursor-pointer transition-all hover:bg-accent-subtle hover:border-accent hover:text-accent active:scale-[.97] no-underline select-none mt-3">Back to __FEATURE_TITLE__</a></div></div>{{end}}</div>
  {{if .InitialDataJSON}}
  <script id="__FEATURE__-initial-data" type="application/json">{{.InitialDataJSON}}</script>
  <script>(function(){var e=document.getElementById("__FEATURE__-initial-data");window.__INITIAL_DATA__=JSON.parse(e.textContent);e.remove()})();</script>
  {{end}}
  <script src="/static/vendor/react.production.min.js"></script>
  <script src="/static/vendor/react-dom.production.min.js"></script>
  <script type="module" src="/static/__FEATURE__/dist/__FEATURE__.tsx.js"></script>
  <script>window.__MODULE_LOADED__=true;</script>
</body>
</html>
DETAIL
echo "  ✓ templates/detail.html.tmpl (default)"

# ── Generate Feature.tsx.tmpl (custom layout) ───────────────────
FTITLE=$(echo "$FEATURE" | awk -F'-' '{ for (i=1; i<=NF; i++) $i=toupper(substr($i,1,1)) substr($i,2); print }' OFS='')

# Build layout-specific template
case "$LAYOUT" in
  sidebar-content)
    # Layout: sidebar kiri (filter/nav) + konten kanan (list/detail)
    cat > "${OUTDIR}/Feature.tsx.tmpl" << CUSTOMTSX
import React, { useEffect, useState, useCallback, useMemo } from "react";
import { createRoot } from "react-dom/client";
import { list__FEATURE_TITLE__, create__FEATURE_TITLE__, update__FEATURE_TITLE__, delete__FEATURE_TITLE__, get__FEATURE_TITLE__ } from "./api";
import type { __FEATURE_TITLE__ as __FEATURE_TITLE__Type } from "./api";

declare global {
  interface Window {
    __INITIAL_DATA__?: __FEATURE_TITLE__Type[] | __FEATURE_TITLE__Type;
    __PAGE__?: "list" | "detail";
  }
}

// ── Theme ──
function toggleTheme() {
  const h = document.documentElement;
  h.classList.toggle("light");
  try { localStorage.setItem("theme", h.classList.contains("light") ? "light" : "dark"); } catch {}
}
function getInitialTheme(): boolean {
  if (typeof window === "undefined") return false;
  try { return localStorage.getItem("theme") === "light"; } catch { return false; }
}

// ── Icons ──
const I = {
  Sun: () => <svg className="w-3.5 h-3.5" viewBox="0 0 24 24" fill="none" stroke="currentColor" strokeWidth="2" strokeLinecap="round" strokeLinejoin="round"><circle cx="12" cy="12" r="5"/><path d="M12 1v2M12 21v2M4.22 4.22l1.42 1.42M18.36 18.36l1.42 1.42M1 12h2M21 12h2M4.22 19.78l1.42-1.42M18.36 5.64l1.42-1.42"/></svg>,
  Moon: () => <svg className="w-3.5 h-3.5" viewBox="0 0 24 24" fill="none" stroke="currentColor" strokeWidth="2" strokeLinecap="round" strokeLinejoin="round"><path d="M21 12.79A9 9 0 1 1 11.21 3 7 7 0 0 0 21 12.79z"/></svg>,
  Pen: () => <svg className="w-3 h-3" viewBox="0 0 24 24" fill="none" stroke="currentColor" strokeWidth="2" strokeLinecap="round" strokeLinejoin="round"><path d="M17 3a2.85 2.83 0 1 1 4 4L7.5 20.5 2 22l1.5-5.5Z"/></svg>,
  Trash: () => <svg className="w-3 h-3" viewBox="0 0 24 24" fill="none" stroke="currentColor" strokeWidth="2" strokeLinecap="round" strokeLinejoin="round"><path d="M3 6h18"/><path d="M19 6v14c0 1-1 2-2 2H7c-1 0-2-1-2-2V6"/><path d="M8 6V4c0-1 1-2 2-2h4c1 0 2 1 2 2v2"/></svg>,
  X: () => <svg className="w-3 h-3" viewBox="0 0 24 24" fill="none" stroke="currentColor" strokeWidth="2" strokeLinecap="round" strokeLinejoin="round"><path d="M18 6 6 18"/><path d="m6 6 12 12"/></svg>,
  ArrowLeft: () => <svg className="w-3.5 h-3.5" viewBox="0 0 24 24" fill="none" stroke="currentColor" strokeWidth="2" strokeLinecap="round" strokeLinejoin="round"><path d="m12 19-7-7 7-7"/><path d="M19 12H5"/></svg>,
  Plus: () => <svg className="w-3.5 h-3.5" viewBox="0 0 24 24" fill="none" stroke="currentColor" strokeWidth="2" strokeLinecap="round" strokeLinejoin="round"><path d="M12 5v14"/><path d="M5 12h14"/></svg>,
};

// ── Post Card ──
const __FEATURE_TITLE__Card = React.memo(function __FEATURE_TITLE__Card({ post, onDelete, index }: {
  post: __FEATURE_TITLE__Type;
  onDelete: (id: string) => void;
  index: number;
}) {
  return (
    <article className="card p-4 animate-in" style={{ animationDelay: \`\${index * 30}ms\` }}>
      <div className="flex justify-between items-start gap-3">
        <div className="flex-1 min-w-0">
          <a href={\`/__FEATURE__/\${post.id}\`}
            className="block text-[0.9375rem] font-semibold text-text-primary no-underline mb-1 leading-snug hover:text-accent transition-colors">
            {post.title}
          </a>
          <p className="line-clamp-2 text-sm text-text-secondary leading-relaxed m-0">{post.content}</p>
        </div>
        <button onClick={() => onDelete(post.id)} className="btn btn-icon shrink-0 text-text-tertiary hover:text-red hover:border-red"
          title="Delete" aria-label="Delete"><I.Trash /></button>
      </div>
      <div className="flex gap-3 mt-2 pt-2 border-t border-border-subtle text-[0.6875rem] text-text-tertiary">
        <span>By <strong className="font-medium text-text-secondary">{post.author}</strong></span>
        <span>{new Date(post.created_at).toLocaleDateString("en-US", { year: "numeric", month: "short", day: "numeric" })}</span>
      </div>
    </article>
  );
});

// ── List Page (Sidebar + Content) ──
export function __FEATURE_TITLE__List() {
  const [posts, setPosts] = useState<__FEATURE_TITLE__Type[]>(() => {
    if (typeof window !== "undefined" && window.__INITIAL_DATA__ && Array.isArray(window.__INITIAL_DATA__)) {
      const d = window.__INITIAL_DATA__ as __FEATURE_TITLE__Type[];
      window.__INITIAL_DATA__ = undefined;
      return d;
    }
    return [];
  });
  const [err, setErr] = useState<string | null>(null);
  const [showForm, setShowForm] = useState(false);
  const [title, setTitle] = useState("");
  const [content, setContent] = useState("");
  const [author, setAuthor] = useState("");
  const [light, setLight] = useState(getInitialTheme);

  const load = useCallback(() => {
    list__FEATURE_TITLE__().then(setPosts).catch((e: Error) => setErr(e.message));
  }, []);
  useEffect(() => { if (posts.length > 0 && !window.__INITIAL_DATA__) return; load(); }, [load, posts.length]);
  const toggle = useCallback(() => { toggleTheme(); setLight(!light); }, [light]);

  const handleCreate = useCallback(async (e: React.FormEvent) => {
    e.preventDefault();
    if (!title.trim() || !content.trim()) return;
    try {
      await create__FEATURE_TITLE__({ title: title.trim(), content: content.trim(), author: author.trim() || "Anonymous" });
      setTitle(""); setContent(""); setAuthor(""); setShowForm(false);
      await load();
    } catch (e: any) { setErr(e.message); }
  }, [title, content, author, load]);

  const handleDelete = useCallback(async (id: string) => {
    try { await delete__FEATURE_TITLE__(id); await load(); }
    catch (e: any) { setErr(e.message); await load(); }
  }, [load]);

  if (err) return <div className="p-4 text-red text-sm">Error: {err}</div>;

  return (
    <div className="max-w-[60rem] mx-auto px-4 py-6">
      {/* ── Header ── */}
      <div className="flex items-center justify-between mb-6">
        <div>
          <h1 className="text-2xl font-bold tracking-tight text-text-primary leading-tight m-0">__FEATURE_TITLE__</h1>
          <p className="text-xs text-text-tertiary mt-0.5">{posts.length} {posts.length === 1 ? "post" : "posts"}</p>
        </div>
        <div className="flex items-center gap-2">
          <button onClick={toggle} className="theme-toggle" aria-label="Toggle theme">{light ? <I.Moon /> : <I.Sun />}</button>
          <button onClick={() => setShowForm(!showForm)} className="btn btn-sm gap-1">
            {showForm ? <><I.X /> Close</> : <><I.Plus /> New</>}
          </button>
        </div>
      </div>

      {/* ── Sidebar + Content ── */}
      <div className="flex gap-6">
        {/* Sidebar */}
        <aside className="w-56 shrink-0">
          <div className="card p-4">
            <h3 className="text-xs font-semibold text-text-primary tracking-wide mb-3 uppercase">Filters</h3>
            <div className="space-y-1">
              <button className="w-full text-left btn btn-sm btn-ghost justify-start">All Posts</button>
            </div>
          </div>
        </aside>

        {/* Main content */}
        <main className="flex-1 min-w-0">
          {/* ── Create form ── */}
          {showForm && (
            <form onSubmit={handleCreate} className="card p-4 mb-6 animate-slide-up">
              <h2 className="text-xs font-semibold text-text-primary tracking-wide mb-3 m-0">New Post</h2>
              <input className="input mb-2" placeholder="Post title" value={title} onChange={(e) => setTitle(e.target.value)} required />
              <textarea className="input mb-2" placeholder="Write something..." value={content} onChange={(e) => setContent(e.target.value)} required rows={4}
                style={{ resize: "vertical", fontFamily: "inherit", lineHeight: 1.6 }} />
              <div className="flex gap-2">
                <input className="input flex-1" placeholder="Your name (optional)" value={author} onChange={(e) => setAuthor(e.target.value)} />
                <button type="submit" className="btn btn-primary">Publish</button>
              </div>
            </form>
          )}

          {/* ── Post list ── */}
          <div className="flex flex-col gap-3">
            {posts.map((post, i) => (
              <__FEATURE_TITLE__Card key={post.id} post={post} onDelete={handleDelete} index={i} />
            ))}
          </div>
        </main>
      </div>
    </div>
  );
}

// ── Detail Page ──
export function __FEATURE_TITLE__Detail() {
  const [post, setPost] = useState<__FEATURE_TITLE__Type | null>(() => {
    if (typeof window !== "undefined" && window.__INITIAL_DATA__ && !Array.isArray(window.__INITIAL_DATA__)) {
      const d = window.__INITIAL_DATA__ as __FEATURE_TITLE__Type;
      window.__INITIAL_DATA__ = undefined;
      return d;
    }
    return null;
  });
  const [err, setErr] = useState<string | null>(null);
  const [editing, setEditing] = useState(false);
  const [editTitle, setEditTitle] = useState("");
  const [editContent, setEditContent] = useState("");
  const [light, setLight] = useState(getInitialTheme);
  const id = typeof window !== "undefined" ? window.location.pathname.split("/").pop() || "" : "";

  const load = useCallback(() => {
    if (!id) return; get__FEATURE_TITLE__(id).then(setPost).catch((e: Error) => setErr(e.message));
  }, [id]);
  useEffect(() => { if (post) return; load(); }, [load, post]);
  const toggle = useCallback(() => { toggleTheme(); setLight(!light); }, [light]);
  const handleEdit = useCallback(() => {
    if (!post) return; setEditTitle(post.title); setEditContent(post.content); setEditing(true);
  }, [post]);
  const handleSave = useCallback(async () => {
    if (!post || !editTitle.trim() || !editContent.trim()) return;
    try {
      const u = await update__FEATURE_TITLE__(post.id, { title: editTitle.trim(), content: editContent.trim() });
      setPost(u); setEditing(false);
    } catch (e: any) { setErr(e.message); }
  }, [post, editTitle, editContent]);
  const handleDelete = useCallback(async () => {
    if (!post) return;
    try { await delete__FEATURE_TITLE__(post.id); window.location.href = "/__FEATURE__"; }
    catch (e: any) { setErr(e.message); }
  }, [post]);

  if (err) return <div className="p-4 text-red text-sm">Error: {err}</div>;
  if (!post) return <div className="p-8 text-center text-text-tertiary text-sm">Loading...</div>;

  return (
    <div className="max-w-[42rem] mx-auto px-4 py-6">
      <div className="flex items-center justify-between mb-6">
        <a href={\`/__FEATURE__\`} className="btn btn-sm btn-ghost gap-1"><I.ArrowLeft /> Back</a>
        <button onClick={toggle} className="theme-toggle" aria-label="Toggle theme">{light ? <I.Moon /> : <I.Sun />}</button>
      </div>
      {editing ? (
        <div className="card p-4 animate-in">
          <h2 className="text-xs font-semibold text-text-primary tracking-wide mb-3 m-0">Edit Post</h2>
          <input className="input mb-2" value={editTitle} onChange={(e) => setEditTitle(e.target.value)} />
          <textarea className="input mb-3" value={editContent} onChange={(e) => setEditContent(e.target.value)} rows={8}
            style={{ resize: "vertical", fontFamily: "inherit", lineHeight: 1.6 }} />
          <div className="flex gap-2">
            <button onClick={handleSave} className="btn btn-primary">Save</button>
            <button onClick={() => setEditing(false)} className="btn">Cancel</button>
          </div>
        </div>
      ) : (
        <div className="animate-in">
          <h1 className="text-2xl font-bold tracking-tight text-text-primary leading-tight m-0 mb-2">{post.title}</h1>
          <div className="flex gap-3 text-xs text-text-tertiary mb-6 pb-4 border-b border-border-subtle">
            <span>By <strong className="font-medium text-text-secondary">{post.author}</strong></span>
            <span>{new Date(post.created_at).toLocaleDateString("en-US", { year: "numeric", month: "long", day: "numeric" })}</span>
          </div>
          <div className="prose-custom text-[0.9375rem] mb-8 whitespace-pre-wrap">{post.content}</div>
          <div className="flex gap-2">
            <button onClick={handleEdit} className="btn btn-sm gap-1"><I.Pen /> Edit</button>
            <button onClick={handleDelete} className="btn btn-sm btn-danger gap-1"><I.Trash /> Delete</button>
          </div>
        </div>
      )}
    </div>
  );
}

// ── Entry point ──
const el = document.getElementById("__FEATURE__-root");
if (el) {
  const root = createRoot(el);
  root.render(window.__PAGE__ === "detail" ? <__FEATURE_TITLE__Detail /> : <__FEATURE_TITLE__List />);
}
CUSTOMTSX
    ;;

  table|grid)
    # Layout: tabel penuh atau grid cards (default — sama dengan template standar)
    # Untuk layout ini, tidak perlu generate custom — biarkan scaffold default
    echo "  → Layout '${LAYOUT}': using default scaffold template (no custom Feature.tsx needed)"
    ;;

  *)
    # Layout tidak dikenal — fallback ke default
    echo "  → Layout '${LAYOUT}': unknown, using default scaffold template"
    ;;
esac

if [[ -f "${OUTDIR}/Feature.tsx.tmpl" ]]; then
  echo "  ✓ Feature.tsx.tmpl (custom ${LAYOUT} layout)"
fi

echo ""
echo "── Done ──"
echo "  Custom UI templates in: ${OUTDIR}"
echo ""
echo "Next step:"
echo "  .github/skills/new-feature-module/scripts/scaffold.sh ${FEATURE} --custom-ui ${OUTDIR}"
