<%@ page language="java" contentType="text/html; charset=UTF-8" pageEncoding="UTF-8"%>
<!DOCTYPE html>
<html lang="en">
<head>
  <meta charset="UTF-8" />
  <meta name="viewport" content="width=device-width, initial-scale=1" />
  <title>TheRecker — Client Interaction Dashboard</title>
  <link href="https://cdn.jsdelivr.net/npm/bootstrap@5.3.0/dist/css/bootstrap.min.css" rel="stylesheet">
  <style>
    body{min-height:100vh;display:flex;flex-direction:column;background:#f4f6f9}
    .card{border-radius:12px}
    .hero{background:linear-gradient(135deg,#0d6efd22,#6610f222);padding:3rem 1rem}
    footer{margin-top:auto;padding:1rem;background:#fff}
    pre{white-space:pre-wrap}
  </style>
</head>
<body>

<header class="navbar navbar-expand-lg navbar-dark bg-dark">
  <div class="container-fluid">
    <a class="navbar-brand fw-bold" href="#">TheRecker</a>
  </div>
</header>

<section class="hero text-center">
  <h1 class="display-6">Client Browser Intelligence Panel</h1>
  <p class="lead">This page interacts with the client browser to show real, runtime information.</p>
</section>

<main class="container my-4">
  <div class="row g-4">

    <!-- Client Info -->
    <div class="col-md-6">
      <div class="card shadow-sm h-100">
        <div class="card-body">
          <h5 class="card-title">Client Information</h5>
          <ul class="list-group list-group-flush" id="clientInfo"></ul>
        </div>
      </div>
    </div>

    <!-- Network Info -->
    <div class="col-md-6">
      <div class="card shadow-sm h-100">
        <div class="card-body">
          <h5 class="card-title">Network & Location</h5>
          <ul class="list-group list-group-flush" id="networkInfo"></ul>
        </div>
      </div>
    </div>

    <!-- Device Capabilities -->
    <div class="col-md-6">
      <div class="card shadow-sm h-100">
        <div class="card-body">
          <h5 class="card-title">Device Capabilities</h5>
          <ul class="list-group list-group-flush" id="deviceInfo"></ul>
        </div>
      </div>
    </div>

    <!-- Security & Browser -->
    <div class="col-md-6">
      <div class="card shadow-sm h-100">
        <div class="card-body">
          <h5 class="card-title">Security & Browser</h5>
          <ul class="list-group list-group-flush" id="securityInfo"></ul>
        </div>
      </div>
    </div>

  </div>
</main>

<footer class="text-center small text-muted">
  © <span id="year"></span> TheRecker — Client Interaction Dashboard
</footer>

<script src="https://cdn.jsdelivr.net/npm/bootstrap@5.3.0/dist/js/bootstrap.bundle.min.js"></script>
<script>
  document.getElementById('year').textContent = new Date().getFullYear();

  const addItem = (id, key, value) => {
    const li = document.createElement('li');
    li.className = 'list-group-item d-flex justify-content-between align-items-center';
    li.innerHTML = `<strong>${key}</strong><span class='text-muted'>${value}</span>`;
    document.getElementById(id).appendChild(li);
  };

  /* -------- Client / Browser Info -------- */
  const ua = navigator.userAgent;
  addItem('clientInfo','User Agent', ua);
  addItem('clientInfo','Platform', navigator.platform);
  addItem('clientInfo','Language', navigator.language);
  addItem('clientInfo','Languages', navigator.languages.join(', '));
  addItem('clientInfo','Cookies Enabled', navigator.cookieEnabled);
  addItem('clientInfo','Online Status', navigator.onLine);

  /* Browser Detection */
  let browser = 'Unknown';
  if(ua.includes('Chrome') && !ua.includes('Edg')) browser = 'Google Chrome';
  else if(ua.includes('Firefox')) browser = 'Mozilla Firefox';
  else if(ua.includes('Safari') && !ua.includes('Chrome')) browser = 'Apple Safari';
  else if(ua.includes('Edg')) browser = 'Microsoft Edge';
  addItem('securityInfo','Browser', browser);
  addItem('securityInfo','Browser Version', ua);

  /* -------- Device Info -------- */
  addItem('deviceInfo','Screen Resolution', `${screen.width} x ${screen.height}`);
  addItem('deviceInfo','Color Depth', screen.colorDepth);
  addItem('deviceInfo','CPU Cores', navigator.hardwareConcurrency || 'Unknown');
  addItem('deviceInfo','Device Memory (GB)', navigator.deviceMemory || 'Unknown');
  addItem('deviceInfo','Touch Support', 'ontouchstart' in window);

  /* -------- Network Info -------- */
  if(navigator.connection){
    addItem('networkInfo','Network Type', navigator.connection.effectiveType);
    addItem('networkInfo','Downlink (Mb/s)', navigator.connection.downlink);
    addItem('networkInfo','RTT (ms)', navigator.connection.rtt);
    addItem('networkInfo','Save Data Mode', navigator.connection.saveData);
  } else {
    addItem('networkInfo','Network API','Not supported in this browser');
  }

  /* -------- Public IP & Geo Info (client side fetch) -------- */
  fetch('https://api.ipify.org?format=json')
    .then(r=>r.json())
    .then(d=>{
      addItem('networkInfo','Public IP', d.ip);
    })
    .catch(()=>addItem('networkInfo','Public IP','Blocked by network/CORS'));

  fetch('https://ipapi.co/json/')
    .then(r=>r.json())
    .then(loc=>{
      addItem('networkInfo','Country', loc.country_name);
      addItem('networkInfo','City', loc.city);
      addItem('networkInfo','ISP', loc.org);
    })
    .catch(()=>addItem('networkInfo','Geo Info','Blocked by network/CORS'));

  /* -------- Security Info -------- */
  addItem('securityInfo','HTTPS', location.protocol === 'https:' ? 'Yes' : 'No');
  addItem('securityInfo','Do Not Track', navigator.doNotTrack);
  addItem('securityInfo','Referrer', document.referrer || 'Direct Access');

</script>
</body>
</html>
