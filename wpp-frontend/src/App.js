/********************************************************************
 * src/App.js  – Gestor de canales WPPConnect (QR + Código SMS)
 * Versión simplificada SIN sección Warm‑up
 *******************************************************************/
import React, { useState, useEffect, useRef } from 'react';
import { BrowserRouter as Router, Routes, Route, Link } from 'react-router-dom';
import axios from 'axios';
import { ToastContainer, toast } from 'react-toastify';
import 'react-toastify/dist/ReactToastify.css';
import { confirmAlert } from 'react-confirm-alert';
import 'react-confirm-alert/src/react-confirm-alert.css';
import './App.css';

const BASE_DB_URL = 'db';

function App() {
  /* ---------------------- Estados principales ---------------------- */
  const [channels, setChannels] = useState([]);
  const [sessionName, setSessionName] = useState('');
  const [proxyIp, setProxyIp] = useState('');
  const [proxyPort, setProxyPort] = useState('');
  const [proxyUser, setProxyUser] = useState('');
  const [proxyPass, setProxyPass] = useState('');
  const [useProxy, setUseProxy] = useState(false);

  /* ------------------- Estados para el Modal ------------------- */
  const [modalOpen, setModalOpen] = useState(false);
  const [modalStep, setModalStep] = useState(''); // METHOD | GENERATING | SHOW_QR | SHOW_CODE | AWAIT_CODE | CONNECTED | ERROR
  const [modalChannel, setModalChannel] = useState(null);
  const [qrImage, setQrImage] = useState(null);
  const [codeTmp, setCodeTmp] = useState('');
  const pollingRef = useRef(null);
  const [phoneNumber, setPhoneNumber] = useState('');

  /* ----------------------------- Efectos ----------------------------- */
  useEffect(() => { fetchChannels(); }, []);

  const fetchChannels = async () => {
  try {
    const res = await axios.get(`${BASE_DB_URL}/channels`);
    setChannels(res.data);

    // Para cada canal, actualizar estado real inmediatamente
    res.data.forEach(async (channel) => {
      await axios.get(`${BASE_DB_URL}/channels/${channel.channel_id}/refresh-status`);
    });

    // Luego de refrescar estados, vuelve a consultar la lista actualizada
    setTimeout(async () => {
      const updatedRes = await axios.get(`${BASE_DB_URL}/channels`);
      setChannels(updatedRes.data);
    }, 2000);  // espera 2 segundos para asegurar actualización
  } catch {
    toast.error('Error al cargar canales');
  }
};

  /* -------------------------- Crear canal -------------------------- */
  const createChannel = async () => {
    if (!sessionName) { toast.error('Falta Session Name'); return; }
    try {
      await axios.post(`${BASE_DB_URL}/channels`, {
        session_name: sessionName,
        proxy_ip: proxyIp || null,
        proxy_port: proxyPort || null,
        proxy_user: proxyUser || null,
        proxy_pass: proxyPass || null,
        use_proxy: useProxy ? 1 : 0
      });
      toast.success('Canal creado ✔');
      setSessionName(''); setProxyIp(''); setProxyPort(''); setProxyUser(''); setProxyPass(''); setUseProxy(false);
      fetchChannels();
    } catch { toast.error('No se pudo crear el canal'); }
  };

  /* -------------------------- Borrar canal -------------------------- */
  const deleteChannel = (chan) => {
    confirmAlert({
      title: 'Confirmar',
      message: `Eliminar canal ${chan.session_name}?`,
      buttons: [ { label: 'Sí', onClick: () => proceedDelete(chan) }, { label: 'No' } ]
    });
  };
  const proceedDelete = async (chan) => {
    try { await axios.delete(`${BASE_DB_URL}/channels/${chan.channel_id}`); toast.success('Canal eliminado ✔'); fetchChannels(); }
    catch { toast.error('No se pudo eliminar'); }
  };

  /* ---------------------- Iniciar / Ver QR / Código ---------------------- */
  const openStartModal = (chan) => {
    setModalChannel(chan);
    setModalStep('METHOD');
    setQrImage(null);
    setCodeTmp('');
    setModalOpen(true);
  };

  const initiateSession = async (method, phone = null) => {
    try {
      setModalStep('GENERATING');
      const body = { method };
      if (phone) body.phone = phone;
      await axios.post(`${BASE_DB_URL}/channels/${modalChannel.channel_id}/start-session`, body);
      startPolling(modalChannel.channel_id);
    } catch { setModalStep('ERROR'); }
  };

  /* ----------------------------- Polling ----------------------------- */
  const startPolling = (id) => {
    stopPolling();
    pollingRef.current = setInterval(async () => {
      const up = await refreshStatus(id);
      if (!up) return;
      const st = (up.status || '').toLowerCase();

      if (up.qr_code && st.includes('qr')) {
        setQrImage(up.qr_code);
        setModalStep('SHOW_QR');
      }
      if (up.phone_code) {
        setCodeTmp(up.phone_code);
        setModalStep('SHOW_CODE');
      }
      if (st.includes('code_sent')) setModalStep('AWAIT_CODE');
      if (st.includes('connected')) {
        setModalStep('CONNECTED');
        stopPolling();
        setTimeout(() => setModalOpen(false), 1000);
      }
    }, 3000);
  };
  const stopPolling = () => { if (pollingRef.current) clearInterval(pollingRef.current); };
  const refreshStatus = async (id) => {
    try {
      const r = await axios.get(`${BASE_DB_URL}/channels/${id}/refresh-status`);
      const up = r.data.channel;
      if (up) setChannels(p => p.map(c => c.channel_id === up.channel_id ? up : c));
      return up;
    } catch { return null; }
  };

  /* ------------------------ Enviar código SMS ------------------------ */
  const sendCode = async () => {
    if (codeTmp.length !== 6) { toast.error('Código inválido'); return; }
    try {
      await axios.post(`${BASE_DB_URL}/channels/${modalChannel.channel_id}/verify-code`, { code: codeTmp });
      setModalStep('GENERATING');
    } catch { toast.error('Error al verificar código'); }
  };

  const closeModal = () => { stopPolling(); setModalOpen(false); };

  /* ------------------------------ UI ------------------------------ */
  return (
    <>
      <Router>
        <nav style={{ padding: 8 }}>
          <Link to="/">Inicio</Link>
        </nav>
        <Routes>
          <Route path="/" element={<div />} />
        </Routes>
      </Router>

      <div className="app-container">
        <div className="header"><h1>WhatsApp Masivo – Gestor</h1></div>

        <div className="content">
          {/* Formulario alta */}
          <div className="create-channel-form">
            <input placeholder="Session Name" value={sessionName} onChange={e=>setSessionName(e.target.value)} />
            <input placeholder="Proxy IP" value={proxyIp} onChange={e=>setProxyIp(e.target.value)} />
            <input placeholder="Proxy Port" value={proxyPort} onChange={e=>setProxyPort(e.target.value)} />
            <input placeholder="Proxy User" value={proxyUser} onChange={e=>setProxyUser(e.target.value)} />
            <input placeholder="Proxy Pass" value={proxyPass} onChange={e=>setProxyPass(e.target.value)} />
            <label style={{display:'flex',alignItems:'center',gap:4}}>
              <input type="checkbox" checked={useProxy} onChange={()=>setUseProxy(!useProxy)} /> Proxy
            </label>
            <button onClick={createChannel}>Crear Canal</button>
          </div>

          {/* Grid de canales */}
          <div className="channels-grid">
            {channels.map(chan=>{
              const ok = (chan.status||'').toLowerCase().includes('connected');
              return (
                <div key={chan.channel_id} className="channel-card">
                  <div className="channel-card-header">{chan.session_name}</div>
                  <div className="channel-card-body">
                    <p><strong>Phone:</strong> {chan.phone_number||'N/A'}</p>
                    <p><strong>Token:</strong> {chan.session_token||'N/A'}</p>
                    <p><strong>Status:</strong> { ok ? <span className="status-connected">Conectado</span> : chan.status }</p>
                  </div>
                  <div className="channel-card-footer">
                    <button className="btn btn-blue" onClick={()=>openStartModal(chan)}>
                      {!chan.status||chan.status==='new' ? 'Iniciar' : 'Ver QR / Código'}
                    </button>
                    <button className="btn btn-red" onClick={()=>deleteChannel(chan)}>Borrar</button>
                  </div>
                </div>
              );
            })}
          </div>
        </div>
      </div>

      {/* ----------------------- MODAL ----------------------- */}
      {modalOpen && (
        <div className="modal-overlay">
          <div className="modal-content">
            <button className="modal-close" onClick={closeModal}>×</button>

            {modalStep === 'METHOD' && (
  <>
    <h2>¿Cómo iniciar la sesión?</h2>
    <button className="btn btn-blue" style={{ margin: 6 }} onClick={() => initiateSession('qr')}>
      Con QR
    </button>
    <button className="btn btn-yellow" style={{ margin: 6 }} onClick={() => setModalStep('ENTER_PHONE')}>
      Con Código
    </button>
  </>
)}

{modalStep === 'ENTER_PHONE' && (
  <>
    <h2>Ingresa el número de teléfono</h2>
    <input
      type="text"
      placeholder="Número con código país, ej: 54911XXXXXXX"
      style={{ padding: 8, marginTop: 8, width: '100%' }}
      value={phoneNumber}
      onChange={(e) => setPhoneNumber(e.target.value)}
    />
    <button
      className="btn btn-blue"
      style={{ marginTop: 8 }}
      onClick={() => {
        if (!phoneNumber) {
          toast.error('Debes ingresar un número válido');
          return;
        }
        initiateSession('code', phoneNumber);
      }}
    >
      Enviar Código
    </button>
    <button
      className="btn btn-gray"
      style={{ marginTop: 8, marginLeft: 6 }}
      onClick={() => setModalStep('METHOD')}
    >
      Volver
    </button>
  </>
)}

            {modalStep === 'GENERATING' && (
              <>
                <h2>Generando conexión…</h2>
                <img className="modal-spinner" src="https://media.giphy.com/media/3o7aCXAFrVnC0TBmWY/giphy.gif" alt="spinner" />
                <p>Espera un momento…</p>
              </>
            )}

            {modalStep === 'SHOW_QR' && qrImage && (
              <>
                <h2>Escanea este QR</h2>
                <img className="qr-image" src={qrImage} alt="QR" />
                <p>Abre WhatsApp y escanéalo.</p>
              </>
            )}

            {modalStep === 'SHOW_CODE' && (
              <>
                <h2>Código para tu dispositivo</h2>
                <p style={{ fontSize: 24, fontWeight: 'bold' }}>{codeTmp}</p>
                <p>En tu WhatsApp del teléfono, escribe este código para confirmar.</p>
              </>
            )}

            {modalStep === 'AWAIT_CODE' && (
              <>
                <h2>Ingresa el código SMS</h2>
                <input style={{ padding: 8, marginTop: 8 }} maxLength={6}
                       value={codeTmp} onChange={e=>setCodeTmp(e.target.value)} />
                <button className="btn btn-blue" style={{ marginTop: 8 }} onClick={sendCode}>
                  Enviar
                </button>
              </>
            )}

            {modalStep === 'CONNECTED' && (
              <>
                <h2 style={{ color: '#2CA45E' }}>¡Conectado!</h2>
                <p>El canal está online.</p>
              </>
            )}

            {modalStep === 'ERROR' && (
              <>
                <h2 style={{ color: '#E63946' }}>Error</h2>
                <p>No se pudo iniciar la sesión.</p>
              </>
            )}
          </div>
        </div>
      )}

      <ToastContainer position="bottom-right" theme="colored" />
    </>
  );
}

export default App;
