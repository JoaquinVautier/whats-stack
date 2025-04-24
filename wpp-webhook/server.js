/************************************************
 * webhook.js – Registra eventos de wppconnect‑server
 * Maneja phoneCode, status-find, onmessage, onack, onStateChange
 ************************************************/
const express = require('express');
const mysql   = require('mysql2/promise');
const axios   = require('axios');

/* ---------- Configuración DB ---------- */
const pool = mysql.createPool({
  host: 'db',
  user: 'wpp_user',
  password: 'wpp_pass',
  database: 'wpp_db',
  connectionLimit: 10
});

async function queryDB(sql, p = []) {
  const [rows] = await pool.query(sql, p);
  return rows;
}

/* ---------- App ---------- */
const app = express();
app.use(express.json());

/* ---------- Notificar inmediatamente a wpp-db-server ---------- */
async function notifyDbServer(chan) {
  try {
    await axios.get(`http://wpp-db-server:3001/channels/${chan.channel_id}/refresh-status`);
  } catch (error) {
    console.error('Error notificando a wpp-db-server:', error.message);
  }
}

/* ---------- Webhook ---------- */
app.post('/wpp-webhook', async (req, res) => {
  console.log('[WEBHOOK]', JSON.stringify(req.body).slice(0, 250));

  try {
    const data = req.body;
    if (!data.session) return res.sendStatus(200);

    /* localizar canal */
    const [chan] = await queryDB(
      'SELECT channel_id, phone_number FROM channels WHERE session_name=?',
      [data.session]
    );
    if (!chan) return res.sendStatus(200);

    /* normaliza evento a minúsculas */
    const evento = (data.event || '').toLowerCase();

    /* --------- DESPACHADOR --------- */
    switch (evento) {

      /* -- phoneCode: guardar código -- */
      case 'phonecode': {
        await queryDB(
          'UPDATE channels SET status=?, phone_code=?, status_updated_at=NOW() WHERE channel_id=?',
          ['phonecode', data.phoneCode, chan.channel_id]
        );
        await notifyDbServer(chan);
        break;
      }

      /* ------------- CAMBIOS DE ESTADO ------------- */
      case 'session-status':
      case 'statussession':
      case 'session-update':
      case 'status-find': {
        let st = (data.status || '').toLowerCase();

        if (['inchat','synced','main','normal','pairing','opening'].includes(st))
          st = 'connected';
        if (['browserclose','desconnectedmobile','desconnected','timeout','qrreaderror','notlogged'].includes(st))
          st = 'disconnected';

        await queryDB(
          'UPDATE channels SET status=?, status_updated_at=NOW() WHERE channel_id=?',
          [st, chan.channel_id]
        );

        await notifyDbServer(chan);
        break;
      }

      /* -- onmessage: entrantes / salientes -- */
      case 'onmessage': {
        const from  = (data.from || '').replace('@c.us', '');
        const to    = (data.to   || '').replace('@c.us', '');
        const dir   = from === chan.phone_number ? 'OUT' : 'IN';
        const type  = data.type === 'chat' ? 'text' : (data.type || 'text');
        const ack   = data.ack || 0;
        const stat  = dir === 'IN' ? 'delivered' : 'sent';

        await queryDB(
          `INSERT INTO messages
             (channel_id,wpp_message_id,from_number,to_number,
              direction,message_type,message_content,status,ack,created_at)
           VALUES (?,?,?,?,?,?,?,?,?,NOW())`,
          [
            chan.channel_id,
            data.id || null,
            from,
            to,
            dir,
            type,
            data.body || '',
            stat,
            ack
          ]
        );
        break;
      }

      /* -- onack: actualizar ACK de mensajes OUT -- */
      case 'onack': {
        if (!data.id?.fromMe) break;

        const msgId = data.id?._serialized || null;
        const ack   = data.ack || 0;
        const stat  = ack >= 3 ? 'read' : 'sent';

        const [ex] = await queryDB(
          'SELECT message_id FROM messages WHERE wpp_message_id=? AND channel_id=?',
          [msgId, chan.channel_id]
        );
        if (ex) {
          await queryDB(
            'UPDATE messages SET ack=?, status=? WHERE wpp_message_id=? AND channel_id=?',
            [ack, stat, msgId, chan.channel_id]
          );
        }
        break;
      }

      /* -- onstatechange -- */
      case 'onstatechange': {
        let newState = (data.state || '').toLowerCase();
        if (['inchat', 'synced', 'main', 'normal', 'pairing', 'opening'].includes(newState))
          newState = 'connected';
        if (['browserclose', 'desconnectedmobile', 'desconnected', 'timeout', 'qrreaderror', 'notlogged'].includes(newState))
          newState = 'disconnected';

        await queryDB(
          'UPDATE channels SET status=?, status_updated_at=NOW() WHERE channel_id=?',
          [newState, chan.channel_id]
        );

        await notifyDbServer(chan);
        break;
      }

      /* -- cualquier otro evento -- */
      default: {
        console.log('Evento no manejado:', evento, data.session);
        break;
      }
    } /* ← fin switch */

    /* siempre devolver 200 para evitar reintentos */
    res.sendStatus(200);

  } catch (err) {
    console.error('Webhook error:', err);
    res.sendStatus(500);
  }
});

/* ---------- Start server ---------- */
const PORT = 3005;
app.listen(PORT, () => console.log(`Webhook escuchando en http://localhost:${PORT}`));
