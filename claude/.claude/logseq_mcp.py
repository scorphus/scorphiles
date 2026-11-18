#!/usr/bin/env python3
"""Minimal stdio MCP server wrapping the headless `logseq` CLI.

Why this exists: Logseq 2.0-alpha's built-in HTTP MCP server returns 200 but
never emits the JSON-RPC response body (the SSE stream is held open by the GUI
renderer), so Claude Code's HTTP client times out. The `logseq` CLI talks
directly to the db-worker-node with no GUI/HTTP, so we wrap it over stdio
transport instead, which is reliable.

Exposes: logseq_save, logseq_search, logseq_read_page, logseq_list_pages,
         logseq_list_by_prefix, logseq_backlinks, logseq_query,
         logseq_set_tags, logseq_remove_block.
Talks newline-delimited JSON-RPC 2.0 on stdin/stdout (MCP stdio transport).
"""
import json
import os
import shutil
import subprocess
import sys

CLI_TIMEOUT = int(os.environ.get("LOGSEQ_CLI_TIMEOUT", "90"))

# Resolve the logseq binary (Claude Code's spawn env may lack ~/.local/bin).
_CANDIDATES = [
    os.path.expanduser("~/.local/bin/logseq"),
    shutil.which("logseq") or "",
    "/opt/homebrew/bin/logseq",
]
LOGSEQ_BIN = next((p for p in _CANDIDATES if p and os.path.exists(p)), "logseq")

SERVER_INFO = {"name": "logseq-cli", "version": "0.1.0"}
PROTO_DEFAULT = "2024-11-05"


def err(*a):
    print("[logseq-mcp]", *a, file=sys.stderr, flush=True)


def run_cli(args, graph):
    """Run logseq CLI with --output json; return (ok, parsed_or_text)."""
    cmd = [LOGSEQ_BIN, *args, "-g", graph, "--output", "json"]
    try:
        p = subprocess.run(cmd, capture_output=True, text=True, timeout=CLI_TIMEOUT)
    except subprocess.TimeoutExpired:
        return False, f"logseq CLI timed out after {CLI_TIMEOUT}s: {' '.join(args)}"
    except Exception as e:
        return False, f"failed to run logseq CLI: {e}"
    out = (p.stdout or "").strip()
    try:
        data = json.loads(out)
    except Exception:
        if p.returncode != 0:
            return False, (p.stderr or out or f"exit {p.returncode}").strip()
        return True, out
    if isinstance(data, dict) and data.get("status") == "error":
        return False, json.dumps(data.get("error", data))
    return True, data


TOOLS = [
    {
        "name": "logseq_save",
        "description": (
            "Save a memory note as a block under a page in the graph. The whole "
            "graph is the project's memory; organize pages by category prefix "
            "(feedback-*, decision-*, incident-*, reference-*, principle-*, "
            "project-*). Use for durable facts, decisions, and session context. "
            "Pass `tags` (related page names) to link this page for backlink "
            "navigation — inline [[wikilinks]] in content are NOT indexed, so use "
            "`tags` to make logseq_backlinks resolve. Tags are merged with the "
            "page's existing page-tags, not replaced (use logseq_set_tags if you "
            "need to remove a page-tag)."
        ),
        "inputSchema": {
            "type": "object",
            "properties": {
                "content": {"type": "string", "description": "The note text to store."},
                "page": {"type": "string", "description": "Target page (required), e.g. 'decision-foo'."},
                "tags": {
                    "type": "array",
                    "items": {"type": "string"},
                    "description": (
                        "Related page names to link via page-tags, enabling "
                        "logseq_backlinks (e.g. ['project-frontend']). Referenced "
                        "pages are auto-created if missing."
                    ),
                },
            },
            "required": ["content", "page"],
        },
    },
    {
        "name": "logseq_search",
        "description": "Search memory blocks by their text content. Returns matching blocks with ids.",
        "inputSchema": {
            "type": "object",
            "properties": {
                "query": {"type": "string", "description": "Text to search for in block content."},
            },
            "required": ["query"],
        },
    },
    {
        "name": "logseq_read_page",
        "description": "Read a page and its block tree by page name.",
        "inputSchema": {
            "type": "object",
            "properties": {
                "page": {"type": "string", "description": "Page name to read."},
            },
            "required": ["page"],
        },
    },
    {
        "name": "logseq_list_pages",
        "description": "List pages in the graph.",
        "inputSchema": {"type": "object", "properties": {}},
    },
    {
        "name": "logseq_list_by_prefix",
        "description": (
            "List pages whose name starts with a given prefix. Memory pages are named "
            "by category prefix (feedback-*, decision-*, incident-*, reference-*, "
            "principle-*, project-*). Use prefix='feedback' to get every feedback memory, "
            "prefix='decision' for every decision, etc."
        ),
        "inputSchema": {
            "type": "object",
            "properties": {
                "prefix": {"type": "string", "description": "Page name prefix (e.g. 'feedback', 'decision')."},
            },
            "required": ["prefix"],
        },
    },
    {
        "name": "logseq_backlinks",
        "description": (
            "List pages that reference a given page via :logseq.property/page-tags. "
            "Use this to navigate the memory graph — e.g. backlinks of 'crivo' returns every "
            "memory related to the crivo project."
        ),
        "inputSchema": {
            "type": "object",
            "properties": {
                "page": {"type": "string", "description": "Page name to find backlinks for."},
            },
            "required": ["page"],
        },
    },
    {
        "name": "logseq_query",
        "description": (
            "Run a raw Datascript (Datalog) query against the graph. EDN syntax. "
            "Use for advanced exploration that list/search/backlinks can't express. "
            "Example: '[:find ?title :where [?p :block/title ?title] [?p :block/name ?n]]'."
        ),
        "inputSchema": {
            "type": "object",
            "properties": {
                "query": {"type": "string", "description": "EDN datalog query."},
                "inputs": {"type": "string", "description": "Optional EDN vector of inputs for :in clause."},
            },
            "required": ["query"],
        },
    },
    {
        "name": "logseq_set_tags",
        "description": (
            "Set a page's page-tags (related pages) WITHOUT appending a block. "
            "Use to make an existing page reachable via logseq_backlinks without "
            "duplicating its content (unlike logseq_save, which appends a block). "
            "Replaces the page's current page-tags."
        ),
        "inputSchema": {
            "type": "object",
            "properties": {
                "page": {"type": "string", "description": "Page to tag."},
                "tags": {
                    "type": "array",
                    "items": {"type": "string"},
                    "description": "Related page names (e.g. ['project-frontend']). Empty list clears tags.",
                },
            },
            "required": ["page", "tags"],
        },
    },
    {
        "name": "logseq_remove_block",
        "description": (
            "Delete a block by its db/id (ids come from logseq_search / "
            "logseq_read_page). Use to clean up duplicate or stale blocks. "
            "Accepts a single id or a list of ids."
        ),
        "inputSchema": {
            "type": "object",
            "properties": {
                "id": {
                    "type": ["integer", "array"],
                    "items": {"type": "integer"},
                    "description": "Block db/id, or a list of ids.",
                },
            },
            "required": ["id"],
        },
    },
]

# Every tool requires an explicit `graph`. There is intentionally NO default
# graph: the caller must always name the target graph on each call.
for _t in TOOLS:
    _props = _t["inputSchema"].setdefault("properties", {})
    _props["graph"] = {"type": "string", "description": "Graph name to target (required; no default)."}
    _req = _t["inputSchema"].setdefault("required", [])
    if "graph" not in _req:
        _req.insert(0, "graph")


def _page_tags_edn(tags):
    items = " ".join('"' + str(t).replace("\\", "\\\\").replace('"', '\\"') + '"' for t in tags)
    return "{:logseq.property/page-tags [" + items + "]}"


def _existing_page_tags(page, graph):
    """Fetch a page's current page-tags (titles). Empty list if the page
    doesn't exist yet or has none -- --update-properties REPLACES the
    whole set, so callers that want to add must merge with this first."""
    edn = ("[:find (pull ?p [{:logseq.property/page-tags [:block/title]}]) "
           ":in $ ?name :where [?p :block/name ?name]]")
    ok, data = _query(edn, graph, f'["{page.lower()}"]')
    if not ok:
        return []
    rows = (data.get("data", {}) or {}).get("result", []) if isinstance(data, dict) else []
    if not rows or not rows[0]:
        return []
    tags = (rows[0][0] or {}).get("logseq.property/page-tags") or []
    return [t.get("block/title") for t in tags if t.get("block/title")]


def tool_save(args):
    g = args["graph"]
    content = args.get("content", "").strip()
    if not content:
        return False, "content is required"
    page = args.get("page", "").strip()
    if not page:
        return False, "page is required"
    tags = [str(t).strip() for t in (args.get("tags") or []) if str(t).strip()]
    page_args = ["upsert", "page", "--page", page]
    merged = tags
    if tags:
        # page-tags values create :block/refs too, which is what logseq_backlinks
        # keys off. Inline [[links]] in content are NOT parsed, so this is the
        # only tool-driven way to make backlinks resolve. --update-properties
        # REPLACES the whole page-tags set, so merge with what's already there
        # or a save with a short tag list would silently drop prior links.
        merged = sorted(set(_existing_page_tags(page, g)) | set(tags))
        page_args += ["--update-properties", _page_tags_edn(merged)]
    ok, _ = run_cli(page_args, g)  # idempotent ensure-exists (+ page-tags)
    if not ok:
        return False, f"could not ensure page '{page}': {_}"
    ok, data = run_cli(["upsert", "block", "--target-page", page,
                        "--pos", "last-child", "--content", content], g)
    if not ok:
        return False, data
    suffix = f" (page-tags: {', '.join(merged)})" if tags else ""
    return True, f"Saved to '{page}' in graph '{g}'{suffix}. {json.dumps(data)}"


def tool_search(args):
    g = args["graph"]
    q = args.get("query", "").strip()
    if not q:
        return False, "query is required"
    ok, data = run_cli(["search", "block", "--content", q], g)
    if not ok:
        return False, data
    items = data.get("data", {}).get("items", []) if isinstance(data, dict) else []
    if not items:
        return True, f"No matches for '{q}'."
    lines = [f"- [{it.get('db/id')}] {it.get('block/title','')}" for it in items]
    return True, f"{len(items)} match(es):\n" + "\n".join(lines)


def tool_read_page(args):
    g = args["graph"]
    page = args.get("page", "").strip()
    if not page:
        return False, "page is required"
    # `show` prints a human tree; run it without json for readability.
    cmd = [LOGSEQ_BIN, "show", "-g", g, "--page", page]
    try:
        p = subprocess.run(cmd, capture_output=True, text=True, timeout=CLI_TIMEOUT)
    except subprocess.TimeoutExpired:
        return False, f"logseq CLI timed out after {CLI_TIMEOUT}s: show --page {page}"
    except Exception as e:
        return False, f"failed to run logseq CLI: {e}"
    # `show` writes its error message to stdout (not stderr) on failure, so
    # returncode -- not stdout truthiness -- is what decides success here.
    out = (p.stdout or "").strip()
    if p.returncode != 0:
        return False, out or (p.stderr or "").strip() or f"exit {p.returncode}"
    return (True, out) if out else (False, "empty")


def tool_list_pages(args):
    ok, data = run_cli(["list", "page"], args["graph"])
    if not ok:
        return False, data
    return True, json.dumps(data) if not isinstance(data, str) else data


def _query(edn, graph, inputs=None):
    cli_args = ["query", "--query", edn]
    if inputs:
        cli_args += ["--inputs", inputs]
    return run_cli(cli_args, graph)


def tool_list_by_prefix(args):
    g = args["graph"]
    prefix = args.get("prefix", "").strip().lower()
    if not prefix:
        return False, "prefix is required"
    ok, data = run_cli(["list", "page"], g)
    if not ok:
        return False, data
    items = (data.get("data", {}) or {}).get("items", []) if isinstance(data, dict) else []
    titles = sorted(
        it.get("block/title", "") for it in items
        if not it.get("db/ident") and (it.get("block/title", "").lower().startswith(prefix))
    )
    if not titles:
        return True, f"No pages with prefix '{prefix}'."
    return True, f"{len(titles)} page(s) with prefix '{prefix}':\n" + "\n".join(f"- {t}" for t in titles)


def tool_backlinks(args):
    g = args["graph"]
    page = args.get("page", "").strip()
    if not page:
        return False, "page is required"
    edn = (
        '[:find ?from :in $ ?target :where '
        '[?to :block/name ?target] '
        '[?from-page :logseq.property/page-tags ?to] '
        '[?from-page :block/title ?from]]'
    )
    ok, data = _query(edn, g, f'["{page.lower()}"]')
    if not ok:
        return False, data
    rows = (data.get("data", {}) or {}).get("result", []) if isinstance(data, dict) else []
    titles = sorted({r[0] for r in rows if r})
    if not titles:
        return True, f"No backlinks to '{page}'."
    return True, f"{len(titles)} backlink(s) to '{page}':\n" + "\n".join(f"- {t}" for t in titles)


def tool_query(args):
    g = args["graph"]
    edn = args.get("query", "").strip()
    if not edn:
        return False, "query is required"
    inputs = (args.get("inputs") or "").strip() or None
    ok, data = _query(edn, g, inputs)
    if not ok:
        return False, data
    return True, json.dumps(data) if not isinstance(data, str) else data


def tool_set_tags(args):
    g = args["graph"]
    page = args.get("page", "").strip()
    if not page:
        return False, "page is required"
    tags = [str(t).strip() for t in (args.get("tags") or []) if str(t).strip()]
    # upsert page only -- no block appended, so re-tagging never duplicates content.
    ok, data = run_cli(["upsert", "page", "--page", page,
                        "--update-properties", _page_tags_edn(tags)], g)
    if not ok:
        return False, data
    return True, (f"Set page-tags on '{page}' in '{g}': "
                  f"{', '.join(tags) if tags else '(cleared)'}. No block appended.")


def tool_remove_block(args):
    g = args["graph"]
    bid = args.get("id")
    if bid is None or (isinstance(bid, str) and not bid.strip()):
        return False, "id is required"
    if isinstance(bid, list):
        try:
            idarg = "[" + ",".join(str(int(x)) for x in bid) + "]"
        except (TypeError, ValueError):
            return False, "id list must contain integers"
    else:
        idarg = str(bid)
    ok, data = run_cli(["remove", "block", "--id", idarg], g)
    if not ok:
        return False, data
    return True, f"Removed block(s) {idarg} from '{g}'."


DISPATCH = {
    "logseq_save": tool_save,
    "logseq_search": tool_search,
    "logseq_read_page": tool_read_page,
    "logseq_list_pages": tool_list_pages,
    "logseq_list_by_prefix": tool_list_by_prefix,
    "logseq_backlinks": tool_backlinks,
    "logseq_query": tool_query,
    "logseq_set_tags": tool_set_tags,
    "logseq_remove_block": tool_remove_block,
}


def send(obj):
    sys.stdout.write(json.dumps(obj) + "\n")
    sys.stdout.flush()


def handle(msg):
    mid = msg.get("id")
    method = msg.get("method")
    if method == "initialize":
        proto = (msg.get("params") or {}).get("protocolVersion", PROTO_DEFAULT)
        return {"jsonrpc": "2.0", "id": mid, "result": {
            "protocolVersion": proto,
            "capabilities": {"tools": {}},
            "serverInfo": SERVER_INFO,
        }}
    if method in ("notifications/initialized", "initialized"):
        return None  # notification, no reply
    if method == "tools/list":
        return {"jsonrpc": "2.0", "id": mid, "result": {"tools": TOOLS}}
    if method == "tools/call":
        params = msg.get("params") or {}
        name = params.get("name")
        args = params.get("arguments") or {}
        fn = DISPATCH.get(name)
        if not fn:
            return {"jsonrpc": "2.0", "id": mid, "error": {"code": -32601, "message": f"unknown tool: {name}"}}
        if not str(args.get("graph") or "").strip():
            return {"jsonrpc": "2.0", "id": mid, "result": {
                "content": [{"type": "text", "text": "graph is required (no default graph); pass an explicit graph name"}],
                "isError": True,
            }}
        try:
            ok, text = fn(args)
        except Exception as e:
            ok, text = False, f"tool error: {e}"
        return {"jsonrpc": "2.0", "id": mid, "result": {
            "content": [{"type": "text", "text": str(text)}],
            "isError": not ok,
        }}
    if mid is not None:
        return {"jsonrpc": "2.0", "id": mid, "error": {"code": -32601, "message": f"method not found: {method}"}}
    return None


def main():
    err(f"starting; bin={LOGSEQ_BIN}")
    for line in sys.stdin:
        line = line.strip()
        if not line:
            continue
        try:
            msg = json.loads(line)
        except Exception as e:
            err("bad json:", e)
            continue
        resp = handle(msg)
        if resp is not None:
            send(resp)


if __name__ == "__main__":
    main()
