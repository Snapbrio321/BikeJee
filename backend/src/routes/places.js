import express from 'express';

const router = express.Router();

const PLACES_BASE = 'https://maps.googleapis.com/maps/api/place';
const DISTANCE_BASE = 'https://maps.googleapis.com/maps/api/distancematrix/json';
const KEY = () => process.env.GOOGLE_MAPS_KEY || '';

/**
 * Server-side proxy for Google Maps APIs. The browser can't call Google's
 * Places/Distance Matrix directly (CORS), and the key must never ship in the
 * client. These endpoints call Google from the server and return clean JSON.
 */

// GET /places/search?q=koramangala&lat=..&lng=..
router.get('/search', async (req, res) => {
  const q = (req.query.q || '').toString().trim();
  if (!KEY()) return res.json({ places: [] });
  if (!q) return res.json({ places: [] });
  try {
    const params = new URLSearchParams({
      input: q,
      key: KEY(),
      components: 'country:in',
    });
    if (req.query.lat && req.query.lng) {
      params.set('location', `${req.query.lat},${req.query.lng}`);
      params.set('radius', '50000');
    }
    const r = await fetch(`${PLACES_BASE}/autocomplete/json?${params}`);
    const data = await r.json();
    const places = (data.predictions || []).map((p) => ({
      id: p.place_id,
      name: p.structured_formatting?.main_text || p.description,
      address: p.structured_formatting?.secondary_text || p.description,
      type: 'search',
    }));
    return res.json({ places });
  } catch (e) {
    console.error('places search failed:', e.message);
    return res.json({ places: [] });
  }
});

// GET /places/details?id=<place_id>
router.get('/details', async (req, res) => {
  const id = (req.query.id || '').toString();
  if (!KEY() || !id) return res.status(400).json({ error: 'missing id' });
  try {
    const params = new URLSearchParams({
      place_id: id,
      key: KEY(),
      fields: 'geometry,name,formatted_address',
    });
    const r = await fetch(`${PLACES_BASE}/details/json?${params}`);
    const data = await r.json();
    const result = data.result;
    const loc = result?.geometry?.location;
    if (!loc) return res.status(404).json({ error: 'no location' });
    return res.json({
      id,
      name: result.name || '',
      address: result.formatted_address || '',
      lat: loc.lat,
      lng: loc.lng,
    });
  } catch (e) {
    console.error('place details failed:', e.message);
    return res.status(500).json({ error: 'details failed' });
  }
});

// GET /places/distance?fromLat=..&fromLng=..&toLat=..&toLng=..
router.get('/distance', async (req, res) => {
  const { fromLat, fromLng, toLat, toLng } = req.query;
  if (!KEY() || !fromLat || !toLat) {
    return res.json({ distanceKm: null });
  }
  try {
    const params = new URLSearchParams({
      origins: `${fromLat},${fromLng}`,
      destinations: `${toLat},${toLng}`,
      key: KEY(),
      mode: 'driving',
    });
    const r = await fetch(`${DISTANCE_BASE}?${params}`);
    const data = await r.json();
    const meters = data.rows?.[0]?.elements?.[0]?.distance?.value;
    return res.json({ distanceKm: meters != null ? meters / 1000 : null });
  } catch (e) {
    console.error('distance failed:', e.message);
    return res.json({ distanceKm: null });
  }
});

export default router;
