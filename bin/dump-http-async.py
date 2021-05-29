#!/usr/bin/env python3

import asyncio
import random

from aiohttp import web

try:
    from lorem import get_sentence
except ImportError:
    msg = "Cannot generate random text. Instal python-lorem!"
    print(msg)

    def get_sentence():
        return msg


STATUSES = [200, 201, 202, 301, 302, 400, 401, 403, 404, 405, 422, 500, 503]


async def handle(request):
    path = request.match_info.get("path", "unknown")
    text = f"{request.method} {path} {request.headers}"
    print(text)
    sleep = random.uniform(0.5, 5.0)
    await asyncio.sleep(sleep)
    text = f"{request.method} {path} in {sleep:0.2f}\n{get_sentence()}"
    print(text)
    return web.Response(status=random.choice(STATUSES), text=text)


app = web.Application()
app.add_routes(
    [
        web.get("/", handle),
        web.get("/{path}", handle),
    ]
)

if __name__ == "__main__":
    web.run_app(app)
