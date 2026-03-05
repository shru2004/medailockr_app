const WebSocket = require('ws');

/**
 * Sets up a WebSocket server attached to the HTTP server.
 * Returns a broadcast function used by routes to push events.
 */
function setupWebSocket(httpServer) {
  const wss = new WebSocket.Server({ server: httpServer, path: '/ws' });

  const clients = new Set();

  wss.on('connection', (ws, req) => {
    clients.add(ws);
    console.log(`[WS] Client connected. Total: ${clients.size}`);

    // Send welcome ping
    ws.send(JSON.stringify({ event: 'connected', data: { message: 'Health Twin WS connected', ts: new Date().toISOString() } }));

    ws.on('message', (raw) => {
      try {
        const msg = JSON.parse(raw.toString());
        // Echo ping/pong for keep-alive
        if (msg.event === 'ping') {
          ws.send(JSON.stringify({ event: 'pong', data: { ts: new Date().toISOString() } }));
        }
      } catch {
        // ignore malformed
      }
    });

    ws.on('close', () => {
      clients.delete(ws);
      console.log(`[WS] Client disconnected. Total: ${clients.size}`);
    });

    ws.on('error', (err) => {
      console.error('[WS] Error:', err.message);
      clients.delete(ws);
    });
  });

  /**
   * Broadcast a structured event to all connected WebSocket clients.
   * @param {{ event: string, data: any }} payload
   */
  function broadcast(payload) {
    const message = JSON.stringify(payload);
    for (const client of clients) {
      if (client.readyState === WebSocket.OPEN) {
        client.send(message);
      }
    }
  }

  return { wss, broadcast };
}

module.exports = setupWebSocket;
