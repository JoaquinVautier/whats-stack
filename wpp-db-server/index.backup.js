const express = require('express');
const bodyParser = require('body-parser');
const mysql = require('mysql2');
const cors = require('cors');
const axios = require('axios');

/**
 * CONFIG MySQL
 */
const dbConfig = {
  host: '127.0.0.1',
  user: 'wpp_user',
  password: 'StrongPass123_',
  database: 'wpp_db'
};

/**
 * CONFIG WPPConnect
 */
const WPP_SERVER_HOST = 'http://212.85.2.12:21465'; 
const SECRET_KEY = 'THISISMYSECURETOKEN';
const WEBHOOK_URL = 'http://212.85.2.12:3005/wpp-webhook'; 
const pool = mysql.createPool({
  ...dbConfig,
  waitForConnections: true,
  connectionLimit: 10,
  queueLimit: 0
});
function queryDB(sql, params=[]) {
  return new Promise((resolve, reject) => {
    pool.query(sql, params, (err, results) => {
      if (err) {
        console.error('DB Error:', err);
        return reject(err);
      }
      resolve(results);
    });
  });
}

const app = express();
app.use(cors());
app.use(bodyParser.json());
app.use(bodyParser.urlencoded({ extended: true }));

/**
 * ============================
 * 1) CRUD Channels
 * ============================
 */
app.get('/channels', async (req, res) => {
  try {
    const rows = await queryDB('SELECT * FROM channels');
    res.json(rows);
  } catch (error) {
    res.status(500).json({ error: error.message });
  }
});

app.post('/channels', async (req, res) => {
  try {
    const {
      session_name,
      proxy_ip,
      proxy_port,
      proxy_user,
      proxy_pass,
      use_proxy
    } = req.body;

    // phone_number lo dejamos NULL. El user no lo ingresa
    // display_name si quieres poner algo, o lo dejamos ''
    const sql = `
      INSERT INTO channels (
        phone_number,
        display_name,
        session_name,
        proxy_ip, proxy_port, proxy_user, proxy_pass, use_proxy
      ) VALUES (?,?,?,?,?,?,?,?)
    `;
    const result = await queryDB(sql, [
      null, // phone_number
      '',   // display_name
      session_name,
      proxy_ip || null,
      proxy_port || null,
      proxy_user || null,
      proxy_pass || null,
      use_proxy ? 1 : 0
    ]);
    res.json({ message: 'Canal creado', channel_id: result.insertId });
  } catch (error) {
    res.status(500).json({ error: error.message });
  }
});

app.get('/channels/:channelId', async (req, res) => {
  try {
    const [chan] = await queryDB('SELECT * FROM channels WHERE channel_id=?', [req.params.channelId]);
    if (!chan) {
      return res.status(404).json({ error: 'Canal no encontrado' });
    }
    res.json(chan);
  } catch (error) {
    res.status(500).json({ error: error.message });
  }
});

app.delete('/channels/:channelId', async (req, res) => {
  try {
    const [chan] = await queryDB('SELECT * FROM channels WHERE channel_id=?', [req.params.channelId]);
    if (!chan) {
      return res.status(404).json({ error: 'Canal no encontrado' });
    }

    // 1) Llamamos a /close-session en WPPConnect
    const wppUrl = `${WPP_SERVER_HOST}/api/${chan.session_name}/close-session`; // o logout-session
    await axios.post(wppUrl, {}, {
      headers: {
        Authorization: `Bearer ${chan.session_token}`
      }
    });

    // 2) Eliminamos la fila en la DB
    await queryDB('DELETE FROM channels WHERE channel_id=?', [chan.channel_id]);
    res.json({ message: 'Canal y sesión borrados' });
  } catch (error) {
    console.error('Error al borrar canal:', error);
    res.status(500).json({ error: error.message });
  }
});

/**
 * ============================
 * 2) Token / Sesión
 * ============================
 */
// Generar token si no existe
async function generateTokenIfNeeded(channel) {
  if (channel.session_token) {
    return channel.session_token;
  }
  // Llama a /generate-token
  const url = `${WPP_SERVER_HOST}/api/${channel.session_name}/${SECRET_KEY}/generate-token`;
  const resp = await axios.post(url);
  if (!resp.data.token) {
    throw new Error('No llegó "token" en generate-token');
  }
  await queryDB(
    'UPDATE channels SET session_token=? WHERE channel_id=?',
    [resp.data.token, channel.channel_id]
  );
  return resp.data.token;
}

// Start session => genera token => llama /start-session
app.post('/channels/:channelId/start-session', async (req, res) => {
  try {
    const [chan] = await queryDB('SELECT * FROM channels WHERE channel_id=?', [req.params.channelId]);
    if (!chan) {
      return res.status(404).json({ error: 'Canal no encontrado' });
    }
    const usableToken = await generateTokenIfNeeded(chan);

    // Llama /start-session
    const url = `${WPP_SERVER_HOST}/api/${chan.session_name}/start-session`;
    await axios.post(url, {
      // Opciones para guardar la sesión en archivos JSON
  storeOptions: {
    dbType: "file",             // 'file' indica que se usará persistencia en disco
    folderNameToken: "tokens"   // Carpeta donde se crean los .store.json
  },
  // Opciones de la sesión, por ejemplo multidevice
  sessionOptions: {
    multidevice: true
  },
  // Opciones de Puppeteer (no incluyas userDataDir si vas a usar persistencia en JSON)
  createOptions: {
    headless: true,
    browserArgs: [
      "--no-sandbox",
      "--disable-setuid-sandbox"
    ]
  },
  // Tu webhook base
  webhook: WEBHOOK_URL,
  // Esperar a que se lea o no el QR antes de continuar
  waitQrCode: false
}, {
  headers: { Authorization: `Bearer ${usableToken}` }
});

    // Actualiza status local
    await queryDB(
      'UPDATE channels SET status=?, status_updated_at=NOW() WHERE channel_id=?',
      ['qr_waiting', chan.channel_id]
    );

    res.json({ message: 'Sesión iniciada (o en proceso) en WPPConnect', status: 'qr_waiting' });
  } catch (error) {
    console.error('Error startSession:', error);
    res.status(500).json({ error: error.message });
  }
}

/**
 * 2.3 refresh-status => llama /status-session, si hay QR => /qrcode-session => lo guarda en channels.qr_code
 * si conectado => si phone_number es NULL => llama /host-device => actualiza phone_number
 */
);

app.get('/channels/:channelId/refresh-status', async (req, res) => {
  try {
    const channelId = req.params.channelId;
    const [chan] = await queryDB('SELECT * FROM channels WHERE channel_id=?', [channelId]);
    if (!chan) {
      return res.status(404).json({ error: 'Canal no encontrado' });
    }

    // Generar token si no existe
    let token = chan.session_token;
    if (!token) {
      token = await generateTokenIfNeeded(chan);
      chan.session_token = token;
    }

    // Llama /status-session
    const urlStatus = `${WPP_SERVER_HOST}/api/${chan.session_name}/status-session`;
    const respStatus = await axios.get(urlStatus, {
      headers: { Authorization: `Bearer ${chan.session_token}` }
    });
    const dataStatus = respStatus.data; // e.g. {session, status: "QRCODE"/"CONNECTED", ...}
    let finalState = dataStatus.status || 'unknown';

    let newQr = null;
    if (finalState.toLowerCase().includes('qr')) {
      // /qrcode-session => arraybuffer => base64
      const urlQr = `${WPP_SERVER_HOST}/api/${chan.session_name}/qrcode-session`;
      const respQr = await axios.get(urlQr, {
        headers: { Authorization: `Bearer ${chan.session_token}` },
        responseType: 'arraybuffer'
      });
      newQr = `data:image/png;base64,${Buffer.from(respQr.data, 'binary').toString('base64')}`;

      // Actualizamos DB
      await queryDB(
        'UPDATE channels SET status=?, qr_code=?, status_updated_at=NOW() WHERE channel_id=?',
        [finalState, newQr, channelId]
      );
      chan.status = finalState;
      chan.qr_code = newQr;
    } else {
      // Distinto de QR => definimos qr_code=NULL
      await queryDB(
        'UPDATE channels SET status=?, qr_code=NULL, status_updated_at=NOW() WHERE channel_id=?',
        [finalState, channelId]
      );
      chan.status = finalState;
      chan.qr_code = null;
    }

    // Si finalState=connected => si phone_number es NULL => llama /host-device => update channels.phone_number
    if (finalState.toLowerCase().includes('connected') && !chan.phone_number) {
      try {
        const urlDevice = `${WPP_SERVER_HOST}/api/${chan.session_name}/host-device`;
        const respDev = await axios.get(urlDevice, {
          headers: { Authorization: `Bearer ${chan.session_token}` }
        });
        // respDev.data => { me: { user: "549111..." } }
        if (
  respDev.data &&
  respDev.data.response &&
  respDev.data.response.phoneNumber
) {
  let phone = respDev.data.response.phoneNumber; // e.g. "5492234978199@c.us"
  // Opcional: remover "@c.us"
  phone = phone.replace('@c.us', '');

  await queryDB(
    'UPDATE channels SET phone_number=? WHERE channel_id=?',
    [phone, channelId]
  );
  chan.phone_number = phone;
  console.log('Host-device => phone_number:', phone);
}
      } catch (err) {
        console.error('Error host-device:', err);
      }
    }

    res.json({
      message: 'Estado refrescado',
      channel: chan
    });
  } catch (error) {
    console.error('Error refresh-status:', error);
    res.status(500).json({ error: error.message });
  }
});

/**
 * =============================
 * 3) WEBHOOKS
 * =============================
 */
app.post('/webhook/messages', async (req, res) => {
  try {
    const payload = req.body;
    console.log('[WEBHOOK messages] =>', payload);

    const fromNumber = (payload.from || '').replace('@c.us', '');
    const toNumber   = (payload.to || '').replace('@c.us', '');
    const direction = payload.fromMe ? 'OUT' : 'IN';

    const sqlFind = `SELECT channel_id, phone_number FROM channels WHERE phone_number=? OR phone_number=? LIMIT 1`;
    let rows;
    if (direction === 'IN') {
      rows = await queryDB(sqlFind, [toNumber, fromNumber]);
    } else {
      rows = await queryDB(sqlFind, [fromNumber, toNumber]);
    }
    if (!rows.length) {
      console.log('No se encontró canal. from=', fromNumber, 'to=', toNumber);
      return res.json({ message: 'No channel matched' });
    }
    const channel = rows[0];

    // Insertar en messages
    const insSql = `
      INSERT INTO messages (
        channel_id,
        from_number,
        to_number,
        direction,
        message_content,
        message_type,
        media_url,
        status
      ) VALUES (?,?,?,?,?,?,?,?)
    `;
    await queryDB(insSql, [
      channel.channel_id,
      fromNumber,
      toNumber,
      direction,
      payload.body || '',
      payload.type || 'text',
      payload.mediaUrl || null,
      'sent'
    ]);

    res.json({ message: 'OK' });
  } catch (error) {
    console.error('Error webhook/messages:', error);
    res.status(500).json({ error: error.message });
  }
});

app.post('/webhook/status', async (req, res) => {
  try {
    const payload = req.body;
    console.log('[WEBHOOK status] =>', payload);

    const { session, previousState, currentState, reason } = payload;
    const rows = await queryDB(
      'SELECT channel_id, status FROM channels WHERE session_name=? LIMIT 1',
      [session]
    );
    if (!rows.length) {
      return res.json({ message: 'No channel found' });
    }
    const channel = rows[0];

    const finalState = currentState || 'disconnected';
    const lastError = reason || null;

    await queryDB(
      'UPDATE channels SET status=?, last_error=?, status_updated_at=NOW() WHERE channel_id=?',
      [finalState, lastError, channel.channel_id]
    );

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

    res.json({ message: 'Estado de canal actualizado' });
  } catch (error) {
    console.error('Error webhook/status:', error);
    res.status(500).json({ error: error.message });
  }
});



/****************************************************************************
 * Warmup Rutas y Lógica
 ****************************************************************************/
/**
 * POST /warmup/start
 * body:
 * {
 *   "filter": "calientes" | "sin_calentar" | "calentándose" | "todos",
 *   "config": {
 *     "minInterval": 30, 
 *     "maxInterval": 120,
 *     "typoProbability": 0.1,
 *     "phrases": ["Hola","¿Todo bien?","Saludos"],
 *     "includeReactions": true
 *     // etc.
 *   }
 * }
 */
app.post('/warmup/start', async (req, res) => {
  try {
    const { filter, config } = req.body;

    // 1) Seleccionar canales segun filter
    let sqlFilter = '';
    if (filter === 'calientes') {
      sqlFilter = 'WHERE warmup_status IN ("done","in_progress")';
    } else if (filter === 'sin_calentar') {
      sqlFilter = 'WHERE warmup_status="none"';
    } else if (filter === 'calentándose') {
      sqlFilter = 'WHERE warmup_status="in_progress"';
    } 
    // "todos" => sin where

    const sql = `SELECT * FROM channels ${sqlFilter}`;
    const channels = await queryDB(sql);

    // 2) Actualizar DB => warmup_status='in_progress', warmup_config = JSON
    for (const chan of channels) {
      const newStatus = 'in_progress';
      const newConfig = JSON.stringify(config);
      await queryDB(
        'UPDATE channels SET warmup_status=?, warmup_config=? WHERE channel_id=?',
        [newStatus, newConfig, chan.channel_id]
      );
      chan.warmup_status = newStatus;
      chan.warmup_config = newConfig;
    }

    // 3) Llamar a startWarmupRoutine con estos channels
    startWarmupRoutine(channels);

    res.json({ 
      message: 'Warmup iniciado', 
      filteredChannels: channels.length 
    });
  } catch (error) {
    console.error('Error /warmup/start:', error);
    res.status(500).json({ error: error.message });
  }
});

/**
 * Empieza la rutina => crea timers que llaman API oficial WPPConnect
 */
function startWarmupRoutine(channels) {
  for (const chan of channels) {
    scheduleNextAction(chan);
  }

  function scheduleNextAction(chan) {
    if (chan.warmup_status !== 'in_progress') return;

    let config = {};
    try {
      config = JSON.parse(chan.warmup_config);
    } catch (e) {
      console.error('Error parse warmup_config:', e);
      return;
    }

    const minI = config.minInterval || 30;
    const maxI = config.maxInterval || 120;
    const interval = randomBetween(minI, maxI) * 1000;

    setTimeout(async () => {
      await doRandomAction(chan, config);
      scheduleNextAction(chan);
    }, interval);
  }

  async function doRandomAction(chan, config) {
    try {
      // Ejemplo: [sendMessage, react, typing]
      const actions = ['sendMessage','typing'];
      if (config.includeReactions) actions.push('react');

      const action = pickRandom(actions);

      const session = chan.session_name;
      const token = chan.session_token;
      if (!session || !token) {
        console.log('Falta session o token', chan.channel_id);
        return;
      }

      if (action === 'sendMessage') {
        const phrases = config.phrases || ["Hola","Buen día","¿Todo bien?"];
        const text = pickRandom(phrases);
        const typed = applyTypos(text, config.typoProbability || 0.1);

        // Llama /send-message
        await axios.post(`http://212.85.2.12:21465/api/${session}/send-message`,
          {
            phone: chan.phone_number,
            message: typed
          },
          {
            headers: { Authorization: `Bearer ${token}` }
          }
        );
        console.log(`[warmup] sendMessage to ${chan.phone_number}: "${typed}"`);

      } else if (action === 'typing') {
        // /typing => simula "escribiendo"
        await axios.post(`http://212.85.2.12:21465/api/${session}/typing`,
          { phone: chan.phone_number },
          { headers: { Authorization: `Bearer ${token}` } }
        );
        console.log(`[warmup] typing to ${chan.phone_number}`);

        // esperar 3 seg
        await delay(3000);

        // /recording => simula "grabando audio"
        await axios.post(`http://212.85.2.12:21465/api/${session}/recording`,
          { phone: chan.phone_number },
          { headers: { Authorization: `Bearer ${token}` } }
        );
        console.log(`[warmup] recording to ${chan.phone_number}`);

      } else if (action === 'react') {
        const randomEmoji = pickRandom(["\uD83D\uDE00","\u2764","\uD83D\uDE02","\uD83D\uDE0A"]);
        // hipotético: buscar un msg anterior?
        // Hardcodeado => "someMsgId"
        const someMsgId = "true_XXXXXXXXXXXX@c.us_randomID";
        await axios.post(`http://212.85.2.12:21465/api/${session}/react-message`,
          {
            phone: chan.phone_number + "@c.us",
            msgId: someMsgId,
            emoji: randomEmoji
          },
          { headers: { Authorization: `Bearer ${token}` } }
        );
        console.log(`[warmup] reaction ${randomEmoji} to msgId ${someMsgId}`);
      }
    } catch (err) {
      console.error('Error doRandomAction:', err);
    }
  }

  function randomBetween(min, max) {
    return Math.floor(Math.random()*(max-min+1)) + min;
  }
  function pickRandom(arr) {
    return arr[Math.floor(Math.random()*arr.length)];
  }
  function applyTypos(text, prob) {
    if (prob <= 0) return text;
    let out = '';
    for (let c of text) {
      if (Math.random() < prob) {
        out += randomChar();
      } else {
        out += c;
      }
    }
    return out;
  }
  function randomChar() {
    const alpha = "abcdefghijklmnopqrstuvwxyz";
    return alpha[Math.floor(Math.random()*alpha.length)];
  }
  function delay(ms) {
    return new Promise(res => setTimeout(res, ms));
  }
}
/**
 * LEVANTAR SERVIDOR
 */
const PORT = 3001;
app.listen(PORT, () => {
  console.log(`[wpp-db-server] Running on port ${PORT}`);
});
