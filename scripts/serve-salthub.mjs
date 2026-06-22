import http from "node:http";
import fs from "node:fs";
import path from "node:path";

const repoRoot = path.resolve(new URL("..", import.meta.url).pathname.slice(1));
const scriptPath = path.join(repoRoot, "salthub.lua");
const host = "127.0.0.1";
const port = Number(process.env.SALT_HUB_PORT || 16500);

const server = http.createServer((req, res) => {
  const url = new URL(req.url || "/", `http://${host}:${port}`);

  res.setHeader("Access-Control-Allow-Origin", "*");
  res.setHeader("Cache-Control", "no-store");

  if (url.pathname === "/health") {
    res.writeHead(200, { "Content-Type": "text/plain; charset=utf-8" });
    res.end("ok");
    return;
  }

  if (url.pathname !== "/salthub.lua") {
    res.writeHead(404, { "Content-Type": "text/plain; charset=utf-8" });
    res.end("not found");
    return;
  }

  fs.readFile(scriptPath, "utf8", (error, source) => {
    if (error) {
      res.writeHead(500, { "Content-Type": "text/plain; charset=utf-8" });
      res.end(String(error.message || error));
      return;
    }

    res.writeHead(200, { "Content-Type": "text/plain; charset=utf-8" });
    res.end(source);
  });
});

server.listen(port, host, () => {
  console.log(`Serving ${scriptPath} at http://${host}:${port}/salthub.lua`);
});
