const express = require('express');
const bodyParser = require('body-parser');
const mysql = require('mysql2');
const cors = require('cors');

/**
 * CONFIGURACIÓN DE LA DB
 * Ajusta los datos de conexión a MySQL según lo que creaste.
 */
const dbConfig = {
  host: '127.0.0.1',
  user: 'wpp_user',
  password: 'StrongPass123_',
  database: 'wpp_db'
};

/**
 * Creamos pool de conexiones a MySQL para manejar concurrentemente.
 */
const pool = mysql.createPool({
  ...dbConfig,
  waitForConnections: true,
  connectionLimit: 10,
  queueLimit: 0
});

const app = express();
app.use(cors());
app.use(bodyParser.json()); // Soporta JSON en request body
app.use(bodyParser.urlencoded({ extended: true }));

// =========================================================
// FUNCIONES AUXILIARES DE DB
// =========================================================
function queryDB(sql, params = []) {
  return new Promise((resolve, reject) => {
    pool.query(sql, params, (err, results) => {
      if (err) {
        console.error('Error in DB query:', err);
        return reject(err);
      }
      resolve(results);
    });
  });
}

// =========================================================
// ENDPOINTS DE EJEMPLO PARA EL FRONT END
// =========================================================

// 1) Listar canales
app.get('/channels', async (req, res) => {
  try {
    const sql = 'SELECT * FROM channels';
    const rows = await queryDB(sql);
    res.json(rows);
  } catch (error) {
    res.status(500).json({ error: error.message });
  }
});

// 2) Crear un canal
app.post('/channels', async (req, res) => {
  try {
    /**
     * Esperamos en el body algo como:
     * {
     *   "phone_number": "+5491112345678",
     *   "display_name": "Ventas",
     *   "session_name": "session_ventas",
     *   "proxy_ip": "111.222.333.444",
     *   "proxy_port": 8080,
     *   "proxy_user": "...",
     *   "proxy_pass": "...",
     *   "use_proxy": 1
     * }
     */
    const {
      phone_number,
      display_name,
      session_name,
      proxy_ip,
      proxy_port,
      proxy_user,
      proxy_pass,
      use_proxy
    } = req.body;

    const sql = `
      INSERT INTO channels (
        phone_number, display_name, session_name,
        proxy_ip, proxy_port, proxy_user, proxy_pass, use_proxy
      )
      VALUES (?,?,?,?,?,?,?,?)
    `;

    const result = await queryDB(sql, [
      phone_number,
      display_name,
      session_name,
      proxy_ip,
      proxy_port,
      proxy_user,
      proxy_pass,
      use_proxy
    ]);

    res.json({ message: 'Canal creado', channel_id: result.insertId });
  } catch (error) {
    res.status(500).json({ error: error.message });
  }
});

// 3) Actualizar el estado de un canal
app.put('/channels/:channelId/state', async (req, res) => {
  try {
    const channelId = req.params.channelId;
    const { newStatus, lastError } = req.body;
    // Ejemplo: { "newStatus": "connected", "lastError": null }

    // Obtenemos el estado anterior para guardarlo en logs
    const [oldChannel] = await queryDB('SELECT status FROM channels WHERE channel_id=?', [channelId]);
    if(!oldChannel) {
      return res.status(404).json({ error: 'Canal no encontrado' });
    }

    // Actualizamos el canal
    const sql = `
      UPDATE channels
      SET status=?, last_error=?, status_updated_at=NOW()
      WHERE channel_id=?
    `;
    await queryDB(sql, [newStatus, lastError || null, channelId]);

    // Insertamos log del cambio
    const logSql = `
      INSERT INTO channel_logs (channel_id, event_type, old_value, new_value, description)
      VALUES (?, 'state_change', ?, ?, ?)
    `;
    await queryDB(logSql, [
      channelId,
      oldChannel.status,
      newStatus,
      lastError ? `Error: ${lastError}` : `State changed to ${newStatus}`
    ]);

    res.json({ message: 'Estado actualizado' });
  } catch (error) {
    res.status(500).json({ error: error.message });
  }
});

// 4) Eliminar (borrar) un canal
app.delete('/channels/:channelId', async (req, res) => {
  try {
    const channelId = req.params.channelId;
    const sql = 'DELETE FROM channels WHERE channel_id=?';
    await queryDB(sql, [channelId]);
    res.json({ message: 'Canal eliminado' });
  } catch (error) {
    res.status(500).json({ error: error.message });
  }
});

// =========================================================
// WEBHOOKS DE WPPConnect-SERVER
// =========================================================

/**
 * WPPConnect-Server permite definir webhooks para eventos (onMessage, onStateChange, etc.).
 * Aquí guardamos en la DB los mensajes entrantes/salientes, logs de estado, etc.
 */

// Ejemplo: webhook para Mensajes
app.post('/webhook/messages', async (req, res) => {
  try {
    // La estructura depende de WPPConnect-Server. Ejemplo:
    // {
    //   "from": "5491112345678@c.us",
    //   "to": "5499998887776@c.us",
    //   "body": "Hola",
    //   ...
    // }
    const payload = req.body;
    console.log('Mensaje entrante del webhook:', payload);

    const fromNumber = (payload.from || '').replace('@c.us', '');
    const toNumber   = (payload.to || '').replace('@c.us', '');

    // Determinar direction
    // asumiendo que 'fromMe' indica si es OUT o IN
    // o comparar con el canal phone_number.
    const direction = payload.fromMe ? 'OUT' : 'IN';

    // Buscamos el canal con phone_number = X
    // (si toNumber == channel.phone_number => IN, etc.)
    // Simplificamos: supondremos que es un canal con phone_number = fromNumber si es OUT, etc.
    // Tu lógica real puede variar.
    const sqlFindChannel = `
      SELECT channel_id, phone_number
      FROM channels
      WHERE phone_number=? OR phone_number=?
      LIMIT 1
    `;
    let channelRow;
    if(direction === 'IN'){
      channelRow = await queryDB(sqlFindChannel, [ toNumber, fromNumber ]);
    } else {
      channelRow = await queryDB(sqlFindChannel, [ fromNumber, toNumber ]);
    }
    const channel = channelRow.length ? channelRow[0] : null;

    if(!channel) {
      console.log('No se encontró canal que coincida con phone_number:', fromNumber, toNumber);
      return res.json({ message: 'No channel found for this message' });
    }

    // Insertamos en la tabla messages
    const sqlInsert = `
      INSERT INTO messages (
        channel_id,
        from_number,
        to_number,
        direction,
        message_content,
        message_type,
        media_url,
        status
      )
      VALUES (?,?,?,?,?,?,?,?)
    `;
    await queryDB(sqlInsert, [
      channel.channel_id,
      fromNumber,
      toNumber,
      direction,
      payload.body || '',
      payload.type || 'text',
      payload.mediaUrl || null,
      'sent'
    ]);

    // Retornar ok al webhook
    res.json({ message: 'Mensaje procesado y guardado en DB' });

  } catch (error) {
    console.error('Error en webhook de mensajes:', error);
    res.status(500).json({ error: error.message });
  }
});

// Ejemplo: webhook para cambios de estado
app.post('/webhook/status', async (req, res) => {
  try {
    // Estructura depende de WPPConnect. Ej:
    // {
    //   "session": "mySession01",
    //   "previousState": "CONNECTED",
    //   "currentState": "DISCONNECTED",
    //   "reason": "Lost connection"
    // }
    const payload = req.body;
    console.log('Status change webhook:', payload);

    const { session, previousState, currentState, reason } = payload;

    // Buscamos el canal según session_name
    const sqlFind = `
      SELECT channel_id, status
      FROM channels
      WHERE session_name=?
      LIMIT 1
    `;
    const rows = await queryDB(sqlFind, [session]);
    if(!rows.length) {
      return res.json({ message: 'No channel found with that session_name' });
    }
    const channel = rows[0];

    // Actualizamos estado en channels
    const sqlUpdate = `
      UPDATE channels
      SET status=?, last_error=?, status_updated_at=NOW()
      WHERE channel_id=?
    `;
    const finalState = currentState || 'disconnected';
    const lastError = reason || null;

    await queryDB(sqlUpdate, [finalState, lastError, channel.channel_id]);

    // Insertar log
    const logSql = `
      INSERT INTO channel_logs (channel_id, event_type, old_value, new_value, description)
      VALUES (?, 'state_change', ?, ?, ?)
    `;
    await queryDB(logSql, [
      channel.channel_id,
      previousState,
      finalState,
      reason ? reason : `State changed to ${finalState}`
    ]);

    res.json({ message: 'Estado actualizado en DB' });

  } catch (error) {
    console.error('Error en webhook de estado:', error);
    res.status(500).json({ error: error.message });
  }
});

/***************************************************
 * ENDPOINT PARA LISTAR MENSAJES DE UN CANAL
 ***************************************************/
app.get('/messages/:channelId', async (req, res) => {
  try {
    const channelId = req.params.channelId;
    // Ejemplo: GET /messages/1
    const sql = `
      SELECT * 
      FROM messages
      WHERE channel_id=?
      ORDER BY created_at ASC
    `;
    const rows = await queryDB(sql, [channelId]);
    res.json(rows);
  } catch (error) {
    console.error('Error al listar mensajes:', error);
    res.status(500).json({ error: error.message });
  }
});

// =========================================================
// LEVANTAR SERVIDOR
// =========================================================
const PORT = 3001; // Usa un puerto distinto al de React (3000) y WPPConnect (21465)
app.listen(PORT, () => {
  console.log(`[wpp-db-server] Server running on port ${PORT}`);
});
