/********************************************************************
 * wpp‑db‑server – API gestión de canales WPPConnect
 *  • normaliza todos los estados “conectado”  → connected  
 *  • borra completamente la sesión (logout + delete)  
 *  • limpia phone_code al quedar online
 *******************************************************************/
const express  = require('express');
const mysql    = require('mysql2');
const cors     = require('cors');
const axios    = require('axios');
const bodyParser = require('body-parser');

/* ---------- CONFIG DB ---------- */
const pool = mysql.createPool({
  host              : '127.0.0.1',
  user              : 'wpp_user',
  password          : 'StrongPass123_',
  database          : 'wpp_db',
  waitForConnections: true,
  connectionLimit   : 10
});
const queryDB = (sql, p = []) =>
  new Promise((ok, fail) => pool.query(sql, p, (e, r) => (e ? fail(e) : ok(r))));

/* ---------- CONFIG WPP ---------- */
const WPP_SERVER_HOST = 'http://212.85.2.12:21465';
const SECRET_KEY      = 'THISISMYSECURETOKEN';
const WEBHOOK_URL     = 'http://212.85.2.12:3005/wpp-webhook';

/* ---------- helper: token ---------- */
async function generateTokenIfNeeded(chan) {
  if (chan.session_token) return chan.session_token;

  const { data } = await axios.post(
    `${WPP_SERVER_HOST}/api/${chan.session_name}/${SECRET_KEY}/generate-token`
  );
  if (!data.token) throw new Error('No llegó token');
  await queryDB(
    'UPDATE channels SET session_token=? WHERE channel_id=?',
    [data.token, chan.channel_id]
  );
  return data.token;
}

/* ---------- Express ---------- */
const app = express();
app.use(cors());
app.use(bodyParser.json());
app.use(bodyParser.urlencoded({ extended: true }));

/* ============================== CRUD ============================== */
app.get('/channels', async (_req, res) => {
  try { res.json(await queryDB('SELECT * FROM channels')); }
  catch (e) { res.status(500).json({ error: e.message }); }
});

app.post('/channels', async (req, res) => {
  try {
    const b = req.body;
    const r = await queryDB(
      `INSERT INTO channels
         (phone_number,display_name,session_name,
          proxy_ip,proxy_port,proxy_user,proxy_pass,use_proxy)
       VALUES (?,?,?,?,?,?,?,?)`,
      [null, '', b.session_name,
       b.proxy_ip||null, b.proxy_port||null,
       b.proxy_user||null, b.proxy_pass||null,
       b.use_proxy ? 1 : 0]
    );
    res.json({ message: 'Canal creado', channel_id: r.insertId });
  } catch (e) { res.status(500).json({ error: e.message }); }
});
/* =================================================================
 * BORRAR canal  →  close‑session · logout‑session · delete‑session
 * ================================================================= */
app.delete('/channels/:id', async (req, res) => {
  try {
    const [chan] = await queryDB('SELECT * FROM channels WHERE channel_id=?',[req.params.id]);
    if (!chan) return res.status(404).json({ error:'Canal no encontrado' });

    const token = await generateTokenIfNeeded(chan);
    const hdr   = { headers:{ Authorization:`Bearer ${token}` } };

    await axios.post(`${WPP_SERVER_HOST}/api/${chan.session_name}/close-session`,  {}, hdr)
               .catch(()=>{});
    await axios.post(`${WPP_SERVER_HOST}/api/${chan.session_name}/logout-session`, {}, hdr)
               .catch(()=>{});
    await axios.post(`${WPP_SERVER_HOST}/api/${chan.session_name}/delete-session`, {}, hdr)
               .catch(()=>{});

    await queryDB('DELETE FROM channels WHERE channel_id=?',[chan.channel_id]);
    res.json({ message:'Canal y sesión borrados por completo' });
  } catch (err) {
    console.error('deleteChannel:', err.response?.data || err);
    res.status(500).json({ error: err.message });
  }
});

/* ========================== Sesiones ============================== */
app.post('/channels/:id/start-session', async (req, res) => {
  try {
    const [c] = await queryDB('SELECT * FROM channels WHERE channel_id=?',[req.params.id]);
    if (!c) return res.status(404).json({ error:'Canal no encontrado' });

    const tk     = await generateTokenIfNeeded(c);
    const method = (req.body.method || 'qr').toLowerCase();

    const payload = {
      webhook       : WEBHOOK_URL,
      waitQrCode    : false,
      storeOptions  : { dbType:'file', folderNameToken:'tokens' },
      sessionOptions: { multidevice:true },
      createOptions : { headless:true, browserArgs:['--no-sandbox','--disable-setuid-sandbox'] }
    };
    if (method === 'code') { payload.loginType='code'; payload.phone=req.body.phone; }

    await axios.post(`${WPP_SERVER_HOST}/api/${c.session_name}/start-session`,
                     payload,{ headers:{ Authorization:`Bearer ${tk}` } });

    await queryDB(
      'UPDATE channels SET status="initializing", phone_code=NULL, status_updated_at=NOW() WHERE channel_id=?',
      [c.channel_id]
    );
    res.json({ message:'Sesión iniciándose', status:'initializing' });
  } catch (e) { res.status(500).json({ error:e.message }); }
});

app.post('/channels/:id/verify-code', async (req,res)=>{
  try{
    const [c] = await queryDB('SELECT * FROM channels WHERE channel_id=?',[req.params.id]);
    if(!c) return res.status(404).json({ error:'Canal no encontrado' });
    const tk = await generateTokenIfNeeded(c);
    await axios.post(`${WPP_SERVER_HOST}/api/${c.session_name}/confirm-code`,
                     { code:req.body.code },
                     { headers:{ Authorization:`Bearer ${tk}` } });
    res.json({ message:'Código enviado' });
  }catch(e){ res.status(500).json({ error:e.message }); }
});

/* ======================== Refresh‑status ========================== */
app.get('/channels/:id/refresh-status', async (req,res)=>{
  try{
    const [c] = await queryDB('SELECT * FROM channels WHERE channel_id=?',[req.params.id]);
    if(!c) return res.status(404).json({ error:'Canal no encontrado' });
    const tk = await generateTokenIfNeeded(c);

    let newState = (c.status || '').toLowerCase();
    try{
      const { data } = await axios.get(
        `${WPP_SERVER_HOST}/api/${c.session_name}/status-session`,
        { headers:{ Authorization:`Bearer ${tk}` } }
      );
      newState = (data.status||data.state||'').toLowerCase();
    }catch{ newState='disconnected'; }

    /* normalización */
    if (['inchat','synced','main','normal','pairing','opening']
      .includes(newState))  newState = 'connected';
    if(['browserclose','desconnectedmobile','desconnected'].includes(newState))
      newState = 'disconnected';

    /* QR */
    let newQr = null;
    if(newState.includes('qr')){
      const qr = await axios.get(
        `${WPP_SERVER_HOST}/api/${c.session_name}/qrcode-session`,
        { headers:{ Authorization:`Bearer ${tk}` }, responseType:'arraybuffer' }
      );
      newQr=`data:image/png;base64,${Buffer.from(qr.data,'binary').toString('base64')}`;
    }

    await queryDB(
      'UPDATE channels SET status=?,qr_code=?,status_updated_at=NOW() WHERE channel_id=?',
      [newState,newQr,c.channel_id]
    );
    c.status=newState; c.qr_code=newQr;

    /* conectado: host‑device + limpiar código */
    if(newState==='connected'){
      if(!c.phone_number){
        try{
          const dev=await axios.get(
            `${WPP_SERVER_HOST}/api/${c.session_name}/host-device`,
            { headers:{ Authorization:`Bearer ${tk}` } }
          );
          const phone=(dev.data?.response?.phoneNumber||'').replace('@c.us','');
          if(phone){
            await queryDB('UPDATE channels SET phone_number=? WHERE channel_id=?',[phone,c.channel_id]);
            c.phone_number=phone;
          }
        }catch{/* ignore */}
      }
      await queryDB('UPDATE channels SET phone_code=NULL WHERE channel_id=?',[c.channel_id]);
      c.phone_code=null;
    }

    res.json({ message:'Estado refrescado', channel:c });
  }catch(e){
    console.error('refresh-status:',e);
    res.status(500).json({ error:e.message });
  }
});

/* ------------------ LISTEN ------------------ */
app.listen(3001,()=>console.log('[wpp-db-server] Port 3001'));
